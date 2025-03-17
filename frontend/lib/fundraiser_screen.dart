import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'donation_screen.dart'; // ✅ Import Donation Screen
import 'fundraiser_form_screen.dart';

class FundraiserScreen extends StatefulWidget {
  @override
  _FundraiserScreenState createState() => _FundraiserScreenState();
}

class _FundraiserScreenState extends State<FundraiserScreen> {
  List<dynamic> fundraisers = [];
  bool isLoading = true;
  String errorMessage = ''; // Holds error messages if any
  final String backendUrl = "http://192.168.1.4:3000"; // ✅ Update to match your backend

  @override
  void initState() {
    super.initState();
    fetchFundraisers();
  }

  // ✅ Fetch approved fundraisers
  Future<void> fetchFundraisers() async {
    setState(() {
      isLoading = true;
      errorMessage = ''; // Reset any previous error message
    });

    try {
      Response response = await Dio().get('$backendUrl/approved-fundraisers');

      if (response.statusCode == 200) {
        setState(() {
          fundraisers = response.data ?? []; // Ensure it's a list
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "❌ Failed to load fundraisers. Status: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Error fetching fundraisers: $e");
      setState(() {
        errorMessage = "❌ Network Error: Unable to fetch fundraisers!";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fundraisers')),
      body: RefreshIndicator(
        onRefresh: fetchFundraisers, // ✅ Enables pull-to-refresh
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(errorMessage, style: TextStyle(color: Colors.red, fontSize: 16)),
                    ),
                  )
                : fundraisers.isEmpty
                    ? Center(child: Text("🚀 No fundraisers available"))
                    : ListView.builder(
                        itemCount: fundraisers.length,
                        itemBuilder: (context, index) {
                          final fundraiser = fundraisers[index];
                          return Card(
                            elevation: 2,
                            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: ListTile(
                              leading: Icon(Icons.volunteer_activism, color: Colors.blue),
                              title: Text(
                                fundraiser['title'] ?? "No Title",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Goal: NPR ${fundraiser['goalAmount'] ?? "Unknown"}',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              trailing: Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DonationScreen(
                                      fundraiserId: fundraiser['_id'] ?? '',
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FundraiserFormScreen()),
          );
        },
      ),
    );
  }
}
