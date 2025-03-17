import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/config.dart'; // ✅ Keep using login from config.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dashboard.dart'; // Import Dashboard page
import 'volunteer_dashboard.dart'; // Import Volunteer Dashboard page
import 'admin_dashboard.dart'; // Import Admin Dashboard page

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false; // ✅ Loading state

  Future<void> loginUser(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Email and password are required")),
      );
      return;
    }

    setState(() {
      isLoading = true; // ✅ Show loading spinner
    });

    try {
      final response = await http.post(
        Uri.parse(login), // ✅ Keep existing API from config.dart
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      print("📩 API Response: ${response.statusCode} - ${response.body}");

      final jsonResponse = jsonDecode(response.body);
      final bool isSuccess = jsonResponse['status'] ?? false;
      final String? userId = jsonResponse['userId'];
      final String? token = jsonResponse['token'];
      final String? role = jsonResponse['role'];
      final String? errorMessage = jsonResponse['error'];

      if (!isSuccess) {
        setState(() {
          isLoading = false; // ✅ Hide loading indicator
        });

        // 🚨 Handle Volunteer Not Approved Case
        if (role == "Volunteer" && errorMessage == "Your account is pending approval by the Admin.") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("⏳ Your account is pending admin approval."),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        // 🚨 General login failure case
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage ?? "❌ Login failed. Please check your credentials.")),
        );
        return;
      }

      if (userId == null || token == null || role == null) {
        setState(() {
          isLoading = false;
        });

        print("❌ ERROR: User ID, Token, or Role is missing!");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Login failed. Please try again.")),
        );
        return;
      }

      print("✅ Login Successful! User ID: $userId, Role: $role");

      // ✅ Store token & userId securely
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

      setState(() {
        isLoading = false; // ✅ Hide loading indicator
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextPage),
      );
    } catch (error) {
      print("❌ Error during login: $error");

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to connect to the server.")),
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
            isLoading
                ? const CircularProgressIndicator() // ✅ Show loading indicator while logging in
                : ElevatedButton(
                    onPressed: () => loginUser(context),
                    child: const Text("Login"),
                  ),
          ],
        ),
      ),
    );
  }
}
