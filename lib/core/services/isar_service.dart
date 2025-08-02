import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/audiobook_player/data/audiobook.dart';
import 'package:visualit/features/reader/data/highlight.dart';
import 'package:visualit/features/reader/data/chapter.dart' as ReadingChapter;
import 'package:visualit/features/reader/data/reading_progress.dart';
import 'package:visualit/features/reader/data/page_cache.dart';
import 'package:visualit/features/reader/data/search_index.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<void> closeDB() async {
    final isar = await db;
    await isar.close();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [
          BookSchema,
          ContentBlockSchema,
          AudiobookSchema,
          HighlightSchema,
          ReadingChapter.ChapterSchema,
          ReadingProgressSchema,
          PageCacheSchema
        ],
        directory: dir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }

  Future<void> clearDB() async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.clear();
    });
  }
}
