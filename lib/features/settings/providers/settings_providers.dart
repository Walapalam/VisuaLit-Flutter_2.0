import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/settings/data/settings_preferences.dart';

// Provider for the SettingsPreferences service
final settingsPreferencesProvider = Provider<SettingsPreferences>((ref) {
  return SettingsPreferences();
});

// Provider to initialize settings - use this to ensure settings are loaded
final settingsInitializerProvider = FutureProvider<void>((ref) async {
  final prefs = ref.watch(settingsPreferencesProvider);
  await prefs.init();
  return;
});

// Default states for settings when loading
final _defaultPrivacyState = PrivacySettingsState(
  analyticsEnabled: true,
  personalizationEnabled: true,
  crashReportingEnabled: true,
);

final _defaultNotificationState = NotificationSettingsState(
  notificationsEnabled: true,
  bookUpdatesEnabled: true,
  newReleasesEnabled: true,
  quietHoursEnabled: false,
  quietHoursStart: const TimeOfDay(hour: 22, minute: 0), // 10 PM
  quietHoursEnd: const TimeOfDay(hour: 7, minute: 0),    // 7 AM
  notificationFrequency: 'Daily',
);

// Privacy Settings State
class PrivacySettingsState {
  final bool analyticsEnabled;
  final bool personalizationEnabled;
  final bool crashReportingEnabled;

  PrivacySettingsState({
    required this.analyticsEnabled,
    required this.personalizationEnabled,
    required this.crashReportingEnabled,
  });

  PrivacySettingsState copyWith({
    bool? analyticsEnabled,
    bool? personalizationEnabled,
    bool? crashReportingEnabled,
  }) {
    return PrivacySettingsState(
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      personalizationEnabled: personalizationEnabled ?? this.personalizationEnabled,
      crashReportingEnabled: crashReportingEnabled ?? this.crashReportingEnabled,
    );
  }
}

// Privacy Settings Notifier
class PrivacySettingsNotifier extends StateNotifier<PrivacySettingsState> {
  final SettingsPreferences _preferences;

  PrivacySettingsNotifier(this._preferences)
      : super(PrivacySettingsState(
          analyticsEnabled: _preferences.getAnalytics(),
          personalizationEnabled: _preferences.getPersonalization(),
          crashReportingEnabled: _preferences.getCrashReporting(),
        ));

  // Additional constructor to provide default state
  PrivacySettingsNotifier.withDefaultState(this._preferences)
      : super(_defaultPrivacyState);

  Future<void> setAnalytics(bool value) async {
    await _preferences.setAnalytics(value);
    state = state.copyWith(analyticsEnabled: value);
  }

  Future<void> setPersonalization(bool value) async {
    await _preferences.setPersonalization(value);
    state = state.copyWith(personalizationEnabled: value);
  }

  Future<void> setCrashReporting(bool value) async {
    await _preferences.setCrashReporting(value);
    state = state.copyWith(crashReportingEnabled: value);
  }
}

// Notification Settings State
class NotificationSettingsState {
  final bool notificationsEnabled;
  final bool bookUpdatesEnabled;
  final bool newReleasesEnabled;
  final bool quietHoursEnabled;
  final TimeOfDay quietHoursStart;
  final TimeOfDay quietHoursEnd;
  final String notificationFrequency;

  NotificationSettingsState({
    required this.notificationsEnabled,
    required this.bookUpdatesEnabled,
    required this.newReleasesEnabled,
    required this.quietHoursEnabled,
    required this.quietHoursStart,
    required this.quietHoursEnd,
    required this.notificationFrequency,
  });

  NotificationSettingsState copyWith({
    bool? notificationsEnabled,
    bool? bookUpdatesEnabled,
    bool? newReleasesEnabled,
    bool? quietHoursEnabled,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
    String? notificationFrequency,
  }) {
    return NotificationSettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      bookUpdatesEnabled: bookUpdatesEnabled ?? this.bookUpdatesEnabled,
      newReleasesEnabled: newReleasesEnabled ?? this.newReleasesEnabled,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      notificationFrequency: notificationFrequency ?? this.notificationFrequency,
    );
  }
}

// Notification Settings Notifier
class NotificationSettingsNotifier extends StateNotifier<NotificationSettingsState> {
  final SettingsPreferences _preferences;

  NotificationSettingsNotifier(this._preferences)
      : super(NotificationSettingsState(
          notificationsEnabled: _preferences.getNotificationsEnabled(),
          bookUpdatesEnabled: _preferences.getBookUpdatesEnabled(),
          newReleasesEnabled: _preferences.getNewReleasesEnabled(),
          quietHoursEnabled: _preferences.getQuietHoursEnabled(),
          quietHoursStart: _preferences.getQuietHoursStart(),
          quietHoursEnd: _preferences.getQuietHoursEnd(),
          notificationFrequency: _preferences.getNotificationFrequency(),
        ));

  // Additional constructor to provide default state
  NotificationSettingsNotifier.withDefaultState(this._preferences)
      : super(_defaultNotificationState);

  Future<void> setNotificationsEnabled(bool value) async {
    await _preferences.setNotificationsEnabled(value);
    state = state.copyWith(notificationsEnabled: value);
  }

  Future<void> setBookUpdatesEnabled(bool value) async {
    await _preferences.setBookUpdatesEnabled(value);
    state = state.copyWith(bookUpdatesEnabled: value);
  }

  Future<void> setNewReleasesEnabled(bool value) async {
    await _preferences.setNewReleasesEnabled(value);
    state = state.copyWith(newReleasesEnabled: value);
  }

  Future<void> setQuietHoursEnabled(bool value) async {
    await _preferences.setQuietHoursEnabled(value);
    state = state.copyWith(quietHoursEnabled: value);
  }

  Future<void> setQuietHoursStart(TimeOfDay time) async {
    await _preferences.setQuietHoursStart(time);
    state = state.copyWith(quietHoursStart: time);
  }

  Future<void> setQuietHoursEnd(TimeOfDay time) async {
    await _preferences.setQuietHoursEnd(time);
    state = state.copyWith(quietHoursEnd: time);
  }

  Future<void> setNotificationFrequency(String frequency) async {
    await _preferences.setNotificationFrequency(frequency);
    state = state.copyWith(notificationFrequency: frequency);
  }
}

// StateNotifierProviders
final privacySettingsProvider = StateNotifierProvider<PrivacySettingsNotifier, PrivacySettingsState>((ref) {
  // Watch the initializer to ensure SharedPreferences is ready
  final initializationState = ref.watch(settingsInitializerProvider);
  final preferences = ref.watch(settingsPreferencesProvider);

  // Return default state while initializing
  if (initializationState is AsyncLoading) {
    return PrivacySettingsNotifier.withDefaultState(preferences);
  }

  // Once initialized, return the real notifier
  return PrivacySettingsNotifier(preferences);
});

final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, NotificationSettingsState>((ref) {
  // Watch the initializer to ensure SharedPreferences is ready
  final initializationState = ref.watch(settingsInitializerProvider);
  final preferences = ref.watch(settingsPreferencesProvider);

  // Return default state while initializing
  if (initializationState is AsyncLoading) {
    return NotificationSettingsNotifier.withDefaultState(preferences);
  }

  // Once initialized, return the real notifier
  return NotificationSettingsNotifier(preferences);
});
