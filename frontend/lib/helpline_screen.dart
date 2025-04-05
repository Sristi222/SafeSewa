import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class HelplinePage extends StatefulWidget {
  @override
  _HelplinePageState createState() => _HelplinePageState();
}

class _HelplinePageState extends State<HelplinePage> {
  List<dynamic> helplines = [];
  List<dynamic> filtered = [];
  String searchQuery = '';

  final String apiUrl = 'http://192.168.1.3:3000/api/helplines'; // ⚠️ Update this

  @override
  void initState() {
    super.initState();
    fetchHelplines();
  }

  Future<void> fetchHelplines() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          helplines = data;
          filtered = data;
        });
      } else {
        print("⚠️ Failed to load helplines");
      }
    } catch (e) {
      print("❌ Error fetching helplines: $e");
    }
  }

  void _filterNumbers(String query) {
    setState(() {
      searchQuery = query;
      filtered = helplines
          .where((item) =>
              item['title'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _makePhoneCall(String number) async {
    final Uri url = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $number';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Emergency Helpline Numbers'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Important Contacts",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search by service name...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: _filterNumbers,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text("No matches found."))
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
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
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            leading: const Icon(Icons.local_phone, color: Colors.deepPurple),
                            title: Text(
                              item['title'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(item['number'] ?? ''),
                            trailing: IconButton(
                              icon: const Icon(Icons.call, color: Colors.green),
                              onPressed: () => _makePhoneCall(item['number']),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
