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

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling background message: \${message.messageId}");
}

Future<void> showLocalNotification(String title, String body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'disaster_channel',
    'Disaster Alerts',
    channelDescription: 'Channel for disaster alert notifications',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
    payload: 'default',
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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
      initialRoute: '/',
      routes: {
        '/': (context) => homeScreen,
        '/login': (context) => SignInPage(),
        '/signup': (context) => SignupPage(),
        '/dashboard': (context) => const Dashboard(token: '', userId: ''),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    _initializeFirebaseMessaging();
  }

  void _initializeFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('Notification permission status: \${settings.authorizationStatus}');

    messaging.getToken().then((token) {
      setState(() {
        _fcmToken = token;
      });
      print('Firebase Messaging Token: \$_fcmToken');
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: \${message.messageId}');
      print('Message data: \${message.data}');
      if (message.notification != null) {
        print('Message notification: \${message.notification?.title}, \${message.notification?.body}');

        showLocalNotification(
          message.notification?.title ?? 'Alert',
          message.notification?.body ?? 'You have a new message',
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SafeSewa')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: const Text("Go to Login"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              child: const Text("Go to Signup"),
            ),
            if (_fcmToken != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SelectableText('FCM Token:\n\$_fcmToken'),
              ),
          ],
        ),
      ),
    );
  }
}