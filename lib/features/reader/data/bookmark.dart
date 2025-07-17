import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

part 'bookmark.g.dart';

@collection
class Bookmark {
  Id id = Isar.autoIncrement;

  @Index()
  late int bookId;

  /// The page number where the bookmark is placed.
  @Index()
  late int pageNumber;

  /// Optional title for the bookmark.
  String? title;

  /// Optional note for the bookmark.
  String? note;

  /// Timestamp when the bookmark was created.
  DateTime timestamp = DateTime.now();
}

// Extension methods for debugging
extension BookmarkDebug on Bookmark {
  // Log the bookmark details
  void debugLog() {
    debugPrint("[DEBUG] Bookmark: id: $id, bookId: $bookId, page: $pageNumber");
    if (title != null) {
      debugPrint("[DEBUG] Bookmark: title: '$title'");
    }
    if (note != null && note!.isNotEmpty) {
      debugPrint("[DEBUG] Bookmark: note: '${note!.length > 50 ? '${note!.substring(0, 47)}...' : note}'");
    }
    debugPrint("[DEBUG] Bookmark: timestamp: $timestamp");
  }

  // Get a string representation of the bookmark
  String toDebugString() {
    return "Bookmark(id: $id, bookId: $bookId, page: $pageNumber, " +
           "title: ${title != null ? "'$title'" : 'null'}, " +
           "timestamp: $timestamp)";
  }
}

// Static helper methods for debugging
class BookmarkUtils {
  // Log a list of bookmarks
  static void debugLogBookmarks(List<Bookmark> bookmarks, [String message = ""]) {
    debugPrint("[DEBUG] BookmarkUtils: $message - ${bookmarks.length} bookmarks");
    for (int i = 0; i < bookmarks.length; i++) {
      debugPrint("[DEBUG] BookmarkUtils: [$i] ${bookmarks[i].toDebugString()}");
    }
  }

  // Create a debug bookmark for testing
  static Bookmark createDebugBookmark({
    int id = 0,
    required int bookId,
    required int pageNumber,
    String? title,
    String? note,
  }) {
    debugPrint("[DEBUG] BookmarkUtils: Creating debug bookmark for bookId: $bookId, page: $pageNumber");
    final bookmark = Bookmark()
      ..id = id
      ..bookId = bookId
      ..pageNumber = pageNumber
      ..title = title
      ..note = note
      ..timestamp = DateTime.now();

    return bookmark;
  }
}
