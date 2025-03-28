import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'login.dart'; // ✅ Import Login Screen for Redirect

class AdminDashboard extends StatefulWidget {
  final String token;
  final String userId;

  const AdminDashboard({required this.token, required this.userId, super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  List<dynamic> pendingVolunteers = [];
  List<dynamic> fundraisers = [];
  bool isLoading = true;
  bool isFundraisersLoading = true;
  late TabController _tabController;

  final String baseUrl = "http://192.168.1.9:3000"; // ✅ Change this to your backend URL

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchPendingVolunteers();
    fetchPendingFundraisers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// ✅ Fetch Pending Volunteers
  Future<void> fetchPendingVolunteers() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/volunteers/pending"),
        headers: {"Authorization": "Bearer ${widget.token}"},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == true) {
          setState(() {
            pendingVolunteers = jsonResponse['volunteers'] ?? [];
          });
        }
      }
    } catch (e) {
      print("❌ Error fetching volunteers: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// ✅ Fetch Pending Fundraisers
  Future<void> fetchPendingFundraisers() async {
    setState(() => isFundraisersLoading = true);
    try {
      final dio = Dio();
      final response = await dio.get('$baseUrl/pending-fundraisers');

      if (response.statusCode == 200 && response.data['success']) {
        setState(() {
          fundraisers = response.data['fundraisers'];
        });
      }
    } catch (e) {
      print("❌ Error fetching fundraisers: $e");
    } finally {
      setState(() => isFundraisersLoading = false);
    }
  }

  /// ✅ Approve Volunteer
  Future<void> approveVolunteer(String id) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/api/volunteers/approve/$id"),
        headers: {"Authorization": "Bearer ${widget.token}"},
      );

      if (response.statusCode == 200) {
        setState(() {
          pendingVolunteers.removeWhere((volunteer) => volunteer['_id'] == id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Volunteer approved!")),
        );
      }
    } catch (e) {
      print("❌ Exception in approving volunteer: $e");
    }
  }

  /// ✅ Approve Fundraiser
  Future<void> approveFundraiser(String id) async {
    try {
      final dio = Dio();
      await dio.put('$baseUrl/approve-fundraiser/$id');

      fetchPendingFundraisers();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Fundraiser approved!")),
      );
    } catch (e) {
      print("❌ Exception in approving fundraiser: $e");
    }
  }

  /// ✅ Sign Out (Clears Token & Redirects)
  Future<void> _signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // ✅ Clears stored login data

    if (!mounted) return;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInPage()), // ✅ Redirects to Login Page
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Volunteers"),
            Tab(text: "Fundraisers"),
          ],
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: const Text("Admin Menu", style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
            ListTile(
              title: const Text("Dashboard"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Volunteers"),
              onTap: () {
                _tabController.animateTo(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Fundraisers"),
              onTap: () {
                _tabController.animateTo(1);
                Navigator.pop(context);
              },
            ),
            const Spacer(), // Pushes Sign Out button to bottom
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text("Sign Out"),
              onTap: _signOut,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Volunteers Tab
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Pending Volunteers",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: pendingVolunteers.isNotEmpty
                          ? SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                border: TableBorder.all(),
                                columns: const [
                                  DataColumn(label: Text("Username")),
                                  DataColumn(label: Text("Email")),
                                  DataColumn(label: Text("Phone")),
                                  DataColumn(label: Text("Action")),
                                ],
                                rows: pendingVolunteers.map((volunteer) {
                                  return DataRow(cells: [
                                    DataCell(Text(volunteer['username'] ?? "No Username")),
                                    DataCell(Text(volunteer['email'] ?? "No Email")),
                                    DataCell(Text(volunteer['phone'] ?? "No Phone")),
                                    DataCell(
                                      ElevatedButton(
                                        onPressed: () => approveVolunteer(volunteer['_id']),
                                        child: const Text("Approve"),
                                      ),
                                    ),
                                  ]);
                                }).toList(),
                              ),
                            )
                          : const Center(child: Text("No pending volunteers")),
                    ),
                  ],
                ),

          // Fundraisers Tab
          isFundraisersLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: fundraisers.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(fundraisers[index]['title'] ?? "No Title"),
                        subtitle: Text(fundraisers[index]['description'] ?? "No Description"),
                        trailing: ElevatedButton(
                          onPressed: () => approveFundraiser(fundraisers[index]['_id']),
                          child: const Text('Approve'),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
