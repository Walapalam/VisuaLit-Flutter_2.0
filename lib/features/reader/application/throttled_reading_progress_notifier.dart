import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/data/reading_progress.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/streaks/providers/streak_providers.dart';

/// Provider for the current book ID
final currentBookIdProvider = StateProvider<int?>((ref) => null);

/// Provider for the reading session start time
final readingSessionStartProvider = StateProvider<DateTime?>((ref) => null);

/// Provider for the throttled reading progress notifier
final readingProgressProvider =
    AsyncNotifierProvider<ThrottledReadingProgressNotifier, ReadingProgress?>(
      () => ThrottledReadingProgressNotifier(),
    );

/// A notifier that throttles reading progress updates to avoid performance issues.
class ThrottledReadingProgressNotifier extends AsyncNotifier<ReadingProgress?> {
  Timer? _debounceTimer;
  ReadingProgress? _pendingProgress;

  @override
  Future<ReadingProgress?> build() async {
    // Load initial reading progress
    final bookId = ref.watch(currentBookIdProvider);
    if (bookId == null) return null;

    final isar = ref.watch(isarDBProvider).requireValue;
    return await isar.readingProgress.where().bookIdEqualTo(bookId).findFirst();
  }

  /// Update the reading progress with debouncing.
  /// This method updates the state immediately for UI responsiveness,
  /// but debounces the database write to avoid excessive updates.
  Future<void> updateProgress(ReadingProgress progress) async {
    // Store the latest progress
    _pendingProgress = progress;

    // Cancel existing timer
    _debounceTimer?.cancel();

    // Set new timer
    _debounceTimer = Timer(const Duration(seconds: 2), () {
      _saveProgress();
    });

    // Update state immediately for UI
    state = AsyncData(_pendingProgress);
  }

  /// Save the pending progress to the database.
  Future<void> _saveProgress() async {
    if (_pendingProgress == null) return;

    final progress = _pendingProgress!;
    _pendingProgress = null;

    final isar = ref.read(isarDBProvider).requireValue;
    await isar.writeTxn(() async {
      await isar.readingProgress.put(progress);
    });

    // Update book's last read timestamp
    await isar.writeTxn(() async {
      final book = await isar.books.get(progress.bookId);
      if (book != null) {
        book.lastReadPage = progress.pageIndex;
        book.lastReadTimestamp = DateTime.now();
        book.lastAccessedAt = DateTime.now();
        await isar.books.put(book);
      }
    });

    // Track reading time for streaks
    final sessionStart = ref.read(readingSessionStartProvider);
    if (sessionStart != null) {
      final minutesRead = DateTime.now().difference(sessionStart).inMinutes;
      final secondsRead = DateTime.now().difference(sessionStart).inSeconds;

      print(
        '⏱️  Reading Time: ${minutesRead} min ${secondsRead % 60} sec (threshold: 1 min)',
      );

      if (minutesRead > 0) {
        try {
          final streakService = ref.read(streakServiceProvider);
          await streakService.recordReadingSession(minutesRead);
          print('✅ Streak Updated: Recorded $minutesRead minutes of reading');
        } catch (e) {
          print('⚠️ Failed to record streak: $e');
        }
      } else {
        print('⏳ Not enough time yet: ${secondsRead} seconds (need 60)');
      }
    } else {
      print('❌ No session start time found!');
    }

    print(
      "✅ [ThrottledReadingProgressNotifier] Saved reading progress for book ${progress.bookId}, page ${progress.pageIndex}",
    );
  }
}
