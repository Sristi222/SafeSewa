import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import './add_emergency_contact.dart';

class SOSScreen extends StatefulWidget {
  @override
  _SOSScreenState createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> {
  String emergencyNumber = '';

  @override
  void initState() {
    super.initState();
    _loadEmergencyNumber();
  }

  /// ✅ Load Emergency Contact from Shared Preferences
  Future<void> _loadEmergencyNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      emergencyNumber = prefs.getString('emergency_number') ?? '';
    });
  }

  /// ✅ Send SOS Message with Exact Latitude & Longitude
  Future<void> _sendSOS() async {
    if (emergencyNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please set an emergency contact in Profile.')),
      );
      return;
    }

    bool serviceEnabled;
    LocationPermission permission;

    // ✅ Ensure location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location services are disabled. Please enable them.')),
      );
      return;
    }

    // ✅ Check and request location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permission denied. Please enable it in settings.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permission permanently denied. Enable it in settings.')),
      );
      return;
    }

    // ✅ Fetch user location with high accuracy
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    double latitude = position.latitude;
    double longitude = position.longitude;

    // ✅ Construct location message with exact coordinates & Google Maps link
    String locationMessage =
        "🚨 SOS ALERT! 🚨\n"
        "I need immediate help!\n"
        "📍 My location:\n"
        "Latitude: $latitude\n"
        "Longitude: $longitude\n"
        "🔗 Google Maps Link:\n"
        "https://www.google.com/maps?q=$latitude,$longitude";

    // ✅ Send SOS message via SMS
    String smsUrl = "sms:$emergencyNumber?body=${Uri.encodeComponent(locationMessage)}";

    if (await canLaunch(smsUrl)) {
      await launch(smsUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send SOS message.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SOS App')),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.red),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              title: Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                ).then((_) => _loadEmergencyNumber());
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Press the button to send an SOS alert.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendSOS,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text('Send SOS', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
