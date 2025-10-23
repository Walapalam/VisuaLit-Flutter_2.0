import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> onActionNotificationMethod(ReceivedAction action) async {
  debugPrint('[AwesomeNotifications][BACKGROUND][ACTION] ${action.toMap()}');
  // TODO: handle action (open deep link, update DB, etc.)
}

@pragma('vm:entry-point')
Future<void> onNotificationCreatedMethod(ReceivedNotification notification) async {
  debugPrint('[AwesomeNotifications][BACKGROUND][CREATED] ${notification.toMap()}');
  // Optional: background processing for created notification
}

@pragma('vm:entry-point')
Future<void> onNotificationDisplayedMethod(ReceivedNotification notification) async {
  debugPrint('[AwesomeNotifications][BACKGROUND][DISPLAYED] ${notification.toMap()}');
}

@pragma('vm:entry-point')
Future<void> onDismissActionReceivedMethod(ReceivedAction action) async {
  debugPrint('[AwesomeNotifications][BACKGROUND][DISMISS] ${action.toMap()}');
}