import 'package:flutter/material.dart';
import 'login.dart'; // Login widget
import 'registration.dart'; // Signup widget
import 'dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafeSewa',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/', // Set the initial route
      routes: {
        '/': (context) => const HomeScreen(), // Home screen route
        '/login': (context) => SignInPage(), // Login screen route
        '/signup': (context) => SignupPage(), // Signup screen route
        '/dashboard': (context) => Dashboard(token: ''), // Dashboard route
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authentication UI')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login'); // Navigate to Login
              },
              child: const Text("Go to Login"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup'); // Navigate to Signup
              },
              child: const Text("Go to Signup"),
            ),
          ],
        ),
      ),
    );
  }
}
