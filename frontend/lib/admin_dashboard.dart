import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import "config.dart";

class AdminDashboard extends StatefulWidget {
  final String token;
  final String userId;

  const AdminDashboard({required this.token, required this.userId, super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<dynamic> pendingVolunteers = [];
  bool isLoading = true;

  final String baseUrl = "http://192.168.1.7:3000"; // ✅ Updated localhost URL

  @override
  void initState() {
    super.initState();
    fetchPendingVolunteers();
  }

  Future<void> fetchPendingVolunteers() async {
  setState(() => isLoading = true);
  try {
    final response = await http.get(
      Uri.parse("$baseUrl/api/volunteers/pending"),
      headers: {"Authorization": "Bearer ${widget.token}"},
    );

    print("📡 API Response Status: ${response.statusCode}");
    print("📡 API Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (jsonResponse['status'] == true) {
        print("✅ Admin received ${jsonResponse['volunteers'].length} pending volunteers.");
        setState(() {
          pendingVolunteers = jsonResponse['volunteers'] ?? [];
        });
      } else {
        print("⚠️ API returned false status: ${jsonResponse['error']}");
      }
    } else {
      print("❌ Failed to fetch volunteers: ${response.statusCode}");
    }
  } catch (e) {
    print("❌ Error fetching volunteers: $e");
  } finally {
    setState(() => isLoading = false);
  }
}


Future<void> approveVolunteer(String id) async {
  try {
    final response = await http.put(
      Uri.parse("$baseUrl/api/volunteers/approve/$id"),
      headers: {"Authorization": "Bearer ${widget.token}"},
    );

    print("📡 API Response Status: ${response.statusCode}");
    print("📡 API Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == true) {
        print("✅ Volunteer approved!");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Volunteer approved!")),
        );
        setState(() {
          pendingVolunteers.removeWhere((volunteer) => volunteer['_id'] == id);
        });
      } else {
        print("⚠️ API returned false status: ${jsonResponse['error']}");
      }
    } else {
      print("❌ Error approving volunteer: ${response.statusCode}");
    }
  } catch (e) {
    print("❌ Exception in approving volunteer: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text("Admin Menu", style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
            ListTile(
              title: const Text("Dashboard"),
              onTap: () {},
            ),
            ListTile(
              title: const Text("Volunteers"),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: isLoading
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
                          child: SingleChildScrollView(
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
                                  DataCell(Text(volunteer['username'])),
                                  DataCell(Text(volunteer['email'])),
                                  DataCell(Text(volunteer['phone'] ?? "N/A")),
                                  DataCell(
                                    ElevatedButton(
                                      onPressed: () => approveVolunteer(volunteer['_id']),
                                      child: const Text("Approve"),
                                    ),
                                  ),
                                ]);
                              }).toList(),
                            ),
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
    );
  }
}
