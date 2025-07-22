import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/services/sync_service.dart';

/// A provider that tracks the current sync status
final syncStatusProvider = StateProvider<SyncStatus>((ref) {
  return SyncStatus.idle;
});

/// Possible states for sync operations
enum SyncStatus {
  idle,
  syncing,
  success,
  error,
}

/// A widget that displays the current sync status
class SyncStatusIndicator extends ConsumerWidget {
  final bool showText;
  final double size;

  const SyncStatusIndicator({
    super.key,
    this.showText = true,
    this.size = 16.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(syncStatusProvider);

    // Listen to sync operations and update status
    ref.listen(syncProvider, (previous, next) {
      if (next.isLoading) {
        ref.read(syncStatusProvider.notifier).state = SyncStatus.syncing;
      } else if (next.hasError) {
        ref.read(syncStatusProvider.notifier).state = SyncStatus.error;
        // Reset to idle after a delay
        // Use a local variable to capture the notifier
        final notifier = ref.read(syncStatusProvider.notifier);
        Future.delayed(const Duration(seconds: 3), () {
          notifier.state = SyncStatus.idle;
        });
      } else if (next.hasValue) {
        ref.read(syncStatusProvider.notifier).state = SyncStatus.success;
        // Reset to idle after a delay
        // Use a local variable to capture the notifier
        final notifier = ref.read(syncStatusProvider.notifier);
        Future.delayed(const Duration(seconds: 2), () {
          notifier.state = SyncStatus.idle;
        });
      }
    });

    // Define icon and color based on status
    IconData icon;
    Color color;
    String text;

    switch (syncStatus) {
      case SyncStatus.idle:
        icon = Icons.cloud_done;
        color = Colors.grey;
        text = 'Synced';
        break;
      case SyncStatus.syncing:
        icon = Icons.sync;
        color = Colors.blue;
        text = 'Syncing...';
        break;
      case SyncStatus.success:
        icon = Icons.cloud_done;
        color = Colors.green;
        text = 'Synced';
        break;
      case SyncStatus.error:
        icon = Icons.cloud_off;
        color = Colors.red;
        text = 'Sync failed';
        break;
    }

    // Create a row with icon and optional text
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        syncStatus == SyncStatus.syncing
            ? SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              )
            : Icon(
                icon,
                color: color,
                size: size,
              ),
        if (showText) ...[
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: size * 0.75,
            ),
          ),
        ],
      ],
    );
  }
}

/// A button that triggers manual sync
class SyncButton extends ConsumerWidget {
  const SyncButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(syncStatusProvider);
    final isLoading = syncStatus == SyncStatus.syncing;

    return IconButton(
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            )
          : const Icon(Icons.sync),
      onPressed: isLoading
          ? null
          : () {
              // Trigger manual sync
              ref.invalidate(syncProvider);
            },
      tooltip: 'Sync now',
    );
  }
}
