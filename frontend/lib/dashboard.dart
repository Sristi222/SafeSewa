import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  final String token;

  const Dashboard({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      body: Center(
        child: Text(
          "Welcome to the Dashboard!\nToken: $token",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
