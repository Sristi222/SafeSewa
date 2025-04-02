import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:web_socket_channel/io.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SOSScreen extends StatefulWidget {
  final String userId; // ✅ User ID required for backend
  SOSScreen({required this.userId});

  @override
  _SOSScreenState createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> {
  bool isSendingSOS = false; // ✅ Prevent multiple taps
  late GoogleMapController mapController;
  LatLng? userLocation;
  LatLng? volunteerLocation;
  String statusMessage = "Waiting for a Volunteer...";
  IOWebSocketChannel? channel;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {}; // ✅ Route from volunteer to user
  List<String> emergencyContacts = []; // ✅ Emergency Contacts

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _loadEmergencyNumbers(); // ✅ Load emergency contacts on init
  }

  /// ✅ Load Emergency Contacts from SharedPreferences
  Future<void> _loadEmergencyNumbers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    emergencyContacts = prefs.getStringList('emergency_numbers') ?? [];
  }

  /// ✅ Get User's Current Location
  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackbar("⚠️ Enable location services.");
      return;
    }

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      _showSnackbar("⚠️ Location permission denied permanently.");
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
      markers.add(
        Marker(
          markerId: MarkerId("user"),
          position: userLocation!,
          infoWindow: InfoWindow(title: "You"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    });
  }

  /// ✅ Send SOS Alert to Volunteers & SMS to Contacts
  Future<void> _sendSOS() async {
    if (isSendingSOS || userLocation == null) return;

    setState(() {
      isSendingSOS = true;
      statusMessage = "SOS Sent! Waiting for Volunteer...";
    });

    try {
      final response = await http.post(
        Uri.parse("http://100.64.199.99:3000/api/sos"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": widget.userId,
          "latitude": userLocation!.latitude,
          "longitude": userLocation!.longitude,
        }),
      );

      if (response.statusCode == 201) {
        _showSnackbar("✅ SOS Sent! Volunteers Notified.");
        _sendSMS(); // ✅ Send SMS after successful backend call
        _listenForVolunteerUpdates();
      } else {
        _showSnackbar("❌ Failed to notify volunteers.");
      }
    } catch (e) {
      _showSnackbar("⚠️ Error: Unable to send SOS.");
    }

    setState(() {
      isSendingSOS = false;
    });
  }

  /// ✅ Send SMS to Emergency Contacts with Location
  Future<void> _sendSMS() async {
    if (emergencyContacts.isEmpty) {
      _showSnackbar("⚠️ No emergency contacts found.");
      return;
    }

    if (userLocation == null) return;

    String latitude = userLocation!.latitude.toString();
    String longitude = userLocation!.longitude.toString();

    String message = Uri.encodeComponent(
      "🚨 SOS ALERT! 🚨\nI need immediate help!\n📍 My location:\n"
      "Latitude: $latitude\nLongitude: $longitude\n"
      "🔗 https://www.google.com/maps?q=$latitude,$longitude"
    );

    // ✅ Join all numbers into a single comma-separated string
    String recipients = emergencyContacts.join(',');

    String smsUrl = "sms:$recipients?body=$message";

    if (await canLaunch(smsUrl)) {
      await launch(smsUrl);
    } else {
      _showSnackbar("❌ Failed to launch SMS app.");
    }
  }

  /// ✅ Listen for Volunteer Location Updates via WebSocket
  void _listenForVolunteerUpdates() {
    channel = IOWebSocketChannel.connect("ws://100.64.199.99:3000");
    channel!.stream.listen((message) {
      final data = jsonDecode(message);

      if (data['volunteerLatitude'] != null) {
        setState(() {
          statusMessage = "🚗 Volunteer is on the way!";
          volunteerLocation = LatLng(data['volunteerLatitude'], data['volunteerLongitude']);

          markers.add(
            Marker(
              markerId: MarkerId("volunteer"),
              position: volunteerLocation!,
              infoWindow: InfoWindow(title: "Volunteer"),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            ),
          );

          // ✅ Update the route between volunteer and user
          _updateRoute();
        });
      }
    });
  }

  /// ✅ Update the polyline (route) from volunteer to user
  void _updateRoute() {
    if (userLocation == null || volunteerLocation == null) return;

    setState(() {
      polylines.clear();
      polylines.add(
        Polyline(
          polylineId: PolylineId("route"),
          points: [volunteerLocation!, userLocation!],
          color: Colors.blue,
          width: 5,
        ),
      );
    });
  }

  @override
  void dispose() {
    channel?.sink.close();
    super.dispose();
  }

  /// ✅ Show Snackbar Message
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ✅ Full-Screen Google Map
          userLocation == null
              ? Center(child: CircularProgressIndicator())
              : GoogleMap(
                  initialCameraPosition: CameraPosition(target: userLocation!, zoom: 14),
                  markers: markers,
                  polylines: polylines,
                  myLocationEnabled: true,
                  onMapCreated: (controller) => mapController = controller,
                ),

          // ✅ Status Message at the Top
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Text(statusMessage, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),

          // ✅ SOS Button at Bottom
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: isSendingSOS ? null : _sendSOS,
              style: ElevatedButton.styleFrom(
                backgroundColor: isSendingSOS ? Colors.grey : Colors.red,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(
                isSendingSOS ? "Sending..." : "🚨 Send SOS",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
