import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import "config.dart";

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

  final String baseUrl = "http://192.168.1.8:3000"; // ✅ Updated localhost URL
  final String fundraiserBaseUrl = "http://192.168.1.8:3000"; // Fundraiser API URL

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

  Future<void> fetchPendingFundraisers() async {
  setState(() => isFundraisersLoading = true);
  try {
    final dio = Dio();
    final response = await dio.get('$fundraiserBaseUrl/pending-fundraisers');

    print("📡 Fetching Pending Fundraisers...");
    print("📡 API Response: ${response.statusCode} - ${response.data}");

    if (response.statusCode == 200 && response.data['success']) {
      print("✅ Fundraisers received: ${response.data['fundraisers'].length}");
      setState(() {
        fundraisers = response.data['fundraisers'];
      });
    } else {
      print("⚠️ API returned false: ${response.data['message']}");
    }
  } catch (e) {
    print("❌ Error fetching fundraisers: $e");
  } finally {
    setState(() => isFundraisersLoading = false);
  }
}


  Future<void> approveVolunteer(String id) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/api/volunteers/approve/$id"),
        headers: {"Authorization": "Bearer ${widget.token}"},
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Volunteer approved!")),
          );
          setState(() {
            pendingVolunteers.removeWhere((volunteer) => volunteer['_id'] == id);
          });
        }
      }
    } catch (e) {
      print("❌ Exception in approving volunteer: $e");
    }
  }

  Future<void> approveFundraiser(String id) async {
    try {
      final dio = Dio();
      await dio.put('$fundraiserBaseUrl/approve-fundraiser/$id');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Fundraiser approved!")),
      );

      fetchPendingFundraisers();
    } catch (e) {
      print("❌ Exception in approving fundraiser: $e");
    }
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
                          : const Center(
                              child: Text(
                                "No pending volunteers",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                    ),
                  ],
                ),

          // Fundraisers Tab
          isFundraisersLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Pending Fundraisers",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: fundraisers.isNotEmpty
                          ? ListView.builder(
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
                            )
                          : const Center(
                              child: Text(
                                "No pending fundraisers",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
