from flask import Flask, request, jsonify
from pymongo import MongoClient
import bcrypt
import jwt  # Import JWT
import os
from datetime import datetime, timedelta
from functools import wraps
from dotenv import load_dotenv
import base64
from bson import ObjectId
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger

scheduler = BackgroundScheduler()

load_dotenv()
mongodb_uri = os.getenv("MONGODB_URI")
secret_key = os.getenv("SECRET_KEY", "your_default_secret_key")  # Use a secret key for JWT

app = Flask(__name__)

client = MongoClient(mongodb_uri)
db = client['user_database']
users_collection = db['users']
classes_collection = db['classes']
packages_collection = db["packages"]

################################################# START CLEAR RESERVATIONS #############################################################
# def reset_reservations_and_capacities():
#     # 1. Reset all user reservations
#     users_collection.update_many({}, {"$set": {"reserved_classes": []}})

#     # 2. Reset all class capacities to the initial_capacity and set available to true
#     # classes_collection.update_many(
#     #     {},
#     #     {
#     #         "$set": {
#     #             "capacity": {

#     #             },
#     #             "members": [],
#     #             "available": True
#     #         }
#     #     }
#     # )

#     # print(f"Reset performed at {datetime.now()}")
#     for class_doc in classes_collection.find({}, {"_id": 1, "initial_capacity": 1}):
#         initial_capacity = class_doc.get("initial_capacity", 0)  # Default to 0 if not set
#         class_id = class_doc["_id"]

#         # Update each class manually
#         classes_collection.update_one(
#             {"_id": class_id},
#             {
#                 "$set": {
#                     "capacity": initial_capacity,
#                     "members": [],
#                     "available": True
#                 }
#             }
#         )
#     print(f"Manual reset performed at {datetime.now()}")

# scheduler = BackgroundScheduler()
# trigger = CronTrigger(hour=0, minute=0)  # Run daily at 12 AM
# scheduler.add_job(reset_reservations_and_capacities, trigger)
# scheduler.start()
################################################# END CLEAR RESERVATIONS #############################################################

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

    if not all(key in data for key in ("email", "username", "password", "number", "allowed_reservations")):
        return jsonify({"message": "Missing required fields"}), 400

    if users_collection.find_one({"email": data['email']}) or users_collection.find_one({"username": data['username']}):
        return jsonify({"message": "User with this email or username already exists"}), 400

    # hashed_password = hash_password(data['password'])

    user_data = {
        "email": data['email'],
        "username": data['username'],
        "password": data['password'],
        "number": data['number'],
        "reserved_classes": [],
        "allowed_reservations": data['allowed_reservations'],
        "allowed_reformer": data['allowed_reformer']
    }

    # Insert user data and retrieve the inserted ID
    result = users_collection.insert_one(user_data)
    user_id = str(result.inserted_id)  # Convert ObjectId to string

    # Generate token
    token = create_token(user_id)

    return jsonify({"message": "User successfully signed up", "token": token, "user_id": user_id}), 201


@app.route('/signin', methods=['POST'])
def signin():
    data = request.json

    if not all(key in data for key in ("username", "password")):
        return jsonify({"message": "Missing required fields"}), 400

    user = users_collection.find_one({"username": data['username']})
    if user is None:
        return jsonify({"message": "User not found"}), 404

    # if not check_password(user['password'], data['password']):
    #     return jsonify({"message": "Incorrect password"}), 401

    # Generate token using user ID
    user_id = str(user['_id'])  # Convert ObjectId to string
    token = create_token(user_id)

    return jsonify({"message": "Successfully signed in", "token": token, "user_id": user_id}), 200

@app.route('/get_users', methods=['GET'])
def get_users():
    users = list(users_collection.find({}, {"password": 0}))  # Exclude password field
    for user in users:
        user["_id"] = str(user["_id"])
        user["reserved_classes"] = [str(cls_id) if isinstance(cls_id, ObjectId) else cls_id for cls_id in user["reserved_classes"]]
    return jsonify({"users": users}), 200

