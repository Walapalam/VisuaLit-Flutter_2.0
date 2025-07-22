import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:visualit/core/models/user_preferences_schema.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/data/layout_cache_service.dart';
import 'package:visualit/features/reader/data/reading_providers.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:visualit/core/api/appwrite_client.dart';

/// Provider for the SettingsService
final settingsServiceProvider = Provider<SettingsService>((ref) {
  final isar = ref.watch(isarDBProvider).requireValue;
  final databases = ref.watch(appwriteDatabasesProvider);
  final realtime = ref.watch(appwriteRealtimeProvider);
  final layoutCacheService = ref.watch(layoutCacheServiceProvider);
  return SettingsService(isar, databases, realtime, layoutCacheService);
});

/// Provider for user preferences
final userPreferencesProvider = StateNotifierProvider<UserPreferencesNotifier, AsyncValue<UserPreferencesSchema>>((ref) {
  final settingsService = ref.watch(settingsServiceProvider);
  return UserPreferencesNotifier(settingsService, ref);
});

/// Notifier for user preferences
class UserPreferencesNotifier extends StateNotifier<AsyncValue<UserPreferencesSchema>> {
  final SettingsService _settingsService;
  final Ref _ref;

  UserPreferencesNotifier(this._settingsService, this._ref) : super(const AsyncValue.loading()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await _settingsService.getUserPreferences();
      state = AsyncValue.data(prefs);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (state is AsyncData) {
      final currentPrefs = (state as AsyncData<UserPreferencesSchema>).value;
      final updatedPrefs = currentPrefs..themeMode = themeMode..updatedAt = DateTime.now();
      state = AsyncValue.data(updatedPrefs);
      await _settingsService.saveUserPreferences(updatedPrefs);
    }
  }

  Future<void> setFontSize(String fontSize) async {
    if (state is AsyncData) {
      final currentPrefs = (state as AsyncData<UserPreferencesSchema>).value;
      final updatedPrefs = currentPrefs..fontSize = fontSize..updatedAt = DateTime.now();
      state = AsyncValue.data(updatedPrefs);
      await _settingsService.saveUserPreferences(updatedPrefs);

      // Invalidate layout cache for all books
      await _settingsService.invalidateLayoutCache();
    }
  }

  Future<void> setFontStyle(String fontStyle) async {
    if (state is AsyncData) {
      final currentPrefs = (state as AsyncData<UserPreferencesSchema>).value;
      final updatedPrefs = currentPrefs..fontStyle = fontStyle..updatedAt = DateTime.now();
      state = AsyncValue.data(updatedPrefs);
      await _settingsService.saveUserPreferences(updatedPrefs);

      // Invalidate layout cache for all books
      await _settingsService.invalidateLayoutCache();
    }
  }

  Future<void> setLineSpacing(double lineSpacing) async {
    if (state is AsyncData) {
      final currentPrefs = (state as AsyncData<UserPreferencesSchema>).value;
      final updatedPrefs = currentPrefs..lineSpacing = lineSpacing..updatedAt = DateTime.now();
      state = AsyncValue.data(updatedPrefs);
      await _settingsService.saveUserPreferences(updatedPrefs);

      // Invalidate layout cache for all books
      await _settingsService.invalidateLayoutCache();
    }
  }

  Map<String, dynamic> getFontSettings() {
    if (state is AsyncData) {
      final prefs = (state as AsyncData<UserPreferencesSchema>).value;
      return {
        'fontSize': prefs.fontSize,
        'fontStyle': prefs.fontStyle,
        'lineSpacing': prefs.lineSpacing,
      };
    }
    return {
      'fontSize': 'Medium',
      'fontStyle': 'Inter',
      'lineSpacing': 1.2,
    };
  }
}

/// Service for managing user preferences
class SettingsService {
  final Isar _isar;
  final Databases _databases;
  final Realtime _realtime;
  final LayoutCacheService _layoutCacheService;
  static const String _collectionId = 'user_preferences';
  static const String _databaseId = 'visualit';

  // Store active subscriptions to clean up when needed
  final Map<String, RealtimeSubscription> _subscriptions = {};

  SettingsService(this._isar, this._databases, this._realtime, this._layoutCacheService);

