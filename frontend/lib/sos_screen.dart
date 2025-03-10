import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class SOSScreen extends StatefulWidget {
  @override
  _SOSScreenState createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> {
  List<String> emergencyContacts = [];

  @override
  void initState() {
    super.initState();
    _loadEmergencyNumbers();
  }

  /// ✅ Load Emergency Contacts from SharedPreferences
  Future<void> _loadEmergencyNumbers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      emergencyContacts = prefs.getStringList('emergency_numbers') ?? [];
    });
  }

  /// ✅ Send SOS Message to Multiple Contacts
  Future<void> _sendSOS() async {
    if (emergencyContacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please set at least one emergency contact in Profile.')),
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

    // ✅ Fetch user location
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    double latitude = position.latitude;
    double longitude = position.longitude;

    // ✅ Construct location message
    String locationMessage =
        "🚨 SOS ALERT! 🚨\n"
        "I need immediate help!\n"
        "📍 My location:\n"
        "Latitude: $latitude\n"
        "Longitude: $longitude\n"
        "🔗 Google Maps Link:\n"
        "https://www.google.com/maps?q=$latitude,$longitude";

    // ✅ Send SOS to multiple contacts
    for (String contact in emergencyContacts) {
      String smsUrl = "sms:$contact?body=${Uri.encodeComponent(locationMessage)}";

      if (await canLaunch(smsUrl)) {
        await launch(smsUrl);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send SOS to $contact.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SOS App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Press the button to send an SOS alert to your emergency contacts.',
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
