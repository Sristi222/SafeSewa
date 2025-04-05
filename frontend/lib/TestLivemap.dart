import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';

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

  final int id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  await flutterLocalNotificationsPlugin.show(
    id,
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
  final LatLng _center = const LatLng(28.3949, 84.1240);
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    setupNotifications();
    fetchDisasterData();
  }

  Future<void> setupNotifications() async {
    await Firebase.initializeApp();

    await FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.instance.subscribeToTopic("disaster_alerts");

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(
  initSettings,
  onDidReceiveNotificationResponse: (NotificationResponse response) async {
    final payload = response.payload;
    print("🔔 Notification tapped. Payload: $payload");
    // Optional: navigate to specific screen
  },
);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notif = message.notification;
      if (notif != null) {
        showLocalNotification(notif.title ?? '⚠️ Alert', notif.body ?? 'Check map');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("🟢 Notification opened from background: ${message.data}");
      // Optional: Navigate to screen or handle payload
    });
  }

  Future<void> fetchDisasterData() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.3:3000/api/disasters'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print("📦 Disaster data received: $data");

        Set<Marker> loadedMarkers = {};
        List<Map<String, dynamic>> earthquakes = [];

        for (var item in data) {
          final location = item['location'];
          final timestampStr = item['timestamp'];

          if (location != null &&
              location['lat'] != null &&
              location['lng'] != null) {
            final type = item['type'] ?? 'Unknown';
            final desc = item['description'] ?? 'No description';

            loadedMarkers.add(
              Marker(
                markerId: MarkerId(item['_id']),
                position: LatLng(location['lat'], location['lng']),
                infoWindow: InfoWindow(
                  title: '⚠️ ${type.toUpperCase()}',
                  snippet: desc,
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed),
              ),
            );

            if (type.toLowerCase() == 'earthquake' && timestampStr != null) {
              earthquakes.add({
                'id': item['_id'],
                'description': desc,
                'timestamp': DateTime.parse(timestampStr).toUtc(),
              });
            }
          }
        }

        earthquakes.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

        if (earthquakes.isNotEmpty) {
          final latest = earthquakes.first;
          await showLocalNotification(
              '⚠️ Earthquake Alert', latest['description']);
          print(
              '✅ Notification shown for latest earthquake: ${latest['description']}');
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

  void triggerFakeAlert() {
    final fakeId = DateTime.now().millisecondsSinceEpoch.toString();
    final fakeLatLng = LatLng(27.7172, 85.3240); // Kathmandu

    final Marker fakeMarker = Marker(
      markerId: MarkerId(fakeId),
      position: fakeLatLng,
      infoWindow: InfoWindow(
        title: '⚠️ EARTHQUAKE',
        snippet: 'Simulated earthquake near Kathmandu',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      _markers.add(fakeMarker);
    });

    showLocalNotification(
      '⚠️ Earthquake Alert',
      'Simulated earthquake near Kathmandu',
    );
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
      floatingActionButton: FloatingActionButton(
        onPressed: triggerFakeAlert,
        child: Icon(Icons.warning),
        backgroundColor: Colors.red,
        tooltip: 'Simulate Earthquake Alert',
      ),
    );
  }
}
