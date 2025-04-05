import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';
import 'registration.dart';
import 'dashboard.dart';
import 'admin_dashboard.dart';
import 'volunteer_dashboard.dart';

// ✅ Local Notification Plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// ✅ Background FCM handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("🔔 [Background] message: ${message.messageId}");

  showLocalNotification(
    message.notification?.title ?? 'Alert',
    message.notification?.body ?? 'Something happened!',
  );
}

/// ✅ Show notification locally
Future<void> showLocalNotification(String title, String body) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'disaster_channel',
    'Disaster Alerts',
    channelDescription: 'Channel for disaster alert notifications',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );

  const NotificationDetails platformDetails =
      NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformDetails,
    payload: 'default',
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // ✅ Initialize local notification system
  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
      InitializationSettings(android: androidInitSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // ✅ Handle background/terminated messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ✅ Handle foreground notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("🔔 [Foreground] message: ${message.notification?.title}");
    showLocalNotification(
      message.notification?.title ?? 'Alert',
      message.notification?.body ?? 'Something happened!',
    );
  });

  // ✅ Get FCM token (for testing on Firebase Console)
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? fcmToken = await messaging.getToken();
  print("📱 FCM Token: $fcmToken");

  // ✅ Handle login persistence
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString("token");
  String? userId = prefs.getString("userId");
  String? role = prefs.getString("role");

  Widget homeScreen;
  if (token != null && userId != null && role != null) {
    if (role == "Admin") {
      homeScreen = AdminDashboard(token: token, userId: userId);
    } else if (role == "Volunteer") {
      homeScreen = VolunteerDashboard(token: token, userId: userId);
    } else {
      homeScreen = Dashboard(token: token, userId: userId);
    }
  } else {
    homeScreen = const SignInPage();
  }

  runApp(MyApp(homeScreen: homeScreen));
}

class MyApp extends StatelessWidget {
  final Widget homeScreen;
  const MyApp({super.key, required this.homeScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafeSewa',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: homeScreen,
      routes: {
        '/login': (context) => SignInPage(),
        '/signup': (context) => SignupPage(),
        '/dashboard': (context) => const Dashboard(token: '', userId: ''),
      },
    );
  }
}
