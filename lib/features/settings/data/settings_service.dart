import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';
import 'package:visualit/features/settings/data/user_settings.dart';

/// Service for managing user settings
class SettingsService {
  final Isar _isar;

  SettingsService(this._isar);

  /// Load user settings from the database
  Future<UserSettings> loadSettings() async {
    // Try to find existing settings
    final settings = await _isar.userSettings.where().findFirst();
    
    // If no settings exist, create default settings
    if (settings == null) {
      final defaultSettings = UserSettings();
      await saveSettings(defaultSettings);
      return defaultSettings;
    }
    
    return settings;
  }

  /// Save user settings to the database
  Future<void> saveSettings(UserSettings settings) async {
    await _isar.writeTxn(() async {
      settings.updatedAt = DateTime.now();
      await _isar.userSettings.put(settings);
    });
  }

  /// Update settings from ReadingPreferences
  Future<void> updateFromReadingPreferences(ReadingPreferences prefs) async {
    final settings = await loadSettings();
    settings.updateFromReadingPreferences(prefs);
    await saveSettings(settings);
  }

  /// Get settings as ReadingPreferences
  Future<ReadingPreferences> getReadingPreferences() async {
    final settings = await loadSettings();
    return settings.toReadingPreferences();
  }

  /// Watch for changes to user settings
  Stream<UserSettings?> watchSettings() {
    return _isar.userSettings.watchObject(1, fireImmediately: true);
  }
}

/// Provider for the SettingsService
final settingsServiceProvider = Provider<SettingsService>((ref) {
  final isar = ref.watch(isarDBProvider).value!;
  return SettingsService(isar);
});