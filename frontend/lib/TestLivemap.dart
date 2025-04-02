import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> showLocalNotification(String title, String body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'disaster_channel',
    'Disaster Alerts',
    channelDescription: 'Channel for disaster alert notifications',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
    payload: 'default',
  );
}

class DisasterMapScreenn extends StatefulWidget {
  @override
  _DisasterMapScreenState createState() => _DisasterMapScreenState();
}

class _DisasterMapScreenState extends State<DisasterMapScreenn> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(28.3949, 84.1240); // Nepal center
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    initializeLocalNotifications();
    fetchDisasterData();
  }

  Future<void> initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> fetchDisasterData() async {
    try {
      final response = await http.get(
        Uri.parse('http://100.64.199.99:3000/api/disasters'), // Corrected URL
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print("📦 Disaster data received: $data");

        Set<Marker> loadedMarkers = {};

        for (var item in data) {
          final location = item['location'];
          if (location != null && location['lat'] != null && location['lng'] != null) {
            final type = item['type'] ?? 'Unknown';
            final desc = item['description'] ?? 'No description';

            if (type.toLowerCase() == 'earthquake') {
              showLocalNotification('⚠️ Earthquake Alert', desc);
            }

            loadedMarkers.add(
              Marker(
                markerId: MarkerId(item['_id']),
                position: LatLng(location['lat'], location['lng']),
                infoWindow: InfoWindow(
                  title: '⚠️ ${type.toString().toUpperCase()}',
                  snippet: desc,
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              ),
            );
          }
        }

        setState(() {
          _markers = loadedMarkers;
        });
      } else {
        print("❌ Failed to load disaster data: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching disaster data: $e");
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Live Disaster Map')),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 6,
        ),
        markers: _markers,
      ),
    );
  }
}
