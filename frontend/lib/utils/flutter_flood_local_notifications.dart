import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/main.dart'; // Make sure navigatorKey is here
import '../notificationhistory.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    // ✅ Handle tap on notification
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      final payload = response.payload;
      if (payload == 'flood_alert') {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => NotificationHistoryScreen()),
        );
      }
    },
  );
}

Future<void> showFloodAlertNotification(int count) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'flood_alert_channel',
    'Flood Alerts',
    channelDescription: 'Displays flood warning alerts in your area',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'Flood Alert',
  );

  const NotificationDetails platformDetails = NotificationDetails(
    android: androidDetails,
  );

  // 🔔 Show local notification
  await flutterLocalNotificationsPlugin.show(
    0,
    '⚠️ Flood Alert!',
    '$count active flood alert${count > 1 ? 's' : ''} in your area',
    platformDetails,
    payload: 'flood_alert',
  );

  // 🌐 Save to backend
  try {
    final response = await http.post(
      Uri.parse('http://192.168.1.10:3000/api/notifications/flood'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': '⚠️ Flood Alert!',
        'body': '$count active flood alert${count > 1 ? 's' : ''} in your area',
      }),
    );

    if (response.statusCode == 201) {
      print("✅ Flood notification saved to backend.");
    } else {
      print("❌ Failed to save flood notification. Status: ${response.statusCode}");
    }
  } catch (e) {
    print("❌ Error sending notification to backend: $e");
  }
}
