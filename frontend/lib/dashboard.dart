import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification.dart';
import 'config.dart';

class Dashboard extends StatefulWidget {
  final String token;

  const Dashboard({super.key, required this.token});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final List<String> notifications = []; // List to store notifications
  List<dynamic> alerts = []; // List to store flood alerts
  int floodAlertCount = 0; // Counter for flood alerts
  late NotificationService notificationService;

  @override
  void initState() {
    super.initState();
    // Initialize the notification service
    notificationService = NotificationService();
    notificationService.initializeLocalNotifications();
    notificationService.subscribeToFloodAlerts(onNewNotification: (title, body) {
      setState(() {
        notifications.add("$title: $body");
      });
    });
    _fetchAlerts(); // Fetch flood alerts
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
                  // Navigate to the alert list screen
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner Section
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 150,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/rescuer_banner.jpg'), // Add the appropriate image
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: Container(
                    color: Colors.blue.withOpacity(0.8),
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Stay Alert, Stay Safe',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Get real-time flood alerts and rescue updates',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Quick Actions Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 6, // Number of actions
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemBuilder: (context, index) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.contact_phone), // Placeholder icon
                    onPressed: () {
                      // Handle button actions
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Recent Alerts Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Text(
                'Recent Alerts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: alerts.length, // Number of recent alerts
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
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
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.sos, color: Colors.red), label: 'SOS'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Info'),
          BottomNavigationBarItem(icon: Icon(Icons.volunteer_activism), label: 'Donation'),
        ],
        onTap: (index) {
          // Handle navigation actions
        },
      ),
    );
  }
}

// Alert List Screen
class AlertListScreen extends StatelessWidget {
  final List<dynamic> alerts; // List of alerts
  const AlertListScreen({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flood Alerts')),
      body: ListView.builder(
        itemCount: alerts.length, // Number of alerts
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
