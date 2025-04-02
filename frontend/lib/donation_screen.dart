import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class DonationScreen extends StatefulWidget {
  final String fundraiserId;

  DonationScreen({required this.fundraiserId});

  @override
  _DonationScreenState createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen>
    with WidgetsBindingObserver {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _donorNameController = TextEditingController();

  final String backendUrl = "http://192.168.1.5:3000";

  bool _openedKhalti = false;
  String? _latestPidx;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _openedKhalti) {
      _openedKhalti = false;

      // ✅ Verify donation on return
      verifyDonation().then((_) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("🎉 Donation Completed"),
            content: Text("Thank you for your donation!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to fundraiser screen
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
      });
    }
  }

  Future<void> verifyDonation() async {
    if (_latestPidx == null) return;

    final verifyUrl = "$backendUrl/verify-donation?pidx=$_latestPidx";

    try {
      final response = await http.get(Uri.parse(verifyUrl));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        print("✅ Donation verified successfully");
      } else {
        print("❌ Donation verification failed: ${data['message']}");
      }
    } catch (e) {
      print("❌ Error verifying donation: $e");
    }
  }

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
          "fundraiserId": widget.fundraiserId,
          "website_url": backendUrl,
        }),
      );

      final data = jsonDecode(response.body);
      print("Response Status: ${response.statusCode}");
      print("Response Data: $data");

      if (response.statusCode == 200 && data['success']) {
        String khaltiUrl = data['payment']['payment_url'];
        _latestPidx = data['payment']['pidx']; // ✅ Save pidx for verification

        if (await canLaunch(khaltiUrl)) {
          _openedKhalti = true;
          await launch(khaltiUrl);
        } else {
          throw 'Could not launch $khaltiUrl';
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${data['message']}")),
        );
      }
    } catch (e) {
      print("❌ Error: $e");
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
