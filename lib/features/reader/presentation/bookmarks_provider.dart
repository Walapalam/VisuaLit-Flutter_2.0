import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/data/bookmark.dart';

// This provider returns a stream of all bookmarks for a specific bookId.
// The UI can subscribe to this to get real-time updates.
final bookmarksProvider = StreamProvider.family.autoDispose<List<Bookmark>, int>((ref, bookId) {
  debugPrint("[DEBUG] bookmarksProvider: Creating provider for bookId: $bookId");
  final isar = ref.watch(isarDBProvider).value;
  if (isar == null) {
    debugPrint("[DEBUG] bookmarksProvider: Isar is null, returning empty list");
    return Stream.value([]);
  }

  debugPrint("[DEBUG] bookmarksProvider: Creating stream for bookId: $bookId");

  return isar.bookmarks.where().bookIdEqualTo(bookId).watch(fireImmediately: true);
});

// This provider is used to add, update, or remove bookmarks
final bookmarksControllerProvider = Provider((ref) {
  debugPrint("[DEBUG] bookmarksControllerProvider: Creating controller");
  final isarFuture = ref.watch(isarDBProvider.future);

  return BookmarksController(isarFuture);
});

class BookmarksController {
  final Future<Isar> _isarFuture;

  BookmarksController(this._isarFuture);

  Future<void> addBookmark(int bookId, int pageNumber, {String? title, String? note}) async {
    debugPrint("[DEBUG] BookmarksController: Adding bookmark for bookId: $bookId, page: $pageNumber");
    try {
      final isar = await _isarFuture;

      final bookmark = Bookmark()
        ..bookId = bookId
        ..pageNumber = pageNumber
        ..title = title
        ..note = note;

      await isar.writeTxn(() async {
        final id = await isar.bookmarks.put(bookmark);
        debugPrint("[DEBUG] BookmarksController: Bookmark added with id: $id");
      });
    } catch (e) {
      debugPrint("[ERROR] BookmarksController: Failed to add bookmark: $e");
      rethrow;
    }
  }

  Future<void> removeBookmark(int bookmarkId) async {
    debugPrint("[DEBUG] BookmarksController: Removing bookmark with id: $bookmarkId");
    try {
      final isar = await _isarFuture;

      await isar.writeTxn(() async {
        final success = await isar.bookmarks.delete(bookmarkId);
        debugPrint("[DEBUG] BookmarksController: Bookmark removal success: $success");
      });
    } catch (e) {
      debugPrint("[ERROR] BookmarksController: Failed to remove bookmark: $e");
      rethrow;
    }
  }

  Future<int?> getBookmarkIdByPage(int bookId, int pageNumber) async {
    debugPrint("[DEBUG] BookmarksController: Getting bookmark ID for bookId: $bookId, page: $pageNumber");
    try {
      final isar = await _isarFuture;

      final bookmark = await isar.bookmarks
          .where()
          .bookIdEqualTo(bookId)
          .filter()
          .pageNumberEqualTo(pageNumber)
          .findFirst();

      debugPrint("[DEBUG] BookmarksController: Found bookmark ID: ${bookmark?.id}");
      return bookmark?.id;
    } catch (e) {
      debugPrint("[ERROR] BookmarksController: Failed to get bookmark ID: $e");
      rethrow;
    }
  }

  Future<bool> isPageBookmarked(int bookId, int pageNumber) async {
    debugPrint("[DEBUG] BookmarksController: Checking if page is bookmarked - bookId: $bookId, page: $pageNumber");
    try {
      final isar = await _isarFuture;

      final bookmark = await isar.bookmarks
          .where()
          .bookIdEqualTo(bookId)
          .filter()
          .pageNumberEqualTo(pageNumber)
          .findFirst();

      final isBookmarked = bookmark != null;
      debugPrint("[DEBUG] BookmarksController: Page is bookmarked: $isBookmarked");
      return isBookmarked;
    } catch (e) {
      debugPrint("[ERROR] BookmarksController: Failed to check if page is bookmarked: $e");
      return false;
    }
  }
}
