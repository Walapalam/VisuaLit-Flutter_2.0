import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPreferences {
  static const String _analyticsKey = 'analytics_enabled';
  static const String _personalizationKey = 'personalization_enabled';
  static const String _crashReportingKey = 'crash_reporting_enabled';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _bookUpdatesKey = 'book_updates_enabled';
  static const String _newReleasesKey = 'new_releases_enabled';
  static const String _quietHoursEnabledKey = 'quiet_hours_enabled';
  static const String _quietHoursStartKey = 'quiet_hours_start';
  static const String _quietHoursEndKey = 'quiet_hours_end';
  static const String _notificationFrequencyKey = 'notification_frequency';

  // Singleton instance
  static SettingsPreferences? _instance;

  // SharedPreferences instance
  SharedPreferences? _prefs;
  bool _initialized = false;

  // Factory constructor
  factory SettingsPreferences() {
    _instance ??= SettingsPreferences._();
    return _instance!;
  }

  // Private constructor
  SettingsPreferences._();

  // Initialize SharedPreferences
  Future<void> init() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  // Check if prefs is initialized and return it
  SharedPreferences get prefs {
    if (_prefs == null) {
      throw StateError('SettingsPreferences not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // Check if initialized
  bool get isInitialized => _initialized;

  // Privacy Settings
  Future<void> setAnalytics(bool value) async {
    await prefs.setBool(_analyticsKey, value);
  }

  bool getAnalytics() {
    return prefs.getBool(_analyticsKey) ?? true; // Default to true
  }

  Future<void> setPersonalization(bool value) async {
    await prefs.setBool(_personalizationKey, value);
  }

  bool getPersonalization() {
    return prefs.getBool(_personalizationKey) ?? true; // Default to true
  }

  Future<void> setCrashReporting(bool value) async {
    await prefs.setBool(_crashReportingKey, value);
  }

  bool getCrashReporting() {
    return prefs.getBool(_crashReportingKey) ?? true; // Default to true
  }

  // Notification Settings
  Future<void> setNotificationsEnabled(bool value) async {
    await prefs.setBool(_notificationsEnabledKey, value);
  }

  bool getNotificationsEnabled() {
    return prefs.getBool(_notificationsEnabledKey) ?? true; // Default to true
  }

  Future<void> setBookUpdatesEnabled(bool value) async {
    await prefs.setBool(_bookUpdatesKey, value);
  }

  bool getBookUpdatesEnabled() {
    return prefs.getBool(_bookUpdatesKey) ?? true; // Default to true
  }

  Future<void> setNewReleasesEnabled(bool value) async {
    await prefs.setBool(_newReleasesKey, value);
  }

  bool getNewReleasesEnabled() {
    return prefs.getBool(_newReleasesKey) ?? true; // Default to true
  }

  Future<void> setQuietHoursEnabled(bool value) async {
    await prefs.setBool(_quietHoursEnabledKey, value);
  }

  bool getQuietHoursEnabled() {
    return prefs.getBool(_quietHoursEnabledKey) ?? false; // Default to false
  }

  Future<void> setQuietHoursStart(TimeOfDay time) async {
    final minutes = time.hour * 60 + time.minute;
    await prefs.setInt(_quietHoursStartKey, minutes);
  }

  TimeOfDay getQuietHoursStart() {
    final minutes = prefs.getInt(_quietHoursStartKey) ?? 1320; // Default to 10:00 PM (22*60)
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }

  Future<void> setQuietHoursEnd(TimeOfDay time) async {
    final minutes = time.hour * 60 + time.minute;
    await prefs.setInt(_quietHoursEndKey, minutes);
  }

  TimeOfDay getQuietHoursEnd() {
    final minutes = prefs.getInt(_quietHoursEndKey) ?? 420; // Default to 7:00 AM (7*60)
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }

  Future<void> setNotificationFrequency(String frequency) async {
    await prefs.setString(_notificationFrequencyKey, frequency);
  }

  String getNotificationFrequency() {
    return prefs.getString(_notificationFrequencyKey) ?? 'Daily'; // Default to Daily
  }
}
