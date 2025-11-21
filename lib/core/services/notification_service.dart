// import 'dart:io';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// /// Background handler (top-level function is required)
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   // You can log background messages here if needed.
// }
//
// class NotificationService {
//   // Singleton
//   NotificationService._internal();
//   static final NotificationService instance = NotificationService._internal();
//
//   final FirebaseMessaging _messaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _localNotifications =
//   FlutterLocalNotificationsPlugin();
//
//   bool _initialized = false;
//
//   /// Initialize Firebase Messaging & Local Notifications
//   Future<void> init() async {
//     if (_initialized) return;
//
//     // Firebase Init
//     await Firebase.initializeApp();
//
//     // Background message handler
//     FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
//
//     // Request permissions (Android auto-granted but still recommended)
//     await _messaging.requestPermission();
//
//     // Initialize local notifications plugin
//     const AndroidInitializationSettings androidSettings =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     const InitializationSettings initSettings =
//     InitializationSettings(android: androidSettings);
//
//     await _localNotifications.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse details) {
//         // Handle tap on notification (foreground/background)
//         debugPrint('Notification tapped: ${details.payload}');
//       },
//     );
//
//     // Create Android notification channel
//     await _createNotificationChannel();
//
//     // Listen for FCM messages in foreground
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       _showForegroundNotification(message);
//     });
//
//     // Listen when user taps a notification (when app is open in background)
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       debugPrint("Notification opened: ${message.data}");
//     });
//
//     _initialized = true;
//   }
//
//   /// Subscribe user to the marketing topic
//   Future<void> subscribeToMarketingTopic() async {
//     await _messaging.subscribeToTopic('marketing');
//     debugPrint("Subscribed to topic: marketing");
//   }
//
//   /// Create Android FCM notification channel
//   Future<void> _createNotificationChannel() async {
//     const AndroidNotificationChannel channel = AndroidNotificationChannel(
//       'high_importance_channel', // unique ID
//       'High Importance Notifications', // name
//       description: 'This channel is used for marketing messages.',
//       importance: Importance.high,
//     );
//
//     final androidPlugin =
//     _localNotifications.resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin>();
//
//     await androidPlugin?.createNotificationChannel(channel);
//   }
//
//   /// Show notification manually when app is in FOREGROUND
//   Future<void> _showForegroundNotification(RemoteMessage message) async {
//     final notification = message.notification;
//     final android = notification?.android;
//
//     if (notification == null || android == null) return;
//
//     const AndroidNotificationDetails androidDetails =
//     AndroidNotificationDetails(
//       'high_importance_channel',
//       'High Importance Notifications',
//       channelDescription: 'This channel is used for marketing messages.',
//       importance: Importance.high,
//       priority: Priority.high,
//       playSound: true,
//     );
//
//     const NotificationDetails platformDetails =
//     NotificationDetails(android: androidDetails);
//
//     await _localNotifications.show(
//       DateTime.now().millisecond ~/ 1000,
//       notification.title,
//       notification.body,
//       platformDetails,
//       payload: message.data.toString(),
//     );
//   }
// }
