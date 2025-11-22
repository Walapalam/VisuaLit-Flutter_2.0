import 'dart:developer';
import 'package:isar/isar.dart';
import 'package:visualit/features/custom_reader/model/new_reading_progress.dart';
import 'package:visualit/features/streaks/services/streak_service.dart';
import 'package:visualit/features/reader/data/book_data.dart';

class NewReadingController {
  final Isar _isar;

  NewReadingController(this._isar);

  Isar get isar => _isar;

  Future<NewReadingProgress?> loadProgress(int bookId) async {
    log('Loading progress for bookId: $bookId', name: 'NewReadingController');
    final progress = await _isar
        .collection<NewReadingProgress>()
        .filter()
        .bookIdEqualTo(bookId)
        .findFirst();
    if (progress != null) {
      log(
        'Progress loaded: ChapterHref=${progress.lastChapterHref}, ScrollOffset=${progress.lastScrollOffset}',
        name: 'NewReadingController',
      );
    } else {
      log(
        'No progress found for bookId: $bookId',
        name: 'NewReadingController',
      );
    }
    return progress;
  }

  Future<void> saveProgress(
    int bookId,
    String chapterHref,
    double scrollOffset, {
    DateTime? sessionStart,
  }) async {
    log(
      'Saving progress for bookId: $bookId, ChapterHref=$chapterHref, ScrollOffset=$scrollOffset',
      name: 'NewReadingController',
    );

    // Perform the entire read-modify-write operation within a single transaction
    // to prevent race conditions.
    await _isar.writeTxn(() async {
      // First, try to find an existing progress record for this bookId.
      var progress = await _isar
          .collection<NewReadingProgress>()
          .filter()
          .bookIdEqualTo(bookId)
          .findFirst();

      if (progress == null) {
        // If no record exists, create a new one.
        progress = NewReadingProgress()..bookId = bookId;
      }

      // Update the properties of the (either existing or new) record.
      progress
        ..lastChapterHref = chapterHref
        ..lastScrollOffset = scrollOffset;

      // 'put' will either insert the new record or update the existing one
      // because we are reusing the 'Id' if it exists.
      await _isar.collection<NewReadingProgress>().put(progress);
      log(
        'Progress record saved with id: ${progress.id}',
        name: 'NewReadingController',
      );

      // Update book's last read timestamp
      final book = await _isar.books.get(bookId);
      if (book != null) {
        book.lastReadTimestamp = DateTime.now();
        book.lastAccessedAt = DateTime.now();
        await _isar.books.put(book);
        log('Updated book lastReadTimestamp', name: 'NewReadingController');
      }
    });

    log(
      'Progress saved successfully for bookId: $bookId',
      name: 'NewReadingController',
    );

    // Track reading time for streaks
    if (sessionStart != null) {
      final minutesRead = DateTime.now().difference(sessionStart).inMinutes;
      final secondsRead = DateTime.now().difference(sessionStart).inSeconds;

      print(
        '⏱️  Reading Time: ${minutesRead} min ${secondsRead % 60} sec (threshold: 1 min)',
      );

      if (minutesRead > 0) {
        try {
          final streakService = StreakService(_isar);
          await streakService.recordReadingSession(minutesRead);
          print('✅ Streak Updated: Recorded $minutesRead minutes of reading');
        } catch (e) {
          print('⚠️ Failed to record streak: $e');
        }
      } else {
        print('⏳ Not enough time yet: ${secondsRead} seconds (need 60)');
      }
    } else {
      print('❌ No session start time provided to saveProgress!');
    }
  }
}
