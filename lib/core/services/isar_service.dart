// lib/core/services/isar_service.dart

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:visualit/features/reader/data/book_data.dart';        // Book & ContentBlock
import 'package:visualit/features/audiobook_player/data/audiobook.dart';
import 'package:visualit/features/reader/data/highlight.dart';
import 'package:visualit/features/reader/data/chapter.dart';
import 'package:visualit/features/reader/data/reading_progress.dart';
import 'package:visualit/features/reader/data/page_cache.dart';
import 'package:visualit/features/reader/data/search_index.dart';     // If used later

class IsarService {
  /// Future holding the Isar database instance
  late Future<Isar> db;

  /// Constructor: initializes the database instance
  IsarService() {
    db = openDB();
  }

  /// Opens and returns the Isar database instance
  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [
          BookSchema,
          ContentBlockSchema,
          AudiobookSchema,
          HighlightSchema,
          ChapterSchema,
          ReadingProgressSchema,
          PageCacheSchema,
        ],
        directory: dir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }

  /// Closes the Isar instance if open
  Future<void> closeDB() async {
    final isar = await db;
    if (isar.isOpen) {
      await isar.close();
    }
  }

  /// Clears all collections in the database (useful for development)
  Future<void> clearDB() async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.clear();
    });
  }
}
