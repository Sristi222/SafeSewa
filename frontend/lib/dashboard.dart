import 'package:flutter/material.dart';
import 'notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_page.dart';
import 'config.dart';
import 'feed_screen.dart';
import 'sos_screen.dart';
import 'add_emergency_contact.dart';
import '../services/api_service.dart';
import 'fundraiser_screen.dart';
import './fundraiser_form_screen.dart';
import './disaster_map.dart';
import './helpline_screen.dart';
import './earthquakemap_screen.dart';
import './disaster_precaution_screen.dart';
import './TestLivemap.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class Dashboard extends StatefulWidget {
  final String token;
  final String userId;

  const Dashboard({super.key, required this.token, required this.userId});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<String> emergencyContacts = [];
  List<dynamic> alerts = [];
  int _selectedIndex = 0;
  String? username;
  int floodAlertCount = 0;

  String city = '';
  String description = '';
  double temperature = 0;
  String icon = '';
  bool isLoadingWeather = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchContacts();
    _fetchAlerts();
    _fetchWeather();
  }

  Future<void> _fetchContacts() async {
    final contacts = await ApiServices.fetchEmergencyContacts();
    setState(() {
      emergencyContacts =
          contacts.map((c) => "${c['name']} (${c['phone']})").toList();
    });
  }

  Future<void> _fetchAlerts() async {
    final data = await ApiService.fetchFloodAlerts();
    setState(() {
      alerts = data;
      floodAlertCount =
          alerts.where((alert) => alert['status'] == 'Flood Alert!').length;
    });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Guest';
    });
  }

  Future<void> _fetchWeather() async {
    try {
      final response =
          await http.get(Uri.parse('http://100.64.199.99:3000/api/weather'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          city = data['city'];
          description = data['description'];
          temperature = data['temp'];
          icon = data['icon'];
          isLoadingWeather = false;
        });
      } else {
        print("Failed to fetch weather");
      }
    } catch (e) {
      print("Error fetching weather: $e");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 2:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SOSScreen(userId: widget.userId)));
        break;
      case 3:
        Navigator.push(context,
                MaterialPageRoute(builder: (context) => ProfileScreen()))
            .then((_) => _fetchContacts());
        break;
      case 4:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => FeedScreen()));
        break;
      case 5:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => FundraiserFormScreen()));
        break;
      case 6:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => FundraiserScreen()));
        break;
      case 7:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HelplinePage()));
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
                        builder: (context) => AlertListScreen(alerts: alerts)),
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
                )
            ],
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, size: 30),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfilePage()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              isLoadingWeather
                  ? Center(child: CircularProgressIndicator())
                  : Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.lightBlueAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Image.network(
                            'https://openweathermap.org/img/wn/$icon@2x.png',
                            width: 50,
                            height: 50,
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("$temperature°C in $city",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              Text(description,
                                  style:
                                      const TextStyle(color: Colors.white70)),
                            ],
                          )
                        ],
                      ),
                    ),
              const SizedBox(height: 25),
              const Text("Items",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _buildItemTile(Icons.favorite, "Donations", () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => FundraiserScreen()));
                  }),
                  _buildItemTile(Icons.feed, "Feed", () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => FeedScreen()));
                  }),
                  _buildItemTile(Icons.map, "SOS Map", () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => LiveAlertMapScreen()));
                  }),
                  _buildItemTile(Icons.contact_phone, "Contacts", () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => ProfileScreen()));
                  }),
                  _buildItemTile(Icons.warning, "Alerts", () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => AlertListScreen(alerts: alerts)));
                  }),
                  _buildItemTile(Icons.add_alert, "Add SOS", () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => SOSScreen(userId: widget.userId)));
                  }),
                  _buildItemTile(Icons.add_alert, "Disaster Precaution", () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const DisasterPreventionPage()));
                  }),
                  _buildItemTile(Icons.add_alert, "Live Dashboard", () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => DisasterMapScreen()));
                  }),
                  _buildItemTile(Icons.add_alert, "Live Dashboard", () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => DisasterMapScreenn()));
                  }),
                ],
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
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
          BottomNavigationBarItem(
              icon: Icon(Icons.volunteer_activism), label: 'Helpline'),
        ],
      ),
    );
  }
}

Widget _buildItemTile(IconData icon, String label, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: Colors.deepPurple),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    ),
  );
}

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
