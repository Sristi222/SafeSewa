import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _apiUrl = 'http://192.168.101.9:3000/api/flood-alerts'; 

  // Fetch flood alerts from backend
  static Future<List<dynamic>> fetchFloodAlerts() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error fetching alerts: $e');
      return [];
    }
  }
}

// ignore: prefer_const_declarations
final url = 'http://192.168.101.9:3000/';
// ignore: prefer_interpolation_to_compose_strings
final registration = url + "registration";
// ignore: prefer_interpolation_to_compose_strings
final login = url + "login";
