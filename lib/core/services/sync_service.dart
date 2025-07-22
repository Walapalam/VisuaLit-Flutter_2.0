import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/providers/settings_provider.dart';
import 'package:visualit/core/services/highlight_service.dart';
import 'package:visualit/core/services/bookmark_service.dart';

/// Provider for the SyncService
final syncServiceProvider = Provider<SyncService>((ref) {
  final settingsService = ref.watch(settingsServiceProvider);
  final highlightService = ref.watch(highlightServiceProvider);
  final bookmarkService = ref.watch(bookmarkServiceProvider);
  return SyncService(settingsService!, highlightService, bookmarkService);
});

/// Provider for sync operations
/// This provider is used to trigger sync operations and track their status
final syncProvider = FutureProvider.autoDispose<bool>((ref) async {
  final syncService = ref.watch(syncServiceProvider);

  // If sync is not initialized or no user is logged in, return false
  if (!syncService.isInitialized || syncService.currentUserId == null) {
    return false;
  }

  // Reinitialize sync for the current user
  syncService.initializeSync(syncService.currentUserId!);

  // Return true to indicate sync was triggered
  return true;
});

/// Service for managing synchronization of all data types
class SyncService {
  final SettingsService _settingsService;
  final HighlightService _highlightService;
  final BookmarkService _bookmarkService;

  bool _isInitialized = false;
  String? _currentUserId;

  SyncService(this._settingsService, this._highlightService, this._bookmarkService);

  /// Initialize synchronization for a user
  void initializeSync(String userId) {
    if (_isInitialized && _currentUserId == userId) {
      return; // Already initialized for this user
    }

    // Clean up any existing subscriptions
    cleanupSync();

    // Store the current user ID
    _currentUserId = userId;

    // Subscribe to changes in user preferences
    _settingsService.subscribeToPreferencesChanges(
      userId,
      (prefs) {
        print('Received updated preferences from Appwrite: ${prefs.themeMode}, ${prefs.fontSize}, ${prefs.fontStyle}');
      },
    );

    // Subscribe to changes in highlights
    _highlightService.subscribeToHighlightChanges(userId);

    // Subscribe to changes in bookmarks
    _bookmarkService.subscribeToBookmarkChanges(userId);

    _isInitialized = true;
    print('Sync initialized for user: $userId');
  }

  /// Clean up all subscriptions
  void cleanupSync() {
    if (!_isInitialized) {
      return;
    }

    if (_currentUserId != null) {
      _settingsService.cancelSubscription(_currentUserId!);
      _highlightService.cancelSubscription(_currentUserId!);
      _bookmarkService.cancelSubscription(_currentUserId!);
    }

    _settingsService.cancelAllSubscriptions();
    _highlightService.cancelAllSubscriptions();
    _bookmarkService.cancelAllSubscriptions();

    _isInitialized = false;
    _currentUserId = null;
    print('Sync cleaned up');
  }

  /// Update user ID in local data
  Future<void> updateUserIdInLocalData(String userId) async {
    // This method is called when a user logs in to associate local data with the user
    // It updates the userId field in all local data that doesn't have a userId yet

    // TODO: Implement updating userId in local data
    // This would involve:
    // 1. Finding all user preferences, highlights, and bookmarks without a userId
    // 2. Updating them with the provided userId
    // 3. Syncing them to Appwrite
  }

  /// Check if sync is initialized
  bool get isInitialized => _isInitialized;

  /// Get the current user ID
  String? get currentUserId => _currentUserId;
}
