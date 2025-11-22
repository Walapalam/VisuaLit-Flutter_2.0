import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationServiceProvider = Provider((ref) => NotificationService());

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Print notification details when received in background
  print('═══════════════════════════════════════════');
  print('🔔 BACKGROUND NOTIFICATION RECEIVED');
  print('Message ID: ${message.messageId}');
  print('Title: ${message.notification?.title ?? 'No title'}');
  print('Body: ${message.notification?.body ?? 'No body'}');
  print('Data: ${message.data}');
  print('Sent Time: ${message.sentTime}');
  print('═══════════════════════════════════════════');
}

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Request permissions
    NotificationSettings settings = await _fcm.requestPermission();
    print('✅ Notification permission status: ${settings.authorizationStatus}');

    // Initialize local notifications for foreground messages
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);

    // Set up message handlers
    FirebaseMessaging.onMessage.listen(_showLocalNotification);
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('═══════════════════════════════════════════');
      print('👆 NOTIFICATION TAPPED (App in background)');
      print('Message ID: ${message.messageId}');
      print('Title: ${message.notification?.title ?? 'No title'}');
      print('═══════════════════════════════════════════');
    });
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    print('✅ NotificationService initialized');
  }

  void _showLocalNotification(RemoteMessage message) async {
    // Print notification details when received in foreground
    print('═══════════════════════════════════════════');
    print('🔔 FOREGROUND NOTIFICATION RECEIVED');
    print('Message ID: ${message.messageId}');
    print('Title: ${message.notification?.title ?? 'No title'}');
    print('Body: ${message.notification?.body ?? 'No body'}');
    print('Data: ${message.data}');
    print('Sent Time: ${message.sentTime}');
    print('═══════════════════════════════════════════');

    final notification = message.notification;
    if (notification != null) {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'marketing_messages',
        'Marketing Messages',
        channelDescription: 'Notifications from the VisuaLit team.',
        importance: Importance.max,
        priority: Priority.high,
      );
      const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        notificationDetails,
      );

      print('✅ Local notification shown');
    } else {
      print('⚠️ Notification payload is null');
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
    print('═══════════════════════════════════════════');
    print('✅ SUBSCRIBED to topic: $topic');
    print('═══════════════════════════════════════════');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
    print('═══════════════════════════════════════════');
    print('❌ UNSUBSCRIBED from topic: $topic');
    print('═══════════════════════════════════════════');
  }
}