  /// Get user preferences from Isar
  Future<UserPreferencesSchema> getUserPreferences() async {
    // Try to get existing preferences
    final prefs = await _isar.userPreferencesSchemas.where().findFirst();

    if (prefs != null) {
      return prefs;
    }

    // Create default preferences if none exist
    final defaultPrefs = UserPreferencesSchema()
      ..themeMode = ThemeMode.system
      ..fontSize = 'Medium'
      ..fontStyle = 'Inter'
      ..lineSpacing = 1.2
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.userPreferencesSchemas.put(defaultPrefs);
    });

    return defaultPrefs;
  }

  /// Save user preferences to Isar and sync to Appwrite
  Future<void> saveUserPreferences(UserPreferencesSchema prefs) async {
    // Save to Isar
    await _isar.writeTxn(() async {
      await _isar.userPreferencesSchemas.put(prefs);
    });

    // Sync to Appwrite if user is authenticated
    if (prefs.userId != null) {
      try {
        // Convert to map for Appwrite
        final prefsMap = {
          'userId': prefs.userId,
          'themeMode': prefs.themeMode.index,
          'fontSize': prefs.fontSize,
          'fontStyle': prefs.fontStyle,
          'lineSpacing': prefs.lineSpacing,
          'updatedAt': prefs.updatedAt.millisecondsSinceEpoch,
        };

        // Check if document exists
        try {
          final existingDoc = await _databases.getDocument(
            databaseId: _databaseId,
            collectionId: _collectionId,
            documentId: prefs.userId!,
          );

          // Update if exists
          if (existingDoc.$id == prefs.userId) {
            await _databases.updateDocument(
              databaseId: _databaseId,
              collectionId: _collectionId,
              documentId: prefs.userId!,
              data: prefsMap,
            );
          }
        } catch (e) {
          // Create if doesn't exist
          await _databases.createDocument(
            databaseId: _databaseId,
            collectionId: _collectionId,
            documentId: prefs.userId!,
            data: prefsMap,
          );
        }
      } catch (e) {
        print('Error syncing preferences to Appwrite: $e');
      }
    }
  }

  /// Invalidate layout cache for all books
  Future<void> invalidateLayoutCache() async {
    await _layoutCacheService.clearAllCaches();
  }

  /// Subscribe to changes in user preferences from Appwrite
  void subscribeToPreferencesChanges(String userId, Function(UserPreferencesSchema) onUpdate) {
    // Cancel any existing subscription for this user
    if (_subscriptions.containsKey(userId)) {
      _subscriptions[userId]?.close();
      _subscriptions.remove(userId);
    }

    // Create a new subscription
    final subscription = _realtime.subscribe([
      'databases.$_databaseId.collections.$_collectionId.documents.$userId'
    ]);

    subscription.stream.listen((response) {
      if (response.events.contains('databases.*.collections.*.documents.*.update') ||
          response.events.contains('databases.$_databaseId.collections.$_collectionId.documents.$userId.update')) {

        // Extract the updated data
        final payload = response.payload;

        // Check if this is a newer update than what we have locally
        final remoteUpdatedAt = DateTime.fromMillisecondsSinceEpoch(payload['updatedAt']);

        // Get the local preferences
        _isar.userPreferencesSchemas.where().findFirst().then((localPrefs) {
          // If we don't have local prefs or the remote update is newer, update local
          if (localPrefs == null || remoteUpdatedAt.isAfter(localPrefs.updatedAt)) {
            // Create updated preferences from remote data
            final updatedPrefs = UserPreferencesSchema()
              ..id = localPrefs?.id ?? Isar.autoIncrement
              ..userId = payload['userId']
              ..themeMode = ThemeMode.values[payload['themeMode']]
              ..fontSize = payload['fontSize']
              ..fontStyle = payload['fontStyle']
              ..lineSpacing = payload['lineSpacing'].toDouble()
              ..createdAt = localPrefs?.createdAt ?? DateTime.now()
              ..updatedAt = remoteUpdatedAt;

            // Save to local database
            _isar.writeTxn(() async {
              await _isar.userPreferencesSchemas.put(updatedPrefs);
            }).then((_) {
              // Notify the callback
              onUpdate(updatedPrefs);

              // Invalidate layout cache if font settings changed
              if (localPrefs != null && (
                  localPrefs.fontSize != updatedPrefs.fontSize ||
                  localPrefs.fontStyle != updatedPrefs.fontStyle ||
                  localPrefs.lineSpacing != updatedPrefs.lineSpacing)) {
                invalidateLayoutCache();
              }
            });
          }
        });
      }
    });

    // Store the subscription
    _subscriptions[userId] = subscription;
  }

  /// Cancel subscription for a user
  void cancelSubscription(String userId) {
    if (_subscriptions.containsKey(userId)) {
      _subscriptions[userId]?.close();
      _subscriptions.remove(userId);
    }
  }

  /// Cancel all subscriptions
  void cancelAllSubscriptions() {
    for (final subscription in _subscriptions.values) {
      subscription.close();
    }
    _subscriptions.clear();
  }
}
