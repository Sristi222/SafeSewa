import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FundraiserFormScreen extends StatefulWidget {
  @override
  _FundraiserFormScreenState createState() => _FundraiserFormScreenState();
}

class _FundraiserFormScreenState extends State<FundraiserFormScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController goalAmountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? userId; // Store userId from SharedPreferences

  @override
  void initState() {
    super.initState();
    _fetchUserId(); // Get userId when the screen loads
  }

  // ✅ Fetch User ID from SharedPreferences
  Future<void> _fetchUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
    });
  }

  // ✅ Submit Fundraiser
  Future<void> submitFundraiser() async {
    if (!_formKey.currentState!.validate()) return;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ User not logged in! Please log in again.')),
      );
      return;
    }

    try {
      Response response = await Dio().post(
        'http://192.168.1.4:3000/fundraise', // Update with your API URL
        data: jsonEncode({
          'title': titleController.text.trim(),
          'description': descriptionController.text.trim(),
          'goalAmount': int.parse(goalAmountController.text),
          'userId': userId, // ✅ Automatically attach logged-in userId
        }),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Fundraiser submitted successfully!')),
        );
        titleController.clear();
        descriptionController.clear();
        goalAmountController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Failed to submit fundraiser. Try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error submitting fundraiser: $e')),
      );
      print("❌ Fundraiser Submission Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Fundraiser')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value == null || value.isEmpty ? 'Title is required' : null,
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => value == null || value.isEmpty ? 'Description is required' : null,
              ),
              TextFormField(
                controller: goalAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Goal Amount'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Goal amount is required';
                  if (int.tryParse(value) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitFundraiser,
                child: const Text('Submit Fundraiser'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
