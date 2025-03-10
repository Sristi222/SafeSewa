import 'package:flutter/material.dart';
import 'notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_page.dart';
import 'config.dart';
import 'feed_screen.dart';
import 'sos_screen.dart';
import 'add_emergency_contact.dart'; // ✅ Import AddEmergencyContact
import '../services/api_service.dart';
import 'fundraiser_screen.dart'; // ✅ Import FundraiserScreen
import './fundraiser_form_screen.dart'; // ✅ Import DonationScreen
import './map_screen.dart'; // ✅ Import Map Screen

class Dashboard extends StatefulWidget {
  final String token;

  const Dashboard({super.key, required this.token, required String userId});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<String> emergencyContacts = [];
  List<dynamic> alerts = [];
  int _selectedIndex = 0;
  String? username;
  int floodAlertCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchContacts();
    _fetchAlerts();
  }

  /// Fetch saved emergency contacts from API
  Future<void> _fetchContacts() async {
    final contacts = await ApiServices.fetchEmergencyContacts();
    setState(() {
      emergencyContacts =
          contacts.map((c) => "${c['name']} (${c['phone']})").toList();
    });
  }

  /// Fetch flood alerts
  Future<void> _fetchAlerts() async {
    final data = await ApiService.fetchFloodAlerts();
    setState(() {
      alerts = data;
      floodAlertCount =
          alerts.where((alert) => alert['status'] == 'Flood Alert!').length;
    });
  }

  /// Load user data from local storage
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Guest';
    });
  }

  /// Handle bottom navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 2:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SOSScreen()));
        break;
      case 3:
        Navigator.push(context,
                MaterialPageRoute(builder: (context) => ProfileScreen()))
            .then((_) => _fetchContacts()); // Refresh contacts after adding
        break;
      case 4:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => FeedScreen()));
        break;
      case 5:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    FundraiserFormScreen())); // ✅ Navigate to Fundraiser
        break;
      case 6:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    FundraiserScreen())); // ✅ Navigate to Donation
        break;
      case 7:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    MapScreen())); // ✅ Navigate to Map
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
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
          IconButton(
            icon: const Icon(Icons.account_circle, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // **Emergency Contacts Section**
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Emergency Contacts",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            emergencyContacts.isEmpty
                ? const Center(child: Text("No emergency contacts added."))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: emergencyContacts.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.contact_phone),
                        title: Text(emergencyContacts[index]),
                      );
                    },
                  ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfileScreen())).then(
                    (_) => _fetchContacts()); // Refresh contacts after adding
              },
              child: const Text("Add Emergency Contact"),
            ),
            const SizedBox(height: 20),

            // **Flood Alerts Section**
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Recent Alerts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            // **Items Section**
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("Items",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              children: List.generate(5, (index) {
                return Container(
                  margin: const EdgeInsets.all(8),
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(child: Icon(Icons.image, size: 40)),
                );
              }),
            ),

            // **Map Section**
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Text("Live Map",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapScreen()),
                );
              },
              child: Container(
                margin: const EdgeInsets.all(16),
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[300],
                ),
                child: const Center(
                  child: Icon(Icons.map, size: 50, color: Colors.blueGrey),
                ),
              ),
            ),
          ],
        ),
      ),

      // **Bottom Navigation Bar**
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Alerts'),
          BottomNavigationBarItem(
              icon: Icon(Icons.sos, color: Colors.red), label: 'SOS'),
          BottomNavigationBarItem(
              icon: Icon(Icons.contact_phone), label: 'Contacts'),
          BottomNavigationBarItem(icon: Icon(Icons.feed), label: 'Feed'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Fundraisers'),
          BottomNavigationBarItem(
              icon: Icon(Icons.volunteer_activism), label: 'Donations'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'), // ✅ Map
        ],
      ),
    );
  }
}

/// **Alert List Screen**
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
                color: alert['status'] == 'Flood Alert!' ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }
}
