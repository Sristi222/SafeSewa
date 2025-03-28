import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'volunteerscreen.dart';
import 'login.dart';
import 'event_screen.dart';
import 'eventdetails_screen.dart';
import 'recentevents_screen.dart';

class VolunteerDashboard extends StatefulWidget {
  final String token;
  final String userId;

  const VolunteerDashboard(
      {Key? key, required this.token, required this.userId})
      : super(key: key);

  @override
  _VolunteerDashboardState createState() => _VolunteerDashboardState();
}

class _VolunteerDashboardState extends State<VolunteerDashboard> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      Center(
        child: Text(
          "Hi, Volunteer!",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      HomeFeedScreen(userId: widget.userId), // 🟦 All Events
      RecentEventsScreen(userId: widget.userId), // 🟩 Enrolled Events
      VolunteerScreen(), // 🔴 SOS Alerts
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// ✅ Logout Function (Clears SharedPreferences & Navigates to Login)
  Future<void> _signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Volunteer Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _signOut,
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Events"),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: "My Events"),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: "SOS"),
        ],
      ),
    );
  }
}
