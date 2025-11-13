import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

/// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("🔵 Background message received: ${message.notification?.body}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MessagingApp());
}

class MessagingApp extends StatelessWidget {
  const MessagingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Firebase Messaging",
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? fcmToken = "Fetching token...";

  @override
  void initState() {
    super.initState();

    // Get FCM token
    FirebaseMessaging.instance.getToken().then((token) {
      print("🔑 FCM Token: $token");
      setState(() => fcmToken = token);
    });

    // Foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      print("🟢 Foreground message: ${message.notification?.body}");
      _showNotificationDialog(message.notification?.title, message.notification?.body);
    });

    // When app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("🟡 Message opened from tray!");
      _showNotificationDialog("Opened From Tray", message.notification?.body);
    });
  }

  void _showNotificationDialog(String? title, String? body) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title ?? "Notification"),
        content: Text(body ?? "No message body"),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Firebase Messaging"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Your FCM Token:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SelectableText(
              fcmToken ?? "No token",
              style: const TextStyle(fontSize: 14, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
