import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/services/sync_service.dart';

/// Provider for the SyncLifecycleObserver
final syncLifecycleObserverProvider = Provider<SyncLifecycleObserver>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  final observer = SyncLifecycleObserver(syncService);
  
  // Register the observer with the WidgetsBinding instance
  WidgetsBinding.instance.addObserver(observer);
  
  // Dispose the observer when the provider is disposed
  ref.onDispose(() {
    WidgetsBinding.instance.removeObserver(observer);
  });
  
  return observer;
});

/// A lifecycle observer that triggers sync operations when the app lifecycle changes
class SyncLifecycleObserver extends WidgetsBindingObserver {
  final SyncService _syncService;
  
  SyncLifecycleObserver(this._syncService);
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // When the app resumes from background, trigger a sync if a user is logged in
    if (state == AppLifecycleState.resumed) {
      if (_syncService.isInitialized && _syncService.currentUserId != null) {
        print('App resumed, triggering sync for user: ${_syncService.currentUserId}');
        _syncService.initializeSync(_syncService.currentUserId!);
      }
    }
    
    // When the app is paused (going to background), clean up resources
    if (state == AppLifecycleState.paused) {
      print('App paused, cleaning up sync resources');
      // We don't fully clean up here to allow for quick resume,
      // but we could implement partial cleanup if needed
    }
  }
}