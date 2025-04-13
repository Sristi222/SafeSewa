import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _apiUrl = 'http://192.168.1.4:3000/api/flood-alerts';

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

// ignore: prefer_const_declarations choose Wireless LAN adapter WiFi: in cmd do ipconfig
final url = 'http://192.168.1.4:3000/';//http://100.64.216.142:3000/
// ignore: prefer_interpolation_to_compose_strings
final registration = url + "registration";
// ignore: prefer_interpolation_to_compose_strings
final login = url + "login";

const String baseUrl = "http://192.168.1.4:3000/api";
const String sosUrl = "$baseUrl/sos";
const String emergencyContactsUrl = "$baseUrl/emergency-contacts";

const String forgotPasswordUrl = "$baseUrl/reset-password-direct";
const String changePasswordUrl = "$baseUrl/change-password";


const String sosUserUrl = "$baseUrl/sosuser";