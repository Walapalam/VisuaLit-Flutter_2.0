import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/services/sync_service.dart';

/// Observer that triggers sync operations based on app lifecycle events.
class SyncLifecycleObserver extends WidgetsBindingObserver {
  final Ref _ref;
  
  SyncLifecycleObserver(this._ref);
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App has come to the foreground, trigger sync
      _ref.read(syncProvider.future).catchError((e) {
        // Handle sync errors silently
        debugPrint('Sync error during lifecycle event: $e');
      });
    }
  }
}

/// Provider for the SyncLifecycleObserver.
final syncLifecycleObserverProvider = Provider<SyncLifecycleObserver>((ref) {
  final observer = SyncLifecycleObserver(ref);
  
  // Register the observer with WidgetsBinding
  WidgetsBinding.instance.addObserver(observer);
  
  // Dispose the observer when the provider is disposed
  ref.onDispose(() {
    WidgetsBinding.instance.removeObserver(observer);
  });
  
  return observer;
});