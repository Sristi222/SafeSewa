import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core for initialization
import 'package:firebase_messaging/firebase_messaging.dart'; // For FCM notifications
import 'package:shared_preferences/shared_preferences.dart'; // ✅ Added SharedPreferences
import 'login.dart';
import 'registration.dart';
import 'dashboard.dart';
import 'admin_dashboard.dart';
import 'volunteer_dashboard.dart';

// Background message handler for FCM
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // ✅ Initialize Firebase

  // ✅ Initialize Firebase Messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ✅ Retrieve saved user credentials for auto-login
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
    homeScreen = const SignInPage(); // ✅ Redirect to login if no token is found
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
      initialRoute: '/', // ✅ Keep initial route
      routes: {
        '/': (context) => homeScreen, // ✅ Auto-login logic applied here
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

    // Request permission for notifications
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('Notification permission status: ${settings.authorizationStatus}');

    // Get the FCM token
    messaging.getToken().then((token) {
      setState(() {
        _fcmToken = token;
      });
      print('Firebase Messaging Token: $_fcmToken');
    });

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.messageId}');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print(
            'Message notification: ${message.notification?.title}, ${message.notification?.body}');
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
                Navigator.pushNamed(context, '/login'); // Navigate to Login
              },
              child: const Text("Go to Login"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup'); // Navigate to Signup
              },
              child: const Text("Go to Signup"),
            ),
            if (_fcmToken != null) // Display the FCM Token if available
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SelectableText('FCM Token:\n$_fcmToken'),
              ),
          ],
        ),
      ),
    );
  }
}
