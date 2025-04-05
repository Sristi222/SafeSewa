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
  bool isLoadingContacts = true;
  bool isLoadingAlerts = true;
  
  // Define our blue color scheme (matching the other screens)
  final Color primaryBlue = const Color(0xFF2196F3);
  final Color lightBlue = const Color(0xFFBBDEFB);
  final Color darkBlue = const Color(0xFF1565C0);
  final Color accentBlue = const Color(0xFF03A9F4);

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchContacts();
    _fetchAlerts();
    _fetchWeather();
  }

  Future<void> _fetchContacts() async {
    setState(() => isLoadingContacts = true);
    try {
      final contacts = await ApiServices.fetchEmergencyContacts();
      setState(() {
        emergencyContacts = contacts.map((c) => "${c['name']} (${c['phone']})").toList();
        isLoadingContacts = false;
      });
    } catch (e) {
      setState(() => isLoadingContacts = false);
      _showErrorSnackBar("Error loading contacts: $e");
    }
  }

  Future<void> _fetchAlerts() async {
    setState(() => isLoadingAlerts = true);
    try {
      final data = await ApiService.fetchFloodAlerts();
      setState(() {
        alerts = data;
        floodAlertCount = alerts.where((alert) => alert['status'] == 'Flood Alert!').length;
        isLoadingAlerts = false;
      });
    } catch (e) {
      setState(() => isLoadingAlerts = false);
      _showErrorSnackBar("Error loading alerts: $e");
    }
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        username = prefs.getString('username') ?? 'Guest';
      });
    } catch (e) {
      _showErrorSnackBar("Error loading user data: $e");
    }
  }

  Future<void> _fetchWeather() async {
    setState(() => isLoadingWeather = true);
    try {
      final response = await http.get(Uri.parse('http://192.168.1.3:3000/api/weather'));
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
        setState(() => isLoadingWeather = false);
        _showErrorSnackBar("Failed to fetch weather: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => isLoadingWeather = false);
      _showErrorSnackBar("Error fetching weather: $e");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfileScreen()))
            .then((_) => _fetchContacts());
        break;
      case 4:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => FeedScreen()));
        break;
      case 5:
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FundraiserFormScreen()));
        break;
      case 6:
        Navigator.push(
            context,
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBlue,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, size: 26),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AlertListScreen(
                          alerts: alerts,
                          primaryBlue: primaryBlue,
                          lightBlue: lightBlue,
                          darkBlue: darkBlue,
                        )),
                  );
                },
              ),
              if (floodAlertCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        '$floodAlertCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
            ],
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, size: 26),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfilePage()));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: primaryBlue,
        onRefresh: () async {
          await Future.wait([
            _fetchWeather(),
            _fetchAlerts(),
            _fetchContacts(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome section
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: lightBlue.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.waving_hand, color: darkBlue, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Welcome back, ${username ?? 'Guest'}!",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: darkBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Weather widget
                _buildWeatherWidget(),
                const SizedBox(height: 24),
                
                // Alert summary
                if (!isLoadingAlerts && floodAlertCount > 0)
                  _buildAlertSummary(),
                
                const SizedBox(height: 24),
                
                // Menu items section
                Row(
                  children: [
                    Icon(Icons.grid_view, size: 20, color: darkBlue),
                    const SizedBox(width: 8),
                    Text(
                      "Quick Actions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Grid items
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildItemTile(Icons.favorite, "Donations", () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => FundraiserScreen()));
                    }, primaryBlue),
                    _buildItemTile(Icons.feed, "Feed", () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => FeedScreen()));
                    }, primaryBlue),
                    _buildItemTile(Icons.map, "SOS Map", () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => LiveAlertMapScreen()));
                    }, primaryBlue),
                    _buildItemTile(Icons.contact_phone, "Contacts", () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => ProfileScreen()));
                    }, primaryBlue),
                    _buildItemTile(Icons.warning, "Alerts", () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => AlertListScreen(
                                alerts: alerts,
                                primaryBlue: primaryBlue,
                                lightBlue: lightBlue,
                                darkBlue: darkBlue,
                              )));
                    }, primaryBlue),
                    _buildItemTile(Icons.add_alert, "Add SOS", () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => SOSScreen(userId: widget.userId)));
                    }, Colors.red),
                    _buildItemTile(Icons.health_and_safety, "Disaster Precaution", () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const DisasterPreventionPage()));
                    }, primaryBlue),
                    _buildItemTile(Icons.dashboard, "Live Dashboard", () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => DisasterMapScreen()));
                    }, primaryBlue),
                    _buildItemTile(Icons.public, "Earthquake Map", () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => DisasterMapScreenn()));
                    }, primaryBlue),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Emergency contacts section
                if (emergencyContacts.isNotEmpty) _buildEmergencyContactsSection(),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        elevation: 8,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
          BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.sos, color: Colors.white, size: 20),
              ), 
              label: 'SOS'
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.contact_phone), label: 'Contacts'),
          const BottomNavigationBarItem(icon: Icon(Icons.feed), label: 'Feed'),
          const BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Fundraisers'),
          const BottomNavigationBarItem(icon: Icon(Icons.volunteer_activism), label: 'Donations'),
          const BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: 'Helpline'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SOSScreen(userId: widget.userId)),
          );
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.sos, color: Colors.white),
      ),
    );
  }

  Widget _buildWeatherWidget() {
    if (isLoadingWeather) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryBlue, accentBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Loading weather...",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlue, accentBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.network(
              'https://openweathermap.org/img/wn/$icon@2x.png',
              width: 60,
              height: 60,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.cloud,
                size: 60,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$temperature°C",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  city,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: Colors.red.shade700,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$floodAlertCount Active Flood Alert${floodAlertCount > 1 ? 's' : ''}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.red.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Tap to view details and safety information",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.red.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.contact_phone, size: 20, color: darkBlue),
                const SizedBox(width: 8),
                Text(
                  "Emergency Contacts",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkBlue,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()));
              },
              style: TextButton.styleFrom(
                foregroundColor: primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text("Manage"),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: isLoadingContacts
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: emergencyContacts.length > 3 ? 3 : emergencyContacts.length,
                  separatorBuilder: (context, index) => Divider(
                    color: Colors.grey.shade200,
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: lightBlue,
                        child: Icon(
                          Icons.person,
                          color: primaryBlue,
                        ),
                      ),
                      title: Text(
                        emergencyContacts[index].split(' (')[0],
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        emergencyContacts[index].split(' (')[1].replaceAll(')', ''),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.phone, color: primaryBlue),
                        onPressed: () {
                          // Call functionality would go here
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

Widget _buildItemTile(IconData icon, String label, VoidCallback onTap, Color color) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class AlertListScreen extends StatelessWidget {
  final List<dynamic> alerts;
  final Color primaryBlue;
  final Color lightBlue;
  final Color darkBlue;
  
  const AlertListScreen({
    super.key, 
    required this.alerts,
    required this.primaryBlue,
    required this.lightBlue,
    required this.darkBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Flood Alerts',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBlue,
        elevation: 0,
      ),
      body: alerts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.water_drop,
                    size: 80,
                    color: lightBlue,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No Flood Alerts",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: darkBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "All monitoring stations are reporting normal water levels",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                final bool isAlertActive = alert['status'] == 'Flood Alert!';
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isAlertActive ? Colors.red.shade200 : Colors.green.shade200,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isAlertActive ? Colors.red.shade100 : Colors.green.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isAlertActive ? Icons.warning_amber_rounded : Icons.check_circle,
                                color: isAlertActive ? Colors.red : Colors.green,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    alert['stationName'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isAlertActive ? "Flooding Risk" : "Normal Status",
                                    style: TextStyle(
                                      color: isAlertActive ? Colors.red : Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildAlertInfoItem(
                                "Water Level",
                                "${alert['waterLevel']} m",
                                Icons.water,
                                isAlertActive ? Colors.red.shade700 : primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildAlertInfoItem(
                                "Status",
                                alert['status'],
                                isAlertActive ? Icons.warning : Icons.check_circle,
                                isAlertActive ? Colors.red : Colors.green,
                              ),
                            ),
                          ],
                        ),
                        if (isAlertActive) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade100),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.red.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Stay alert and follow safety guidelines. Avoid low-lying areas.",
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
  
  Widget _buildAlertInfoItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}