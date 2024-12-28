import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  // Initialize Local Notifications
  void initializeLocalNotifications() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Subscribe to the flood-alerts topic and handle incoming notifications
  void subscribeToFloodAlerts(
      {required Function(String, String) onNewNotification}) {
    FirebaseMessaging.instance.subscribeToTopic('flood-alerts');
    print("Subscribed to flood-alerts topic");

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final String? title = message.notification?.title;
      final String? body = message.notification?.body;

      if (title != null && body != null) {
        onNewNotification(title, body);
        showLocalNotification(title, body);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification clicked: ${message.notification?.title}");
    });
  }

  // Show local notification
  void showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'flood_alerts', // Channel ID
      'Flood Alerts', // Channel Name
      channelDescription: 'Notifications for flood alerts',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      title.hashCode, // Unique ID
      title,
      body,
      details,
    );
  }
}
