import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './model/event_model.dart';

class RecentEventsScreen extends StatefulWidget {
  final String userId;
  const RecentEventsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _RecentEventsScreenState createState() => _RecentEventsScreenState();
}

class _RecentEventsScreenState extends State<RecentEventsScreen> {
  List<Event> recentEvents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecentEvents();
  }

  Future<void> fetchRecentEvents() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(
        Uri.parse('http://100.64.199.99:3000/api/events/volunteer/${widget.userId}'),
      );
      if (res.statusCode == 200) {
        final List decoded = json.decode(res.body);
        setState(() {
          recentEvents = decoded.map((e) => Event.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        print("Error fetching events: ${res.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Enrolled Events"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchRecentEvents,
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchRecentEvents,
              child: recentEvents.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(height: 150),
                        Center(child: Text("No events enrolled yet."))
                      ],
                    )
                  : ListView.builder(
                      itemCount: recentEvents.length,
                      itemBuilder: (context, index) {
                        final e = recentEvents[index];
                        return Card(
                          margin: EdgeInsets.all(8),
                          child: ListTile(
                            leading: Image.network(
                              e.image,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                            title: Text(e.title),
                            subtitle: Text('${e.date} at ${e.time}'),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
