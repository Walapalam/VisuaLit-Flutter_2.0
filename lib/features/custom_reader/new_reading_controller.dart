import 'dart:developer';
import 'package:isar/isar.dart';
import 'package:visualit/features/custom_reader/model/new_reading_progress.dart';

class NewReadingController {
  final Isar _isar;

  NewReadingController(this._isar);

  Isar get isar => _isar;

  Future<NewReadingProgress?> loadProgress(int bookId) async {
    log('Loading progress for bookId: $bookId', name: 'NewReadingController');
    final progress = await _isar.collection<NewReadingProgress>().filter().bookIdEqualTo(bookId).findFirst();
    if (progress != null) {
      log('Progress loaded: ChapterHref=${progress.lastChapterHref}, ScrollOffset=${progress.lastScrollOffset}', name: 'NewReadingController');
    } else {
      log('No progress found for bookId: $bookId', name: 'NewReadingController');
    }
    return progress;
  }

  Future<void> saveProgress(int bookId, String chapterHref, double scrollOffset) async {
    log('Saving progress for bookId: $bookId, ChapterHref=$chapterHref, ScrollOffset=$scrollOffset', name: 'NewReadingController');
    final existingProgress = await _isar
        .collection<NewReadingProgress>()
        .filter()
        .bookIdEqualTo(bookId)
        .findFirst();

    final progress = existingProgress ?? NewReadingProgress()
      ..bookId = bookId;

    progress
      ..lastChapterHref = chapterHref
      ..lastScrollOffset = scrollOffset;

    await _isar.writeTxn(() async {
      await _isar.collection<NewReadingProgress>().put(progress);
    });

    log('Progress saved for bookId: $bookId', name: 'NewReadingController');
  }
}
