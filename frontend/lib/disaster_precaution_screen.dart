import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DisasterPreventionPage extends StatefulWidget {
  const DisasterPreventionPage({super.key});

  @override
  State<DisasterPreventionPage> createState() => _DisasterPreventionPageState();
}

class _DisasterPreventionPageState extends State<DisasterPreventionPage> {
  List<dynamic> disasters = [];
  List<dynamic> filteredDisasters = [];
  String searchQuery = '';

  // ✅ Change this to your actual IP (same as used in Postman or browser)
  final String baseUrl = "http://192.168.1.3:3000"; 

  @override
  void initState() {
    super.initState();
    fetchPrecautions();
  }

  Future<void> fetchPrecautions() async {
    final url = Uri.parse("$baseUrl/api/precautions");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          disasters = data;
          filteredDisasters = data;
        });
      } else {
        print("❌ Failed to load: ${response.body}");
      }
    } catch (e) {
      print("❌ Error fetching precautions: $e");
    }
  }

  void _filter(String query) {
    setState(() {
      searchQuery = query;
      filteredDisasters = disasters
          .where((item) => item['title']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showDetails(BuildContext context, Map<String, dynamic> disaster) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.blue.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(disaster['title'], textAlign: TextAlign.center),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('✅ Precautions Before:', style: sectionTitle),
              const SizedBox(height: 4),
              Text(disaster['precaution']),
              const SizedBox(height: 12),
              Text('🚨 What to Do After:', style: sectionTitle),
              const SizedBox(height: 4),
              Text(disaster['response']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          )
        ],
      ),
    );
  }

  TextStyle get sectionTitle => const TextStyle(fontWeight: FontWeight.bold, fontSize: 16);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Disaster Prevention"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Box
            TextField(
              onChanged: _filter,
              decoration: InputDecoration(
                hintText: "Search disaster...",
                prefixIcon: const Icon(Icons.menu),
                suffixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Grid
            Expanded(
              child: filteredDisasters.isEmpty
                  ? const Center(child: Text("No precautions found"))
                  : GridView.builder(
                      itemCount: filteredDisasters.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                      ),
                      itemBuilder: (context, index) {
                        final disaster = filteredDisasters[index];
                        final imageUrl = "$baseUrl/uploads/${disaster['image']}";

                        return GestureDetector(
                          onTap: () => _showDetails(context, disaster),
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                      image: NetworkImage(imageUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                disaster['title'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
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
