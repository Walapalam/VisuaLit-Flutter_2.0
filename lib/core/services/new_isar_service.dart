import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:visualit/core/models/book_schema.dart';
import 'package:visualit/core/models/content_block_schema.dart';
import 'package:visualit/core/models/toc_entry_schema.dart';
import 'package:visualit/core/models/user_preferences_schema.dart';
import 'package:visualit/core/models/highlight_schema.dart';
import 'package:visualit/core/models/bookmark_schema.dart';

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
          BookSchemaSchema,
          ContentBlockSchemaSchema,
          TOCEntrySchemaSchema,
          UserPreferencesSchemaSchema,
          HighlightSchemaSchema,
          BookmarkSchemaSchema,
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
