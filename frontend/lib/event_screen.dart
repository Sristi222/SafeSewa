import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './model/event_model.dart';
import 'eventdetails_screen.dart';

class HomeFeedScreen extends StatefulWidget {
  final String userId;

  const HomeFeedScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _HomeFeedScreenState createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  List<Event> events = [];

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    final response = await http.get(Uri.parse('http://192.168.1.9:3000/api/events'));
    if (response.statusCode == 200) {
      final List decoded = json.decode(response.body);
      setState(() {
        events = decoded.map((e) => Event.fromJson(e)).toList();
      });
    } else {
      print('Failed to fetch events: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Feed')),
      body: events.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final e = events[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(e.image, height: 150, width: double.infinity, fit: BoxFit.cover),
                      ListTile(
                        title: Text(e.title),
                        subtitle: Text('${e.location} | ${e.date}'),
                        trailing: ElevatedButton(
                          child: const Text("Details"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EventDetailsScreen(
                                  eventId: e.id,
                                  userId: widget.userId,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
