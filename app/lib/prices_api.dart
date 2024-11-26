import 'dart:convert';
import 'package:http/http.dart' as http;

class PackagesAPI {
  // The base URL of your API (change this to the actual URL of your API)
  // static const String baseUrl = 'http://127.0.0.1:5000'; // Replace with your actual API URL
  static const String baseUrl = "lsltranslator.pythonanywhere.com" ;

  // Fetch all packages
  static Future<List<Map<String, dynamic>>> getPackages() async {
    final response = await http.get(
      Uri.parse('$baseUrl/get_packages'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      // Convert to a list of maps for easy handling
      return data.map((package) => package as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to fetch packages: ${response.body}');
    }
  }
}
