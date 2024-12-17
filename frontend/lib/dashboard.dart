import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'config.dart';

class Dashboard extends StatefulWidget {
  final String token;

  const Dashboard({super.key, required this.token});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final List<String> notifications = []; // List to store notifications
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  List<dynamic> alerts = [];
  int floodAlertCount = 0;

  @override
  void initState() {
    super.initState();
    initializeLocalNotifications();
    subscribeToFloodAlerts();
    _fetchAlerts();
  }

  // Initialize Flutter Local Notifications
  void initializeLocalNotifications() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Subscribe to the flood-alerts topic and handle incoming notifications
  void subscribeToFloodAlerts() {
    FirebaseMessaging.instance.subscribeToTopic('flood-alerts');
    print("Subscribed to flood-alerts topic");

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final String? title = message.notification?.title;
      final String? body = message.notification?.body;

      if (title != null && body != null) {
        setState(() {
          notifications.add("$title: $body");
        });
        showLocalNotification(title, body);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification clicked: ${message.notification?.title}");
    });
  }

  // Show local notification
  void showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'flood_alerts', // Channel ID
      'Flood Alerts', // Channel Name
      channelDescription: 'Notifications for flood alerts',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      title.hashCode, // Unique ID
      title,
      body,
      details,
    );
  }

  // Fetch flood alerts from backend
  Future<void> _fetchAlerts() async {
    final data = await ApiService.fetchFloodAlerts();
    setState(() {
      alerts = data;
      floodAlertCount =
          alerts.where((alert) => alert['status'] == 'Flood Alert!').length;
    });
  }

  // Function to display notifications list
  void _showNotificationsList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                "Notifications",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            if (notifications.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("No notifications yet!"),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.notifications_active, color: Colors.blue),
                      title: Text(notifications[index]),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          // Notification Icon with Badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, size: 30),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AlertListScreen(alerts: alerts),
                    ),
                  );
                },
              ),
              if (floodAlertCount > 0)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$floodAlertCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome to the Dashboard!\nToken: ${widget.token}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: _fetchAlerts, // Refresh button
              child: const Text('Refresh Alerts'),
            ),
          ],
        ),
      ),
    );
  }
}

// Alert List Screen
class AlertListScreen extends StatelessWidget {
  final List<dynamic> alerts;
  const AlertListScreen({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flood Alerts')),
      body: ListView.builder(
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final alert = alerts[index];
          return ListTile(
            title: Text(alert['stationName']),
            subtitle: Text('Water Level: ${alert['waterLevel']}'),
            trailing: Text(
              alert['status'],
              style: TextStyle(
                color: alert['status'] == 'Flood Alert!'
                    ? Colors.red
                    : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }
}
