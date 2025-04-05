import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart'; // ✅ For number formatting
import 'donation_screen.dart';
import 'fundraiser_form_screen.dart';

class FundraiserScreen extends StatefulWidget {
  @override
  _FundraiserScreenState createState() => _FundraiserScreenState();
}

class _FundraiserScreenState extends State<FundraiserScreen> {
  List<dynamic> fundraisers = [];
  bool isLoading = true;
  String errorMessage = '';
  final String backendUrl = "http://192.168.1.3:3000";

  @override
  void initState() {
    super.initState();
    fetchFundraisers();
  }

  Future<void> fetchFundraisers() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      Response response = await Dio().get('$backendUrl/approved-fundraisers');

      if (response.statusCode == 200) {
        setState(() {
          fundraisers = response.data ?? [];
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

  final formatter = NumberFormat('#,##0', 'en_US');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fundraisers')),
      body: RefreshIndicator(
        onRefresh: fetchFundraisers,
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
                          final title = fundraiser['title'] ?? 'No Title';
                          final goal = fundraiser['goalAmount'] ?? 0;
                          final raised = fundraiser['raisedAmount'] ?? 0;
                          final usage = fundraiser['usagePlan'] ?? "No breakdown provided.";

                          double progress = goal > 0 ? (raised / goal).clamp(0.0, 1.0) : 0.0;

                          return Card(
                            elevation: 4,
                            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.volunteer_activism, color: Colors.blue),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(title,
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      ),
                                      Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 10,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Raised NPR ${formatter.format(raised)} of ${formatter.format(goal)}',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "📌 Usage: $usage",
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                  SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => DonationScreen(
                                              fundraiserId: fundraiser['_id'],
                                            ),
                                          ),
                                        );
                                        fetchFundraisers(); // ✅ Refresh progress after return
                                      },
                                      child: Text("Donate"),
                                    ),
                                  ),
                                ],
                              ),
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
