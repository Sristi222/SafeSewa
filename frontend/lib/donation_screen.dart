import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class DonationScreen extends StatefulWidget {
  final String fundraiserId; // ✅ Ensure fundraiserId is passed

  DonationScreen({required this.fundraiserId}); // ✅ Constructor update

  @override
  _DonationScreenState createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _donorNameController = TextEditingController();

  String _selectedPaymentMethod = 'Khalti'; // Default payment method

  // ✅ Change the URL based on your testing environment
  final String backendUrl = "http://192.168.1.4:3000"; // ✅ Change for actual server
  // final String backendUrl = "http://10.0.2.2:3001"; // ✅ Use for Android Emulator

  Future<void> _donate() async {
    String amount = _amountController.text.trim();
    String donorName = _donorNameController.text.trim();

    if (donorName.isEmpty || amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your name and amount')),
      );
      return;
    }

    final apiUrl = "$backendUrl/donate";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "donorName": donorName,
          "amount": int.parse(amount),
          "fundraiserId": widget.fundraiserId, // ✅ Ensure fundraiserId is sent
          "website_url": backendUrl,
        }),
      );

      final data = jsonDecode(response.body);
      print("Response Status: ${response.statusCode}");
      print("Response Data: $data");

      if (response.statusCode == 200 && data['success']) {
        String khaltiUrl = data['payment']['payment_url'];
        if (await canLaunch(khaltiUrl)) {
          await launch(khaltiUrl); // Open Khalti payment URL
        } else {
          throw 'Could not launch $khaltiUrl';
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${data['message']}")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to connect to server")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Donate Now')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your Name:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _donorNameController,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                hintText: 'Enter your name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Enter Donation Amount:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter amount (e.g., 500)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.money),
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _donate,
                child: Text('Donate via Khalti'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
