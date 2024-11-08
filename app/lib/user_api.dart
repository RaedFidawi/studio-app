import 'dart:convert';
import 'package:http/http.dart' as http;

class UserAPI {
  // The base URL of your API (change this to the actual URL of your API)
  static const String baseUrl = 'http://10.0.2.2:5000';  // Replace with your actual API URL

  // Sign Up API
  static Future<Map<String, dynamic>> signUp({
    required String email,
    required String username,
    required String password,
    required String number,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'username': username,
        'password': password,
        'number': number,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);  // Return response data if success
    } else {
      throw Exception('Failed to sign up: ${response.body}');
    }
  }

  // Sign In API
  static Future<Map<String, dynamic>> signIn({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signin'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);  // Return response data if success
    } else {
      throw Exception('Failed to sign in: ${response.body}');
    }
  }
}
