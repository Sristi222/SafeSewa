import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController _controller = TextEditingController();
  List<String> emergencyContacts = [];

  @override
  void initState() {
    super.initState();
    _loadEmergencyNumbers();
  }

  /// ✅ Load emergency numbers from SharedPreferences
  Future<void> _loadEmergencyNumbers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      emergencyContacts = prefs.getStringList('emergency_numbers') ?? [];
    });
  }

  /// ✅ Save emergency numbers to SharedPreferences
  Future<void> _saveEmergencyNumbers() async {
    if (_controller.text.isNotEmpty && emergencyContacts.length < 2) {
      setState(() {
        emergencyContacts.add(_controller.text);
        _controller.clear();
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('emergency_numbers', emergencyContacts);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Emergency contact saved!')),
      );
    } else if (emergencyContacts.length >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can only store up to 2 contacts.')),
      );
    }
  }

  /// ✅ Remove a contact
  Future<void> _removeContact(int index) async {
    setState(() {
      emergencyContacts.removeAt(index);
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('emergency_numbers', emergencyContacts);
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
            Text('Emergency Contact Numbers:', style: TextStyle(fontSize: 18)),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Enter phone number',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveEmergencyNumbers,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: Text('Save Contact', style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 20),
            Text('Saved Contacts:', style: TextStyle(fontSize: 18)),
            Expanded(
              child: ListView.builder(
                itemCount: emergencyContacts.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(emergencyContacts[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeContact(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
