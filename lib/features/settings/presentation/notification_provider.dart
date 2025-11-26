import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visualit/core/services/notification_service.dart';

// --- Marketing Notifications Provider ---
const String _marketingNotificationsKey = 'marketing_notifications_enabled';

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, bool>((ref) {
      return NotificationController(ref);
    });

class NotificationController extends StateNotifier<bool> {
  final Ref _ref;
  NotificationController(this._ref) : super(true) {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_marketingNotificationsKey) ?? true;
    print(
      '📱 Marketing Notification preference loaded: ${state ? "ENABLED" : "DISABLED"}',
    );
  }

  Future<void> toggleNotifications(bool isEnabled) async {
    print('═══════════════════════════════════════════');
    print('🔄 TOGGLING NOTIFICATIONS: ${isEnabled ? "ON" : "OFF"}');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_marketingNotificationsKey, isEnabled);
    state = isEnabled;

    final notificationService = _ref.read(notificationServiceProvider);
    if (isEnabled) {
      await notificationService.subscribeToTopic('all_users');
      print('✅ Marketing Notifications ENABLED');
    } else {
      await notificationService.unsubscribeFromTopic('all_users');
      print('❌ Marketing Notifications DISABLED');
    }
    print('═══════════════════════════════════════════');
  }
}

// --- Generic Toggle Providers ---

final accountAlertsProvider = StateNotifierProvider<ToggleStateNotifier, bool>(
  (ref) => ToggleStateNotifier('account_alerts_enabled'),
);

final generalNotificationsProvider =
    StateNotifierProvider<ToggleStateNotifier, bool>(
      (ref) => ToggleStateNotifier('general_notifications_enabled'),
    );

class ToggleStateNotifier extends StateNotifier<bool> {
  final String _prefsKey;
  ToggleStateNotifier(this._prefsKey) : super(true) {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_prefsKey) ?? true;
  }

  Future<void> toggle(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, isEnabled);
    state = isEnabled;
  }
}