@app.route('/clear_user_reservations/<user_id>', methods=['POST'])
def clear_user_reservations(user_id):
    try:
        users_collection.update_one(
            {"_id": ObjectId(user_id)},
            {"$set": {"reserved_classes": []}}
        )
        return jsonify({"message": "User's reserved classes cleared successfully"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
# @app.route('/get_user_reservations/<user_id>', methods=['GET'])
# def get_user_reservations(user_id):
#     # Find the user by user_id
#     user = users_collection.find_one({"_id": ObjectId(user_id)})
    
#     if not user:
#         return jsonify({"error": "User not found"}), 404
    
#     # Initialize an empty list for the reserved classes
#     reserved_classes = []
    
#     if 'reserved_classes' in user:
#         # For each reserved class ID, fetch the class details from the classes collection
#         for class_id in user['reserved_classes']:
#             class_data = classes_collection.find_one({"_id": ObjectId(class_id)})

#             class_data["_id"] = str(class_data["_id"])
#             # # Add the full class data to the reserved_classes list, converting ObjectId to string
#             reserved_classes.append({
#                 "_id": class_data["_id"],
#                 "name": class_data["name"],
#                 "time": class_data.get("time"),
#                 "image": class_data.get("image"),
#                 "available": class_data.get("available"),
#                 "capacity": class_data.get("capacity"),
#                 "day": class_data.get("day")
#             })
    
#     return jsonify({"user_id": user_id, "reserved_classes": reserved_classes}), 200

@app.route('/get_user_reservations/<user_id>', methods=['GET'])
def get_user_reservations(user_id):
    # Find the user by user_id
    user = users_collection.find_one({"_id": ObjectId(user_id)})
    
    if not user:
        return jsonify({"error": "User not found"}), 404
    
    reserved_classes = []
    updated_reservations = []

    if 'reserved_classes' in user:
        # For each reserved class ID, check if it exists in the classes collection
        for class_id in user['reserved_classes']:
            class_data = classes_collection.find_one({"_id": ObjectId(class_id)})
            
            if class_data:
                # Add the full class data to the reserved_classes list, converting ObjectId to string
                reserved_classes.append({
                    "_id": str(class_data["_id"]),
                    "name": class_data["name"],
                    "time": class_data.get("time"),
                    "image": class_data.get("image"),
                    "available": class_data.get("available"),
                    "capacity": class_data.get("capacity"),
                    "day": class_data.get("day")
                })
                updated_reservations.append(class_id)  # Keep valid reservations
            else:
                # Log or handle the non-existent class (optional)
                print(f"Class with ID {class_id} does not exist.")

        # Update the user's reserved_classes in the database to remove invalid reservations
        users_collection.update_one(
            {"_id": ObjectId(user_id)},
            {"$set": {"reserved_classes": updated_reservations}}
        )
    
    return jsonify({"user_id": user_id, "reserved_classes": reserved_classes}), 200


@app.route('/remove_class', methods=['POST'])
def remove_class_from_reservation():
    # Get data from the request (assume JSON payload with user_id and class_id)
    data = request.get_json()
    user_id = data.get('user_id')
    class_id = data.get('class_id')

    # Validate the inputs
    if not user_id or not class_id:
        return jsonify({"error": "Both user_id and class_id are required"}), 400

    # Convert user_id and class_id to ObjectId for querying
    try:
        user_object_id = ObjectId(user_id)
        class_object_id = ObjectId(class_id)
    except Exception as e:
        return jsonify({"error": "Invalid user_id or class_id format"}), 400

    # Find the user in the database
    user = users_collection.find_one({"_id": user_object_id})
    if not user:
        return jsonify({"error": "User not found"}), 404

    # Find the class in the database
    class_data = classes_collection.find_one({"_id": class_object_id})
    if not class_data:
        return jsonify({"error": "Class not found"}), 404

    # Check if the class_id exists in the user's reserved_classes array
    if class_object_id not in user.get('reserved_classes', []):
        return jsonify({"error": "Class not found in user's reserved classes"}), 404

    # Remove the class_id from the user's reserved_classes array
    users_collection.update_one(
        {"_id": user_object_id},
        {"$pull": {"reserved_classes": class_object_id}, "$set": {"allowed_reservations": user['allowed_reservations'] + 1}}
    )

    # Remove the user from the class's reserved_members array
    classes_collection.update_one(
        {"_id": class_object_id},
        {"$pull": {"members": user_object_id}}  # Assuming 'reserved_members' is the list of user IDs
    )

    # Increase class capacity by 1
    new_capacity = class_data['capacity'] + 1

    # Get the number of current reserved members
    reserved_members_count = len(class_data.get('members', []))

    # Recheck availability (if reserved members count is less than capacity, the class is available)
    class_available = new_capacity > 0

    # Update the class with the new capacity and availability status
    classes_collection.update_one(
        {"_id": class_object_id},
        {
            "$set": {
                "capacity": new_capacity,
                "available": class_available
            }
        }
    )

    return jsonify({"message": "Class removed from reservation successfully, and class availability updated"}), 200

@app.route('/delete_user/<user_id>', methods=['DELETE'])
def delete_user(user_id):
    try:
        # Convert user_id to ObjectId
        user_object_id = ObjectId(user_id)
    except:
        return jsonify({"error": "Invalid user ID format"}), 400

    print(user_object_id)
    # Find the user by user_id
    user = users_collection.find_one({"_id": user_object_id})

    if not user:
        return jsonify({"error": "User not found"}), 404
    

    affected_classes = classes_collection.find({"members": {"$in": [user_object_id]}})

    for class_data in affected_classes:
        # classes_collection.update_one(
        #     {"_id": ObjectId(class_data["_id"])},
        #     {
        #         "$pull": {"members": user_object_id},
        #         "$inc": {"capacity": 1}
        #     }
        # )
        # available = True if class_data['capacity'] >= 0 else False
        classes_collection.update_one(
            {"_id": ObjectId(class_data["_id"])},
            {
                "$pull": {"members": user_object_id},
                "$inc": {"capacity": 1},
                "$set": {"available": True}
            }
        )

    # Delete the user from the users collection
    users_collection.delete_one({"_id": user_object_id})

    return jsonify({"message": "User deleted and associated memberships updated successfully"}), 200


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

    if not all(key in data for key in ("name", "time", "available", "image", "capacity")):
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
        "members": [],
        "image": image_data,
        "capacity": data['capacity'],
        "initial_capacity": data['initial_capacity'],
        "day": data['day']
    }

    classes_collection.insert_one(class_data)

    return jsonify({"message": "Class successfully created"}), 201

@app.route('/get_classes', methods=['GET'])
def get_classes():
    classes = list(classes_collection.find())

    for cls in classes:
        cls["_id"] = str(cls["_id"])

        if 'members' in cls:
            cls['members'] = [str(member) for member in cls['members']]

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
def reserve_class():
    data = request.json
    user_id = data.get('user_id')
    class_id = data.get('class_id')

    if not user_id or not class_id:
        return jsonify({"message": "Missing required fields: user_id or class_id"}), 400

    try:
        class_data = classes_collection.find_one({"_id": ObjectId(class_id)})
        if not class_data:
            return jsonify({"message": "Class not found"}), 404

        if not class_data.get('available', True):
            return jsonify({"message": "Class is not available"}), 400

        user = users_collection.find_one({"_id": ObjectId(user_id)})

        if not user:
            return jsonify({"message": "User not found"}), 404

        # Check allowed reservations or allowed reformer classes
        if class_data.get('name') == 'Pilates Reformer':
            if user.get('allowed_reformer', 0) == 0:
                return jsonify({"message": "No remaining Pilates Reformer classes available"}), 403
        else:
            if user.get('allowed_reservations', 0) == 0:
                return jsonify({"message": "Renew package"}), 404

        # Ensure reserved_classes is a list
        reserved_classes = user.get('reserved_classes', [])

        if ObjectId(class_id) in reserved_classes:
            return jsonify({"message": "Class already reserved by the user"}), 400

        # Update the class members and availability
        new_member_count = len(class_data['members']) + 1
        is_available = new_member_count < class_data['capacity']

        # Add the user ID to the class's members list (as ObjectId)
        class_members = class_data.get('members', [])
        class_members.append(ObjectId(user_id))  # Store as ObjectId

        # Update class with new members and availability
        classes_collection.update_one(
            {"_id": ObjectId(class_id)},
            {
                "$set": {"members": class_members, "available": is_available, "capacity": class_data['capacity'] - 1}
            }
        )

        reserved_classes.append(ObjectId(class_id))
        
        if class_data.get('name') == 'Pilates Reformer':
            result = users_collection.update_one(
                {"_id": ObjectId(user_id)},
                {"$set": {"reserved_classes": reserved_classes, "allowed_reformer": user['allowed_reformer'] - 1}}
            )
        else:
            result = users_collection.update_one(
                {"_id": ObjectId(user_id)},
                {"$set": {"reserved_classes": reserved_classes, "allowed_reservations": user['allowed_reservations'] - 1}}
            )

        print(result, reserved_classes)
        
        return jsonify({"message": "Class reserved successfully"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

    
@app.route('/clear_class_members/<class_id>', methods=['POST'])
def clear_class_members(class_id):
    try:
        classes_collection.update_one(
            {"_id": ObjectId(class_id)},
            {"$set": {"members": []}}
        )
        return jsonify({"message": "Class members cleared successfully"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

################################################# END CLASSES APIS #############################################################
################################################# START PRICES APIS ############################################################

@app.route('/create_package', methods=['POST'])
def create_package():
    data = request.json

    new_package = {
        "name": data["name"],
        "description": data['description']
    }
    result = packages_collection.insert_one(new_package)
    return jsonify({"message": "Package created", "id": str(result.inserted_id)}), 201

@app.route('/get_packages', methods=['GET'])
def get_packages():
    packages = list(packages_collection.find())
    for package in packages:
        package["_id"] = str(package["_id"])
    return jsonify(packages), 200

@app.route('/packages/<string:package_id>', methods=['GET'])
def get_package(package_id):
    package = packages_collection.find_one({"_id": ObjectId(package_id)})
    if not package:
        return jsonify({"error": "Package not found"}), 404
    package["_id"] = str(package["_id"])
    return jsonify(package), 200

# Route to delete a package
@app.route('/packages/<string:package_id>', methods=['DELETE'])
def delete_package(package_id):
    result = packages_collection.delete_one({"_id": ObjectId(package_id)})
    if result.deleted_count == 0:
        return jsonify({"error": "Package not found"}), 404
    return jsonify({"message": "Package deleted"}), 200

################################################# END PRICES APIS #############################################################
@app.route('/delete_all', methods=['DELETE'])
def delete_all():
    try:
        # Delete all documents in classes and users collections
        classes_collection.delete_many({})
        users_collection.delete_many({})

        return jsonify({"message": "All classes and users have been deleted successfully"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    host = "127.0.0.1"
    # host = "10.0.2.2"
    # print(encode_image('Uploads/image.png'))
    app.run(host=host, port=5000, debug=True, threaded=True)

## location tower 44 block A offices 11th floor office 118