import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  // Initialize notification service
  Future<void> init() async {
    // Initialize timezone data
    tz.initializeTimeZones();

    debugPrint('Initializing notification service');

    // Initialize awesome_notifications
    await AwesomeNotifications().initialize(
      // Set the app icon
      'resource://drawable/launcher_icon',
      [
        // Create notification channels
        NotificationChannel(
          channelKey: 'visualit_channel',
          channelName: 'VisuaLit Notifications',
          channelDescription: 'VisuaLit app notifications',
          importance: NotificationImportance.High,
          defaultColor: Colors.blue,
          ledColor: Colors.blue,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        ),
        NotificationChannel(
          channelKey: 'visualit_scheduled_channel',
          channelName: 'VisuaLit Scheduled Notifications',
          channelDescription: 'VisuaLit app scheduled notifications',
          importance: NotificationImportance.High,
          defaultColor: Colors.green,
          ledColor: Colors.green,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        ),
      ],
      debug: true, // Enable debug mode for better troubleshooting
    );

    // Request notification permissions
    await requestNotificationPermissions();

    // Setup action listeners for notifications
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (ReceivedAction receivedAction) {
        debugPrint('Notification action received: ${receivedAction.toMap()}');
        // Handle notification action here
        return Future.value(true);
      },
      onNotificationCreatedMethod: (ReceivedNotification receivedNotification) {
        debugPrint('Notification created: ${receivedNotification.toMap()}');
        return Future.value(true);
      },
      onNotificationDisplayedMethod: (ReceivedNotification receivedNotification) {
        debugPrint('Notification displayed: ${receivedNotification.toMap()}');
        return Future.value(true);
      },
      onDismissActionReceivedMethod: (ReceivedAction receivedAction) {
        debugPrint('Notification dismissed: ${receivedAction.toMap()}');
        return Future.value(true);
      },
    );

    debugPrint('Notification service initialized successfully');
  }

  // Request notification permissions
  Future<void> requestNotificationPermissions() async {
    // Request notification permissions through awesome_notifications
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        // Request permissions
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    // Additional permission request through permission_handler for older Android versions
    final status = await Permission.notification.request();
    if (status.isDenied) {
      debugPrint('Notification permission is denied');
    } else {
      debugPrint('Notification permission granted: ${status.isGranted}');
    }
  }

  // Show an immediate notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0,  // Notification ID
        channelKey: 'visualit_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        payload: payload != null ? {'data': payload} : null,
      ),
    );

    debugPrint('Notification sent: $title - $body');
  }

  // Schedule a notification for later
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,  // Notification ID
        channelKey: 'visualit_scheduled_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        payload: payload != null ? {'data': payload} : null,
      ),
      schedule: NotificationCalendar.fromDate(date: scheduledTime),
    );

    debugPrint('Scheduled notification for: ${scheduledTime.toString()}');
  }

  // Cancel a specific notification by ID
  Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  // Create a notification with image
  Future<void> showImageNotification({
    required String title,
    required String body,
    required String imagePath,
    String? payload,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 2,  // Notification ID
        channelKey: 'visualit_channel',
        title: title,
        body: body,
        bigPicture: imagePath,
        notificationLayout: NotificationLayout.BigPicture,
        payload: payload != null ? {'data': payload} : null,
      ),
    );
  }

  // Show a progress notification (useful for downloading)
  Future<void> showProgressNotification({
    required String title,
    required String body,
    required int progress,
    int maxSteps = 100,
    String? payload,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 3,  // Notification ID
        channelKey: 'visualit_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.ProgressBar,
        progress: progress.toDouble(),
        // In version 0.10.1, we use only progress without maxProgress
        // Progress should be a value between 0-100
        payload: payload != null ? {'data': payload} : null,
      ),
    );
  }
}
