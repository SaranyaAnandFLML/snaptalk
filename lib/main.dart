import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'features/auth/screens/spalsh_screen.dart';
import 'models/user_model.dart';

//
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
// FlutterLocalNotificationsPlugin();

// Background message handler
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   debugPrint("🔵 Background FCM message: ${message.notification?.title}");
// }


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  await Hive.openBox<UserModel>('users');
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // // Initialize local notifications
  // const AndroidInitializationSettings androidInitSettings =
  // AndroidInitializationSettings('@mipmap/ic_launcher');
  // const InitializationSettings initSettings =
  // InitializationSettings(android: androidInitSettings);
  // await flutterLocalNotificationsPlugin.initialize(initSettings);
  // FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
  runApp(ProviderScope(child: MyApp()));
}

// void _showNotification(RemoteMessage message) {
//   final notification = message.notification;
//   if (notification == null) return;
//
//   // const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//   //   'high_importance_channel', // Make sure this ID is consistent across app launches
//   //   'High Importance Notifications',
//   //   channelDescription: 'This channel is used for important notifications.',
//   //   importance: Importance.max,
//   //   priority: Priority.high,
//   //   playSound: true,
//   //   // Don't set sound: field to anything, it will use default
//   // );
//
//   // const NotificationDetails notificationDetails = NotificationDetails(
//   //   android: androidDetails,
//   // );
//
//   // flutterLocalNotificationsPlugin.show(
//   //   notification.hashCode,
//   //   notification.title,
//   //   notification.body,
//   //   notificationDetails,
//   // );
// }
final navigatorKey=GlobalKey<NavigatorState>();
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnapTalk',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SplashScreen(),
    );
  }
}

