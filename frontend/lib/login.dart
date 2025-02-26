import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dashboard.dart'; // Import Dashboard page
import 'volunteer_dashboard.dart'; // Import Volunteer Dashboard page
import 'admin_dashboard.dart'; // Import Admin Dashboard page

class SignInPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  SignInPage({super.key});

  Future<void> loginUser(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email and password are required")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final bool isSuccess = jsonResponse['status'] ?? false;
        final String? userId = jsonResponse['userId'];
        final String? token = jsonResponse['token'];
        final String? role = jsonResponse['role'];

        if (!isSuccess || userId == null || token == null || role == null) {
          print("❌ ERROR: User ID or Role is null or missing!");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login failed. Please try again.")),
          );
          return;
        }

        print("✅ Login Successful! User ID: $userId, Role: $role");

        // ✅ Store token & userId in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);
        await prefs.setString("userId", userId);
        await prefs.setString("role", role);

        // ✅ Navigate to appropriate dashboard based on role
        Widget nextPage;
        if (role == "Volunteer") {
          nextPage = VolunteerDashboard(token: token, userId: userId);
        } else if (role == "Admin") {
          nextPage = AdminDashboard(token: token, userId: userId);
        } else {
          nextPage = Dashboard(token: token, userId: userId);
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => nextPage),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid email or password")),
        );
      }
    } catch (error) {
      print("❌ Error during login: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to connect to the server")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Sign In",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => loginUser(context),
              child: const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
