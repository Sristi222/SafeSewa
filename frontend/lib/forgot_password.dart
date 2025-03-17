import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  ForgotPasswordScreen({super.key});

  void sendResetLink(BuildContext context) {
    String email = emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Please enter your email.")),
      );
      return;
    }

    // TODO: Call the backend API to send reset email

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Reset link sent! Check your email.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Enter your email"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => sendResetLink(context),
              child: const Text("Send Reset Link"),
            ),
          ],
        ),
      ),
    );
  }
}
