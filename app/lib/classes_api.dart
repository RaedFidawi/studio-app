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
}
