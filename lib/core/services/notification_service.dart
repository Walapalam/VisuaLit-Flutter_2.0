import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationServiceProvider = Provider((ref) => NotificationService());

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Print notification details when received in background
  if (kDebugMode) {
    print('═══════════════════════════════════════════');
    print('🔔 BACKGROUND NOTIFICATION RECEIVED');
    print('Message ID: ${message.messageId}');
    print('Title: ${message.notification?.title ?? 'No title'}');
    print('Body: ${message.notification?.body ?? 'No body'}');
    print('Data: ${message.data}');
    print('Sent Time: ${message.sentTime}');
    print('═══════════════════════════════════════════');
  }
}

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    try {
      // Request permissions
      NotificationSettings settings = await _fcm.requestPermission();
      if (kDebugMode) {
        print(
          '✅ Notification permission status: ${settings.authorizationStatus}',
        );
      }

      // Get and print FCM Token
      String? fcmToken;
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        // On iOS, we need the APNS token first.
        // On Simulators, this will often be null or throw an error.
        String? apnsToken = await _fcm.getAPNSToken();
        if (apnsToken != null) {
          fcmToken = await _fcm.getToken();
        } else {
          // Wait a bit and try one more time (sometimes it's just a race condition)
          await Future.delayed(const Duration(seconds: 3));
          apnsToken = await _fcm.getAPNSToken();
          if (apnsToken != null) {
            fcmToken = await _fcm.getToken();
          } else {
            if (kDebugMode) {
              print(
                '⚠️ APNS Token not available. (Expected behavior on Simulator)',
              );
              print(
                '   Remote FCM notifications will NOT work on this simulator.',
              );
            }
          }
        }
      } else {
        fcmToken = await _fcm.getToken();
      }

      if (fcmToken != null && kDebugMode) {
        print('═══════════════════════════════════════════');
        print('🔥 FCM TOKEN: $fcmToken');
        print('═══════════════════════════════════════════');
      }

      // Initialize local notifications for foreground messages
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
      );
      await _localNotifications.initialize(initSettings);

      // Set up message handlers
      FirebaseMessaging.onMessage.listen(_showLocalNotification);
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('═══════════════════════════════════════════');
          print('👆 NOTIFICATION TAPPED (App in background)');
          print('Message ID: ${message.messageId}');
          print('Title: ${message.notification?.title ?? 'No title'}');
          print('═══════════════════════════════════════════');
        }
      });
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      if (kDebugMode) {
        print('✅ NotificationService initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ NotificationService init failed: $e');
      }
    }
  }

  void _showLocalNotification(RemoteMessage message) async {
    // Print notification details when received in foreground
    if (kDebugMode) {
      print('═══════════════════════════════════════════');
      print('🔔 FOREGROUND NOTIFICATION RECEIVED');
      print('Message ID: ${message.messageId}');
      print('Title: ${message.notification?.title ?? 'No title'}');
      print('Body: ${message.notification?.body ?? 'No body'}');
      print('Data: ${message.data}');
      print('Sent Time: ${message.sentTime}');
      print('═══════════════════════════════════════════');
    }

    final notification = message.notification;
    if (notification != null) {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'marketing_messages',
            'Marketing Messages',
            channelDescription: 'Notifications from the VisuaLit team.',
            importance: Importance.max,
            priority: Priority.high,
          );
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        notificationDetails,
      );

      if (kDebugMode) {
        print('✅ Local notification shown');
      }
    } else {
      if (kDebugMode) {
        print('⚠️ Notification payload is null');
      }
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _fcm.subscribeToTopic(topic);
      if (kDebugMode) {
        print('═══════════════════════════════════════════');
        print('✅ SUBSCRIBED to topic: $topic');
        print('═══════════════════════════════════════════');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to subscribe to topic: $e');
      }
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _fcm.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print('═══════════════════════════════════════════');
        print('❌ UNSUBSCRIBED from topic: $topic');
        print('═══════════════════════════════════════════');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to unsubscribe from topic: $e');
      }
    }
  }

  Future<void> showTestNotification() async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'marketing_messages',
            'Marketing Messages',
            channelDescription: 'Notifications from the VisuaLit team.',
            importance: Importance.max,
            priority: Priority.high,
          );
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await _localNotifications.show(
        0,
        'Test Notification',
        'This is a test notification to verify the system is working.',
        notificationDetails,
      );
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Failed to show test notification: $e');
      }
    }
  }
}
