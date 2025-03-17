import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SOSScreen extends StatefulWidget {
  final String userId; // ✅ User ID required for backend
  SOSScreen({required this.userId});

  @override
  _SOSScreenState createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> {
  List<String> emergencyContacts = [];
  bool isSendingSOS = false; // ✅ Added a flag to prevent multiple taps

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

  /// ✅ Send SOS Alert to Volunteers & Emergency Contacts
  Future<void> _sendSOS() async {
    if (isSendingSOS) return; // Prevent duplicate requests
    setState(() {
      isSendingSOS = true;
    });

    if (emergencyContacts.isEmpty) {
      _showSnackbar("⚠️ Please set at least one emergency contact in Profile.");
      setState(() {
        isSendingSOS = false;
      });
      return;
    }

    bool serviceEnabled;
    LocationPermission permission;

    // ✅ Ensure location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackbar("⚠️ Location services are disabled. Please enable them.");
      setState(() {
        isSendingSOS = false;
      });
      return;
    }

    // ✅ Check and request location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackbar("⚠️ Location permission denied. Enable it in settings.");
        setState(() {
          isSendingSOS = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackbar("⚠️ Location permission permanently denied. Enable it in settings.");
      setState(() {
        isSendingSOS = false;
      });
      return;
    }

    // ✅ Fetch user location
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    double latitude = position.latitude;
    double longitude = position.longitude;

    // ✅ Send SOS to backend & emergency contacts
    await _sendSOSAlertToVolunteers(latitude, longitude);
    await _sendSOSMessageToContacts(latitude, longitude);

    setState(() {
      isSendingSOS = false;
    });
  }

  /// ✅ Function to send SOS alert to volunteers (Backend API call)
  Future<void> _sendSOSAlertToVolunteers(double latitude, double longitude) async {
    try {
      final response = await http.post(
        Uri.parse("http://192.168.1.4:3000/api/sos"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": widget.userId,
          "latitude": latitude,
          "longitude": longitude,
        }),
      );

      if (response.statusCode == 201) {
        _showSnackbar("✅ SOS Sent! Volunteers Notified.");
      } else {
        _showSnackbar("❌ Failed to notify volunteers. Try again.");
      }
    } catch (e) {
      _showSnackbar("⚠️ Error: Unable to send SOS.");
    }
  }

  /// ✅ Function to send SOS message to emergency contacts
  Future<void> _sendSOSMessageToContacts(double latitude, double longitude) async {
    String locationMessage =
        "🚨 SOS ALERT! 🚨\n"
        "I need immediate help!\n"
        "📍 My location:\n"
        "Latitude: $latitude\n"
        "Longitude: $longitude\n"
        "🔗 Google Maps Link:\n"
        "https://www.google.com/maps?q=$latitude,$longitude";

    for (String contact in emergencyContacts) {
      String smsUrl = "sms:$contact?body=${Uri.encodeComponent(locationMessage)}";

      if (await canLaunch(smsUrl)) {
        await launch(smsUrl);
      } else {
        _showSnackbar("⚠️ Failed to send SOS to $contact.");
      }
    }
  }

  /// ✅ Show Snackbar Message
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
              'Press the button to send an SOS alert to your emergency contacts & volunteers.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isSendingSOS ? null : _sendSOS, // ✅ Disable button while sending
              style: ElevatedButton.styleFrom(
                backgroundColor: isSendingSOS ? Colors.grey : Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text(isSendingSOS ? "Sending..." : "Send SOS",
                  style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
