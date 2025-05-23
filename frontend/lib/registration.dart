import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String selectedRole = 'User';

  Future<void> registerUser(BuildContext context) async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if ([username, email, phone, password, confirmPassword].any((e) => e.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(registration),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "email": email,
          "phone": phone,
          "password": password,
          "role": selectedRole
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final bool isSuccess = jsonResponse['status'] ?? false;
        final String? userId = jsonResponse['userId'];

        if (!isSuccess || userId == null) {
          print("❌ ERROR: Registration failed!");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Signup failed. Please try again.")),
          );
          return;
        }

        // ✅ Store profile data locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("userId", userId);
        await prefs.setString("profile_name", username);
        await prefs.setString("profile_email", email);
        await prefs.setString("profile_phone", phone);
        await prefs.setString("profile_username", '@$username');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signup successful! Please log in.")),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signup failed. Please try again.")),
        );
      }
    } catch (error) {
      print("❌ Error during signup: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to connect to the server")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  "Create Account",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1D2AFF)),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  items: ["User", "Volunteer"].map((role) {
                    return DropdownMenuItem(value: role, child: Text(role));
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() => selectedRole = newValue!);
                  },
                  decoration: InputDecoration(
                    labelText: "Register as",
                    filled: true,
                    fillColor: const Color(0xFFF1F4FF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF1D2AFF)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _inputField("Username", usernameController),
                const SizedBox(height: 16),
                _inputField("Email", emailController),
                const SizedBox(height: 16),
                _inputField("Phone Number", phoneController, keyboard: TextInputType.phone),
                const SizedBox(height: 16),
                _inputField("Password", passwordController, isPassword: true),
                const SizedBox(height: 16),
                _inputField("Confirm Password", confirmPasswordController, isPassword: true),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => registerUser(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D2AFF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 3,
                    ),
                    child: const Text("Signup", style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Login", style: TextStyle(color: Color(0xFF1D2AFF))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(String hint, TextEditingController controller, {bool isPassword = false, TextInputType? keyboard}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF1F4FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
