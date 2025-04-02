import 'dart:convert';
import 'package:frontend/model/disaster_precaution.dart';
import 'package:http/http.dart' as http;


class PrecautionService {
  static const String baseUrl = "http://localhost:3000/api/precautions";

  static Future<List<DisasterPrecaution>> fetchPrecautions() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((item) => DisasterPrecaution.fromJson(item)).toList();
    } else {
      throw Exception("Failed to fetch precautions");
    }
  }

  static Future<void> addPrecaution(String title, String description) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'description': description}),
    );
    if (response.statusCode != 201) throw Exception("Failed to add precaution");
  }

  static Future<void> updatePrecaution(String id, String title, String description) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'description': description}),
    );
    if (response.statusCode != 200) throw Exception("Failed to update precaution");
  }

  static Future<void> deletePrecaution(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) throw Exception("Failed to delete precaution");
  }
}
