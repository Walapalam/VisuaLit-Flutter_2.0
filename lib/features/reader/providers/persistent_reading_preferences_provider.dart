import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';
import 'package:visualit/features/reader/providers/layout_cache_provider.dart';
import 'package:visualit/features/settings/data/settings_service.dart';
import 'package:visualit/features/settings/data/user_settings.dart';

/// A provider that wraps the ReadingPreferencesController and handles persistence
final persistentReadingPreferencesProvider = Provider<ReadingPreferencesController>((ref) {
  final controller = ref.watch(readingPreferencesProvider.notifier);
  final isar = ref.watch(isarDBProvider).value!;
  final settingsService = SettingsService(isar);
  final layoutCacheService = ref.watch(layoutCacheServiceProvider);
  
  // Load settings from database when the provider is created
  settingsService.getReadingPreferences().then((prefs) {
    // Apply the loaded preferences to the controller
    controller.applyTheme(prefs);
  });
  
  // Listen for changes to the reading preferences
  ref.listen(readingPreferencesProvider, (previous, next) {
    if (previous != next) {
      // Save the updated preferences to the database
      settingsService.updateFromReadingPreferences(next);
      
      // Invalidate layout cache when settings change
      layoutCacheService.clearAllLayouts();
    }
  });
  
  return controller;
});