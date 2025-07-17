import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/audiobook_player/data/audiobook.dart';
import 'package:visualit/features/reader/data/highlight.dart';
import 'package:visualit/features/reader/data/bookmark.dart';

class IsarService {
  late Future<Isar> _db;
  static const String _instanceName = 'main_instance';

  IsarService() {
    debugPrint("[DEBUG] IsarService: Initializing service with instance name: $_instanceName");
    _db = _openDB();
  }

  /// Closes the database instance if it exists.
  Future<void> closeDB() async {
    debugPrint("[DEBUG] IsarService: Closing database");
    try {
      final isar = await _db;
      if (isar.isOpen) {
        await isar.close();
        debugPrint("[DEBUG] IsarService: Database closed successfully");
      } else {
        debugPrint("[DEBUG] IsarService: Database already closed");
      }
    } catch (e, stack) {
      debugPrint("[ERROR] IsarService: Failed to close database: $e");
      debugPrintStack(stackTrace: stack);
      // Do not rethrow to prevent app crashes; log and continue
    }
  }

  /// Opens a named Isar instance, reusing an existing one if available.
  Future<Isar> _openDB() async {
    debugPrint("[DEBUG] IsarService: Opening database with instance name: $_instanceName");
    try {
      final existingInstance = Isar.getInstance(_instanceName);
      if (existingInstance == null) {
        debugPrint("[DEBUG] IsarService: No existing Isar instance found, creating new one");
        final dir = await getApplicationDocumentsDirectory();
        debugPrint("[DEBUG] IsarService: Using directory: ${dir.path}");

        final isar = await Isar.open(
          [
            BookSchema,
            ContentBlockSchema,
            AudiobookSchema,
            HighlightSchema,
            BookmarkSchema,
          ],
          directory: dir.path,
          name: _instanceName,
          inspector: true,
        );

        debugPrint("[DEBUG] IsarService: Database opened successfully with new instance");
        return isar;
      }

      debugPrint("[DEBUG] IsarService: Using existing Isar instance");
      if (!existingInstance.isOpen) {
        debugPrint("[ERROR] IsarService: Existing instance is closed");
        throw Exception("Failed to retrieve open Isar instance: $_instanceName");
      }
      debugPrint("[DEBUG] IsarService: Database opened successfully with existing instance");
      return existingInstance;
    } catch (e, stack) {
      debugPrint("[ERROR] IsarService: Failed to open database: $e");
      debugPrintStack(stackTrace: stack);
      throw Exception("Failed to open Isar database: $e");
    }
  }

  /// Returns the resolved Isar instance, ensuring it's open.
  Future<Isar> getDB() async {
    try {
      final isar = await _db;
      if (!isar.isOpen) {
        debugPrint("[DEBUG] IsarService: Database closed, reopening");
        _db = _openDB(); // Reinitialize if closed
        return await _db;
      }
      return isar;
    } catch (e, stack) {
      debugPrint("[ERROR] IsarService: Failed to get database: $e");
      debugPrintStack(stackTrace: stack);
      throw Exception("Failed to get Isar database: $e");
    }
  }

  /// Clears all data in the database.
  Future<void> clearDB() async {
    debugPrint("[DEBUG] IsarService: Clearing database");
    try {
      final isar = await getDB();
      await isar.writeTxn(() async {
        await isar.clear();
        debugPrint("[DEBUG] IsarService: Database cleared successfully");
      });
    } catch (e, stack) {
      debugPrint("[ERROR] IsarService: Failed to clear database: $e");
      debugPrintStack(stackTrace: stack);
      throw Exception("Failed to clear Isar database: $e");
    }
  }

  /// Retrieves database statistics for debugging.
  Future<Map<String, int>> getDBStats() async {
    debugPrint("[DEBUG] IsarService: Getting database statistics for instance: $_instanceName");
    try {
      final isar = await getDB();
      final stats = <String, int>{};

      stats['books'] = await isar.books.count();
      stats['contentBlocks'] = await isar.contentBlocks.count();
      stats['audiobooks'] = await isar.audiobooks.count();
      stats['highlights'] = await isar.highlights.count();
      stats['bookmarks'] = await isar.bookmarks.count();

      debugPrint("[DEBUG] IsarService: Database statistics: $stats");
      return stats;
    } catch (e, stack) {
      debugPrint("[ERROR] IsarService: Failed to get database statistics: $e");
      debugPrintStack(stackTrace: stack);
      return {};
    }
  }
}
