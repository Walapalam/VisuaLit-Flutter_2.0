import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/audiobook_player/data/audiobook.dart';
import 'package:visualit/features/reader/data/highlight.dart'; // Import highlight schema
import 'package:visualit/features/reader/data/bookmark.dart'; // Import bookmark schema
import 'package:visualit/features/reader/data/layout_cache.dart'; // Import layout cache schema
import 'package:visualit/features/settings/data/user_settings.dart'; // Import user settings schema

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
          BookmarkSchema,
          UserSettingsSchema, // Add the user settings schema
          LayoutCacheSchema
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
