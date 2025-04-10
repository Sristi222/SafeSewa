import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DisasterMapScreen extends StatefulWidget {
  @override
  _DisasterMapScreenState createState() => _DisasterMapScreenState();
}

class _DisasterMapScreenState extends State<DisasterMapScreen> {
  List<dynamic> alerts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDisasterData();
  }

  Future<void> fetchDisasterData() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.10:3000/api/disasters'), // Your backend IP
      );
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          alerts = data;
          isLoading = false;
        });
      } else {
        print("Failed to load disaster data: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching disaster data: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Live Disaster Alerts')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView.builder(
                itemCount: alerts.length,
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  return Card(
                    color: alert['type'] == 'earthquake' ? Colors.red[100] : Colors.blue[100],
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.warning,
                        color: alert['type'] == 'earthquake' ? Colors.red : Colors.blue,
                      ),
                      title: Text(
                        alert['type'].toString().toUpperCase(),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(alert['description'] ?? 'No description'),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Lat: ${alert['location']['lat']}'),
                          Text('Lng: ${alert['location']['lng']}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
