import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationHistoryScreen extends StatefulWidget {
  @override
  _NotificationHistoryScreenState createState() => _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends State<NotificationHistoryScreen> {
  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      setState(() => isLoading = true);
      final response = await http.get(Uri.parse('http://192.168.1.10:3000/api/notifications'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Optional: Sort by timestamp descending (in case backend doesn’t)
        data.sort((a, b) {
          final t1 = DateTime.tryParse(a['timestamp'] ?? '') ?? DateTime.now();
          final t2 = DateTime.tryParse(b['timestamp'] ?? '') ?? DateTime.now();
          return t2.compareTo(t1);
        });

        setState(() {
          notifications = data;
          isLoading = false;
        });
      } else {
        print('❌ Failed to fetch notifications: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('❌ Error fetching notifications: $e');
      setState(() => isLoading = false);
    }
  }

  String formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}'
        ' • ${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  String getTypeLabel(String? type) {
    if (type == 'flood') return '🌊 Flood';
    if (type == 'earthquake') return '🌍 Earthquake';
    return '📌 General Alert';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchNotifications,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(child: Text('No notifications found'))
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    final title = notif['title'] ?? 'Untitled';
                    final body = notif['body'] ?? 'No message provided.';
                    final type = notif['type'];
                    final timestamp = DateTime.tryParse(notif['timestamp'] ?? '') ?? DateTime.now();

                    return ListTile(
                      leading: Icon(Icons.notifications, color: Colors.blue.shade700),
                      title: Text(getTypeLabel(type), style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(body),
                        ],
                      ),
                      trailing: Text(
                        formatTimestamp(timestamp),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.right,
                      ),
                    );
                  },
                ),
    );
  }
}
