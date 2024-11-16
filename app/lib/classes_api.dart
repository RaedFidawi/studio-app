// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class ClassesAPI {
//   static const String baseUrl = 'http://127.0.0.1:5000'; // Make sure to adjust this URL

//   // Function to get classes from the API
//   static Future<List<Map<String, dynamic>>> getClasses({
//     required String token,
//   }) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/get_classes'),
//         headers: <String, String>{
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token', // Pass the JWT token in headers
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
        
//         // Ensure the 'classes' key exists in the response data
//         if (data.containsKey('classes') && data['classes'] is List) {
//           return List<Map<String, dynamic>>.from(data['classes']);
//         } else {
//           throw Exception('Invalid data format: No "classes" key in response');
//         }
//       } else {
//         throw Exception('Failed to fetch classes: ${response.body}');
//       }
//     } catch (e) {
//       throw Exception('Error fetching classes: $e');
//     }
//   }
// }

// ############################################# NEW #########################################################

import 'dart:convert';
import 'dart:typed_data';  // For handling the decoded image bytes
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ClassesAPI {
  static const String baseUrl = 'http://127.0.0.1:5000'; // Make sure to adjust this URL

  // Function to get classes from the API and decode image data
  static Future<List<Map<String, dynamic>>> getClasses({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_classes'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Pass the JWT token in headers
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Ensure the 'classes' key exists in the response data
        if (data.containsKey('classes') && data['classes'] is List) {
          List<Map<String, dynamic>> classes = List<Map<String, dynamic>>.from(data['classes']);

          // Process each class and decode the image
          for (var cls in classes) {
            if (cls.containsKey('image') && cls['image'] is String) {
              String base64Image = cls['image'];
              
              // Decode the Base64 image string into bytes
              Uint8List decodedImage = base64Decode(base64Image);
              
              // Add the decoded image to the class data for returning
              cls['decoded_image'] = decodedImage;
            }
          }

          // Return the updated list with decoded images
          return classes;
        } else {
          throw Exception('Invalid data format: No "classes" key in response');
        }
      } else {
        throw Exception('Failed to fetch classes: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching classes: $e');
    }
  }

  static Future<Map<String, dynamic>> reserveClass({
    required String userId,
    required String classId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reserve_class'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
        'class_id': classId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);  // Return response data if success
    } else {
      throw Exception('Failed to reserve class: ${response.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchUserClasses({
    required String token,
    required String userId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_user_reservations/$userId'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data.containsKey('reserved_classes') && data['reserved_classes'] is List) {
          List<Map<String, dynamic>> classes = List<Map<String, dynamic>>.from(data['reserved_classes']);

          // Decode each class image if present
          for (var cls in classes) {
            if (cls.containsKey('image') && cls['image'] is String) {
              String base64Image = cls['image'];
              Uint8List decodedImage = base64Decode(base64Image);
              cls['decoded_image'] = decodedImage;
            }
          }

          return classes;
        } else {
          throw Exception('Invalid data format: No "reserved_classes" key in response');
        }
      } else {
        throw Exception('Failed to fetch user-reserved classes: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching user-reserved classes: $e');
    }
  }

  static Future<Map<String, dynamic>> removeClass(String userId, String classId) async {
    // Prepare the data for the request
    final Map<String, dynamic> requestData = {
      'user_id': userId,
      'class_id': classId,
    };

    // Make the HTTP POST request to the backend
    final response = await http.post(
      Uri.parse('$baseUrl/remove_class'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(requestData),
    );

    // Check the response status code
    if (response.statusCode == 200) {
      // If successful, return the parsed JSON response
      return json.decode(response.body);
    } else {
      // If error occurs, return the error message
      return {'error': 'Failed to remove class from reservation'};
    }
  }
}
