import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:appwrite/appwrite.dart';
import 'package:visualit/core/api/appwrite_client.dart';
import 'package:visualit/core/models/bookmark_schema.dart';
import 'package:visualit/core/providers/isar_provider.dart';

/// Provider for the BookmarkService
final bookmarkServiceProvider = Provider<BookmarkService>((ref) {
  final isar = ref.watch(isarDBProvider).requireValue;
  final databases = ref.watch(appwriteDatabasesProvider);
  final realtime = ref.watch(appwriteRealtimeProvider);
  return BookmarkService(isar, databases, realtime);
});

/// Service for managing bookmarks
class BookmarkService {
  final Isar _isar;
  final Databases _databases;
  final Realtime _realtime;
  static const String _collectionId = 'bookmarks';
  static const String _databaseId = 'visualit';

  // Store active subscriptions to clean up when needed
  final Map<String, RealtimeSubscription> _subscriptions = {};

  BookmarkService(this._isar, this._databases, this._realtime);

  /// Get all bookmarks for a book
  Stream<List<BookmarkSchema>> watchBookBookmarks(int bookId) {
    return _isar.bookmarkSchemas
        .filter()
        .bookIdEqualTo(bookId)
        .watch(fireImmediately: true);
  }

  /// Create a new bookmark
  Future<int> createBookmark(BookmarkSchema bookmark) async {
    // Set timestamps
    bookmark.createdAt = DateTime.now();
    bookmark.updatedAt = DateTime.now();

    // Save to Isar
    final bookmarkId = await _isar.writeTxn(() async {
      return await _isar.bookmarkSchemas.put(bookmark);
    });

    // Sync to Appwrite if user is authenticated
    if (bookmark.userId != null) {
      await _syncBookmarkToAppwrite(bookmark);
    }

    return bookmarkId;
  }

  /// Update an existing bookmark
  Future<void> updateBookmark(BookmarkSchema bookmark) async {
    // Update timestamp
    bookmark.updatedAt = DateTime.now();

    // Save to Isar
    await _isar.writeTxn(() async {
      await _isar.bookmarkSchemas.put(bookmark);
    });

    // Sync to Appwrite if user is authenticated
    if (bookmark.userId != null) {
      await _syncBookmarkToAppwrite(bookmark);
    }
  }

  /// Delete a bookmark
  Future<void> deleteBookmark(int bookmarkId) async {
    // Get the bookmark first to check if it needs to be deleted from Appwrite
    final bookmark = await _isar.bookmarkSchemas.get(bookmarkId);

    // Delete from Isar
    await _isar.writeTxn(() async {
      await _isar.bookmarkSchemas.delete(bookmarkId);
    });

    // Delete from Appwrite if user is authenticated
    if (bookmark != null && bookmark.userId != null) {
      try {
        await _databases.deleteDocument(
          databaseId: _databaseId,
          collectionId: _collectionId,
          documentId: bookmarkId.toString(),
        );
      } catch (e) {
        print('Error deleting bookmark from Appwrite: $e');
      }
    }
  }

  /// Sync a bookmark to Appwrite
  Future<void> _syncBookmarkToAppwrite(BookmarkSchema bookmark) async {
    try {
      // Convert to map for Appwrite
      final bookmarkMap = {
        'userId': bookmark.userId,
        'bookId': bookmark.bookId,
        'chapterIndex': bookmark.chapterIndex,
        'blockIndex': bookmark.blockIndex,
        'pageNumber': bookmark.pageNumber,
        'title': bookmark.title,
        'textSnippet': bookmark.textSnippet,
        'updatedAt': bookmark.updatedAt.millisecondsSinceEpoch,
      };

      // Check if document exists
      try {
        final existingDoc = await _databases.getDocument(
          databaseId: _databaseId,
          collectionId: _collectionId,
          documentId: bookmark.id.toString(),
        );

        // Update if exists
        if (existingDoc.$id == bookmark.id.toString()) {
          await _databases.updateDocument(
            databaseId: _databaseId,
            collectionId: _collectionId,
            documentId: bookmark.id.toString(),
            data: bookmarkMap,
          );
        }
      } catch (e) {
        // Create if doesn't exist
        await _databases.createDocument(
          databaseId: _databaseId,
          collectionId: _collectionId,
          documentId: bookmark.id.toString(),
          data: bookmarkMap,
        );
      }
    } catch (e) {
      print('Error syncing bookmark to Appwrite: $e');
    }
  }

  /// Subscribe to changes in bookmarks for a user
  void subscribeToBookmarkChanges(String userId) {
    // Cancel any existing subscription for this user
    if (_subscriptions.containsKey('bookmarks_$userId')) {
      _subscriptions['bookmarks_$userId']?.close();
      _subscriptions.remove('bookmarks_$userId');
    }

    // Create a new subscription
    final subscription = _realtime.subscribe([
      'databases.$_databaseId.collections.$_collectionId.documents'
    ]);

    subscription.stream.listen((response) {
      if (response.events.contains('databases.*.collections.*.documents.*.update') ||
          response.events.contains('databases.*.collections.*.documents.*.create')) {

        // Extract the updated data
        final payload = response.payload;

        // Only process if this is for the current user
        if (payload['userId'] == userId) {
          // Check if this is a newer update than what we have locally
          final remoteUpdatedAt = DateTime.fromMillisecondsSinceEpoch(payload['updatedAt']);
          final bookmarkId = int.parse(payload['\$id']);

          // Get the local bookmark
          _isar.bookmarkSchemas.get(bookmarkId).then((localBookmark) {
            // If we don't have local bookmark or the remote update is newer, update local
            if (localBookmark == null || remoteUpdatedAt.isAfter(localBookmark.updatedAt)) {
              // Create updated bookmark from remote data
              final updatedBookmark = BookmarkSchema()
                ..id = bookmarkId
                ..userId = payload['userId']
                ..bookId = payload['bookId']
                ..chapterIndex = payload['chapterIndex']
                ..blockIndex = payload['blockIndex']
                ..pageNumber = payload['pageNumber']
                ..title = payload['title']
                ..textSnippet = payload['textSnippet']
                ..createdAt = localBookmark?.createdAt ?? DateTime.now()
                ..updatedAt = remoteUpdatedAt;

              // Save to local database
              _isar.writeTxn(() async {
                await _isar.bookmarkSchemas.put(updatedBookmark);
              });
            }
          });
        }
      } else if (response.events.contains('databases.*.collections.*.documents.*.delete')) {
        // Handle deletion
        // For delete events, we need to extract the document ID from the event
        // Since we can't access it directly, we'll extract it from the payload
        try {
          // Try to get the document ID from the payload
          final Map<String, dynamic> payload = response.payload;
          if (payload.containsKey('\$id')) {
            final String documentId = payload['\$id'].toString();
            final int bookmarkId = int.parse(documentId);

            // Delete from local database
            _isar.writeTxn(() async {
              await _isar.bookmarkSchemas.delete(bookmarkId);
            });
          }
        } catch (e) {
          print('Error handling bookmark deletion: $e');
        }
      }
    });

    // Store the subscription
    _subscriptions['bookmarks_$userId'] = subscription;
  }

  /// Cancel subscription for a user
  void cancelSubscription(String userId) {
    if (_subscriptions.containsKey('bookmarks_$userId')) {
      _subscriptions['bookmarks_$userId']?.close();
      _subscriptions.remove('bookmarks_$userId');
    }
  }

  /// Cancel all subscriptions
  void cancelAllSubscriptions() {
    for (final subscription in _subscriptions.values) {
      subscription.close();
    }
    _subscriptions.clear();
  }
}
