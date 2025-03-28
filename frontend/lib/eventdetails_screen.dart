import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './model/event_model.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;
  final String userId;

  const EventDetailsScreen({required this.eventId, required this.userId});

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  Event? event;
  bool isEnrolled = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchEvent();
  }

  Future<void> fetchEvent() async {
    final response = await http.get(Uri.parse('http://192.168.1.9:3000/api/events/${widget.eventId}'));
    if (response.statusCode == 200) {
      setState(() {
        event = Event.fromJson(json.decode(response.body));
      });
    } else {
      print('Error fetching event: ${response.body}');
    }
  }

  Future<void> enrollInEvent() async {
    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse('http://192.168.1.9:3000/api/events/${widget.eventId}/enroll'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'volunteerId': widget.userId}),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      setState(() => isEnrolled = true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You are now enrolled in this event!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error enrolling")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (event == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Event Details")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(event!.title)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(event!.image, height: 200, fit: BoxFit.cover),
            SizedBox(height: 10),
            Text(event!.organization, style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text("Date: ${event!.date}"),
            Text("Time: ${event!.time}"),
            Text("Location: ${event!.location}"),
            Text("Spots Remaining: ${event!.spots}"),
            SizedBox(height: 20),
            Text(event!.description),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: isEnrolled || isLoading ? null : enrollInEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEnrolled ? Colors.grey : null,
                ),
                child: isEnrolled
                    ? Text("You are enrolled")
                    : isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("Enroll"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
