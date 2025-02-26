import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import "config.dart";

class VolunteerDashboard extends StatefulWidget {
  final String token;
  final String userId;

  const VolunteerDashboard({required this.token, required this.userId, super.key});

  @override
  _VolunteerDashboardState createState() => _VolunteerDashboardState();
}

class _VolunteerDashboardState extends State<VolunteerDashboard> {
  bool isApproved = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkApprovalStatus();
  }

  Future<void> checkApprovalStatus() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/user/${widget.userId}"),
        headers: {"Authorization": "Bearer ${widget.token}"},
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          isApproved = jsonResponse['isApproved'] ?? false;
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Error checking approval status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Volunteer Dashboard")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isApproved
              ? const Center(child: Text("✅ Welcome Volunteer! You are approved."))
              : const Center(child: Text("⏳ Your account is pending approval.")),
    );
  }
}
