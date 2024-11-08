from flask import Flask, request, jsonify
from pymongo import MongoClient
import bcrypt
import os
from dotenv import load_dotenv

load_dotenv()
mongodb_uri = os.getenv("MONGODB_URI")

app = Flask(__name__)

client = MongoClient(mongodb_uri)
db = client['user_database']
users_collection = db['users']

def hash_password(password):
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())

def check_password(stored_hash, password):
    return bcrypt.checkpw(password.encode('utf-8'), stored_hash)

@app.route('/signup', methods=['POST'])
def signup():
    data = request.json

    if not all(key in data for key in ("email", "username", "password", "number")):
        return jsonify({"message": "Missing required fields"}), 400

    if users_collection.find_one({"email": data['email']}) or users_collection.find_one({"username": data['username']}):
        return jsonify({"message": "User with this email or username already exists"}), 400

    hashed_password = hash_password(data['password'])

    user_data = {
        "email": data['email'],
        "username": data['username'],
        "password": hashed_password,
        "number": data['number']
    }

    users_collection.insert_one(user_data)

    return jsonify({"message": "User successfully signed up"}), 201


@app.route('/signin', methods=['POST'])
def signin():
    data = request.json

    if not all(key in data for key in ("username", "password")):
        return jsonify({"message": "Missing required fields"}), 400

    user = users_collection.find_one({"username": data['username']})
    if user is None:
        return jsonify({"message": "User not found"}), 404
    
    if not check_password(user['password'], data['password']):
        return jsonify({"message": "Incorrect password"}), 401

    return jsonify({"message": "Successfully signed in"}), 200


# Run the Flask app
if __name__ == '__main__':
    host = "127.0.0.1"
    # host = "10.0.2.2"
    app.run(host=host, port=5000, debug=True, threaded = True)
