import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelplinePage extends StatefulWidget {
  @override
  _HelplinePageState createState() => _HelplinePageState();
}

class _HelplinePageState extends State<HelplinePage> {
  final List<Map<String, String>> helplineNumbers = [
    {'title': 'Police Emergency', 'number': '100'},
    {'title': 'Ambulance', 'number': '102'},
    {'title': 'Fire Brigade', 'number': '101'},
    {'title': 'Nepal Red Cross', 'number': '4228094'},
    {'title': 'Child Helpline', 'number': '1098'},
    {'title': 'Women Helpline', 'number': '1145'},
    {'title': 'Traffic Police', 'number': '103'},
    {'title': 'Tourist Police', 'number': '1144'},
    {'title': 'Nepal Telecom', 'number': '1498'},
    {'title': 'Electricity Emergency', 'number': '1150'},
    {'title': 'Electricity Emergency', 'number': '9841370926'},
  ];

  List<Map<String, String>> filteredNumbers = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    filteredNumbers = helplineNumbers;
  }

  void _filterNumbers(String query) {
    setState(() {
      searchQuery = query;
      filteredNumbers = helplineNumbers
          .where((item) => item['title']!.toLowerCase().contains(query.toLowerCase()))
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
              child: filteredNumbers.isEmpty
                  ? const Center(child: Text("No matches found."))
                  : ListView.builder(
                      itemCount: filteredNumbers.length,
                      itemBuilder: (context, index) {
                        final item = filteredNumbers[index];
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
                              item['title']!,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(item['number']!),
                            trailing: IconButton(
                              icon: const Icon(Icons.call, color: Colors.green),
                              onPressed: () => _makePhoneCall(item['number']!),
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
