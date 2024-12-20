import 'dart:convert';
import 'package:http/http.dart' as http;

class UserAPI {
  // The base URL of your API (change this to the actual URL of your API)
  // static const String baseUrl = 'http://127.0.0.1:5000';  // Replace with your actual API URL
  static const String baseUrl = "https://lsltranslator.pythonanywhere.com";

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

  static Future<bool> deleteUser(String userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/delete_user/$userId'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
      
    }
  }
}
