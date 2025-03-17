import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'volunteerscreen.dart';
import 'login.dart'; // ✅ Import Login Screen

class VolunteerDashboard extends StatefulWidget {
  final String token;
  final String userId;

  const VolunteerDashboard({Key? key, required this.token, required this.userId}) : super(key: key);

  @override
  _VolunteerDashboardState createState() => _VolunteerDashboardState();
}

class _VolunteerDashboardState extends State<VolunteerDashboard> {
  int _selectedIndex = 0;

  static List<Widget> _pages = <Widget>[
    Center(
      child: Text(
        "Hi, Volunteer!",
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    ),
    VolunteerScreen(), // ✅ Navigate to SOS Alerts
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// ✅ Logout Function (Clears SharedPreferences & Navigates to Login)
  Future<void> _signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // ✅ Clear stored user data
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInPage()), // ✅ Redirect to Login
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
            onPressed: _signOut, // ✅ Calls sign-out function
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.warning, color: Colors.red), label: "SOS Alerts"),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
