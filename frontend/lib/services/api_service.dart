import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/shared_prefs.dart';
import '../config.dart';

class ApiServices {
  // 🔹 Register User
  static Future<Map<String, dynamic>> registerUser(String username, String email, String phone, String password) async {
    final response = await http.post(
      Uri.parse(registration),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "email": email, "phone": phone, "password": password}),
    );

    print("📡 Register API Response: ${response.statusCode}");
    print("📡 Register Response Body: ${response.body}");

    return jsonDecode(response.body);
  }

  // 🔹 Login User
  static Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse(login),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    print("📡 Login API Response: ${response.statusCode}");
    print("📡 Login Response Body: ${response.body}");

    return jsonDecode(response.body);
  }

  // 🔹 Add Emergency Contact
  static Future<Map<String, dynamic>> addEmergencyContact(String name, String phone) async {
    final userId = await SharedPrefs.getUserId();
    
    final response = await http.post(
      Uri.parse("$baseUrl/addEmergencyContact"), // ✅ Ensure correct API endpoint
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId, "name": name, "phone": phone}),
    );

    print("📡 Add Emergency Contact API Response: ${response.statusCode}");
    print("📡 Response Body: ${response.body}"); // ✅ Debugging

    final jsonResponse = jsonDecode(response.body);
    return jsonResponse;
  }

  // 🔹 Fetch Emergency Contacts
  static Future<List<dynamic>> fetchEmergencyContacts() async {
    final userId = await SharedPrefs.getUserId();
    final response = await http.get(Uri.parse("$emergencyContactsUrl/$userId"));

    print("📡 Fetch Emergency Contacts API Response: ${response.statusCode}");
    print("📡 Response Body: ${response.body}");

    return jsonDecode(response.body);
  }

  // 🔹 Send SOS Alert
  static Future<Map<String, dynamic>> sendSOS(double latitude, double longitude) async {
    final userId = await SharedPrefs.getUserId();
    
    final response = await http.post(
      Uri.parse(sosUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId, "latitude": latitude, "longitude": longitude}),
    );

    print("📡 SOS API Response: ${response.statusCode}");
    print("📡 Response Body: ${response.body}"); // ✅ Debugging

    final jsonResponse = jsonDecode(response.body);
    return jsonResponse;
  }
}
