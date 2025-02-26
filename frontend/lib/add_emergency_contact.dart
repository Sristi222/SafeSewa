import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEmergencyNumber();
  }

  Future<void> _loadEmergencyNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _controller.text = prefs.getString('emergency_number') ?? '';
  }

  Future<void> _saveEmergencyNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('emergency_number', _controller.text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Emergency contact saved!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Emergency Contact Number:', style: TextStyle(fontSize: 18)),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Enter phone number',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveEmergencyNumber,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: Text('Save Contact', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
