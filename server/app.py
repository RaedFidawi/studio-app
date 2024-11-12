from flask import Flask, request, jsonify
from pymongo import MongoClient
import bcrypt
import jwt  # Import JWT
import os
from datetime import datetime, timedelta
from functools import wraps
from dotenv import load_dotenv
from werkzeug.utils import secure_filename
import base64
from bson import ObjectId

load_dotenv()
mongodb_uri = os.getenv("MONGODB_URI")
secret_key = os.getenv("SECRET_KEY", "your_default_secret_key")  # Use a secret key for JWT

app = Flask(__name__)

client = MongoClient(mongodb_uri)
db = client['user_database']
users_collection = db['users']
classes_collection = db['classes']

################################################# START USER APIS #############################################################

def hash_password(password):
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())

def check_password(stored_hash, password):
    return bcrypt.checkpw(password.encode('utf-8'), stored_hash)

# JWT helper function to create token
def create_token(data):
    expiration = datetime.utcnow() + timedelta(hours=1)
    return jwt.encode({'user_id': data, 'exp': expiration}, secret_key, algorithm='HS256')

# JWT decorator to protect routes
def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization')
        if not token:
            return jsonify({"message": "Token is missing!"}), 403
        try:
            jwt.decode(token, secret_key, algorithms=['HS256'])
        except jwt.ExpiredSignatureError:
            return jsonify({"message": "Token expired!"}), 403
        except jwt.InvalidTokenError:
            return jsonify({"message": "Invalid token!"}), 403
        return f(*args, **kwargs)
    return decorated

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

    token = create_token(data['username'])

    return jsonify({"message": "User successfully signed up", "token": token}), 201


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

    # Generate JWT token upon successful sign-in
    token = create_token(user['username'])
    return jsonify({"message": "Successfully signed in", "token": token}), 200

################################################# END USER APIS #############################################################

################################################# START CLASSES APIS #############################################################

def encode_image(image_path):
    """
    Reads an image from the given file path and returns it as a Base64-encoded string.

    Parameters:
        image_path (str): Path to the image file.

    Returns:
        str: Base64-encoded string of the image.
    """
    with open(image_path, "rb") as image_file:
        # Read and encode the image
        encoded_string = base64.b64encode(image_file.read()).decode('utf-8')

    with open('encoded_image.txt', "w") as result_file:
        result_file.write(encoded_string)

    return encoded_string


@app.route('/create_class', methods=['POST'])
def create_class():
    data = request.json

    if not all(key in data for key in ("name", "time", "available", "members", "image")):
        return jsonify({"message": "Missing required fields"}), 400

    image_data = data['image']

    try:
        base64.b64decode(image_data)
    except Exception as e:
        return jsonify({"message": "Invalid image format"}), 400

    # Create class document
    class_data = {
        "name": data['name'],
        "time": data['time'],
        "available": data['available'],
        "members": data['members'],
        "image": image_data
    }

    classes_collection.insert_one(class_data)

    return jsonify({"message": "Class successfully created"}), 201

@app.route('/get_classes', methods=['GET'])
def get_classes():
    classes = list(classes_collection.find())
    for cls in classes:
        cls["_id"] = str(cls["_id"])
    return jsonify({"classes": classes}), 200

@app.route('/delete_class', methods=['DELETE'])
def delete_class():
    data = request.json

    if "name" not in data:
        return jsonify({"message": "Missing required field: name"}), 400

    class_name = data['name']

    # Find and delete class with the provided name
    result = classes_collection.delete_one({"name": class_name})

    if result.deleted_count == 0:
        return jsonify({"message": "Class not found"}), 404

    return jsonify({"message": f"Class '{class_name}' successfully deleted"}), 200


@app.route('/reserve_class', methods=['POST'])
@token_required
def reserve_class():
    
    data = request.json
    user_id = data['user_id']
    class_id = data['class_id']

    if not user_id or not class_id:
        return jsonify({"message": "Missing required fields: user_id or class_id"}), 400

    try:
        # Retrieve the class
        class_data = classes_collection.find_one({"_id": ObjectId(class_id)})
        if not class_data:
            return jsonify({"message": "Class not found"}), 404

        # Check class availability
        if not class_data['available']:
            return jsonify({"message": "Class is not available"}), 400

        # Retrieve the user
        user = users_collection.find_one({"_id": ObjectId(user_id)})
        if not user:
            return jsonify({"message": "User not found"}), 404

        # Check if the user already reserved this class
        if ObjectId(class_id) in user.get("reserved_classes", []):
            return jsonify({"message": "Class already reserved by the user"}), 400

        # Update the class members and availability
        new_member_count = class_data['members'] + 1
        is_available = new_member_count < class_data['max_members']
        
        classes_collection.update_one(
            {"_id": ObjectId(class_id)},
            {
                "$set": {"members": new_member_count, "available": is_available}
            }
        )

        # Add class to user's reserved classes
        users_collection.update_one(
            {"_id": ObjectId(user_id)},
            {
                "$addToSet": {"reserved_classes": ObjectId(class_id)}
            }
        )

        return jsonify({"message": "Class reserved successfully"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

################################################# END CLASSES APIS #############################################################


if __name__ == '__main__':
    host = "127.0.0.1"
    # host = "10.0.2.2"
    # print(encode_image('Uploads/image.png'))
    app.run(host=host, port=5000, debug=True, threaded=True)