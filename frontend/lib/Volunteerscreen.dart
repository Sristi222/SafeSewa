import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VolunteerScreen extends StatefulWidget {
  @override
  _VolunteerScreenState createState() => _VolunteerScreenState();
}

class _VolunteerScreenState extends State<VolunteerScreen> {
  late IOWebSocketChannel channel;
  List<Map<String, dynamic>> sosAlerts = [];
  bool isConnected = false;
  final String backendUrl = "http://192.168.1.4:3000"; // ✅ Change this to your backend URL

  @override
  void initState() {
    super.initState();
    _fetchInitialAlerts(); // ✅ Fetch existing alerts on load
    _connectToWebSocket();
  }

  /// ✅ Fetch existing SOS alerts from the database
  Future<void> _fetchInitialAlerts() async {
    try {
      final response = await http.get(Uri.parse("$backendUrl/api/sos-alerts"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            sosAlerts = List<Map<String, dynamic>>.from(data['sosAlerts']);
          });
        }
      } else {
        print("❌ Failed to fetch alerts: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching SOS alerts: $e");
    }
  }

  /// ✅ Connect to WebSocket for live updates
  void _connectToWebSocket() {
    try {
      channel = IOWebSocketChannel.connect("ws://192.168.1.4:3000");
      setState(() => isConnected = true);

      channel.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message);
            if (mounted) {
              setState(() {
                sosAlerts.insert(0, data); // Add new alerts at the top
              });
            }
          } catch (e) {
            print("❌ Error decoding message: $e");
          }
        },
        onError: (error) {
          print("❌ WebSocket Error: $error");
          setState(() => isConnected = false);
          _reconnectWebSocket();
        },
        onDone: () {
          print("🔌 WebSocket Disconnected");
          setState(() => isConnected = false);
          _reconnectWebSocket();
        },
      );
    } catch (e) {
      print("❌ Error connecting to WebSocket: $e");
      setState(() => isConnected = false);
      _reconnectWebSocket();
    }
  }

  /// ✅ Auto-reconnect WebSocket if disconnected
  void _reconnectWebSocket() {
    Future.delayed(Duration(seconds: 5), () {
      if (!isConnected) {
        print("🔄 Attempting to reconnect...");
        _connectToWebSocket();
      }
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  /// ✅ Open SOS Location in Google Maps
  void _openGoogleMaps(double latitude, double longitude) async {
    final googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open Google Maps")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Volunteer SOS Alerts"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchInitialAlerts, // ✅ Refresh alerts manually
          ),
          isConnected
              ? Icon(Icons.wifi, color: Colors.green)
              : Icon(Icons.wifi_off, color: Colors.red),
          SizedBox(width: 10),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchInitialAlerts, // ✅ Pull down to refresh alerts
        child: sosAlerts.isEmpty
            ? Center(child: Text("No SOS Alerts Yet"))
            : ListView.builder(
                itemCount: sosAlerts.length,
                itemBuilder: (context, index) {
                  final alert = sosAlerts[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      leading: Icon(Icons.warning, color: Colors.red),
                      title: Text("🚨 SOS from User ${alert['userId']}"),
                      subtitle: Text("📍 Location: ${alert['latitude']}, ${alert['longitude']}"),
                      trailing: IconButton(
                        icon: Icon(Icons.map, color: Colors.blue),
                        onPressed: () => _openGoogleMaps(alert['latitude'], alert['longitude']),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
