import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:visualit/core/api/appwrite_client.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/data/bookmark.dart';
import 'package:visualit/features/reader/data/highlight.dart';
import 'package:visualit/features/settings/data/user_settings.dart';

/// Service for synchronizing data with Appwrite
class SyncService {
  final Isar _isar;
  final Databases _databases;
  final RealtimeSubscription? _subscription;

  // Appwrite collection IDs
  static const String _databaseId = 'visualit';
  static const String _booksCollectionId = 'books';
  static const String _highlightsCollectionId = 'highlights';
  static const String _bookmarksCollectionId = 'bookmarks';
  static const String _settingsCollectionId = 'settings';

  SyncService(this._isar, this._databases, this._subscription) {
    // Initialize the sync service
    initialize();
  }

  /// Initialize the sync service
  Future<void> initialize() async {
    // Subscribe to real-time updates
    _setupRealtimeSubscription();
  }

  /// Set up real-time subscription to Appwrite collections
  void _setupRealtimeSubscription() {
    if (_subscription == null) return;

    try {
      // Listen for events
      _subscription!.stream.listen(
        (event) {
          if (event.events.contains('databases.*.collections.*.documents.*.create') ||
              event.events.contains('databases.*.collections.*.documents.*.update')) {
            _handleIncomingChange(event);
          }
        },
        onError: (error) {
          print('Error in real-time subscription: $error');
        },
        onDone: () {
          print('Real-time subscription closed');
        },
      );
    } catch (e) {
      print('Error setting up real-time subscription: $e');
    }
  }

  /// Handle incoming change from Appwrite
  Future<void> _handleIncomingChange(RealtimeMessage event) async {
    final payload = event.payload;
    if (payload == null) return;

    final String collectionId = event.payload['\$collectionId'] ?? '';
    final DateTime updatedAt = DateTime.parse(event.payload['updatedAt'] ?? DateTime.now().toIso8601String());
    final String documentId = event.payload['\$id'] ?? '';

    // Handle based on collection type
    switch (collectionId) {
      case _booksCollectionId:
        await _handleBookChange(documentId, payload, updatedAt);
        break;
      case _highlightsCollectionId:
        await _handleHighlightChange(documentId, payload, updatedAt);
        break;
      case _bookmarksCollectionId:
        await _handleBookmarkChange(documentId, payload, updatedAt);
        break;
      case _settingsCollectionId:
        await _handleSettingsChange(documentId, payload, updatedAt);
        break;
    }
  }

  /// Handle book change from Appwrite
  Future<void> _handleBookChange(String documentId, Map<String, dynamic> payload, DateTime updatedAt) async {
    // Find the book in the local database by serverId
    final localBook = await _isar.books.filter().serverIdEqualTo(documentId).findFirst();

    if (localBook != null) {
      // Check if the server version is newer
      if (localBook.updatedAt.isBefore(updatedAt)) {
        await _isar.writeTxn(() async {
          // Update the local book with the server data
          localBook.title = payload['title'];
          localBook.author = payload['author'];
          localBook.lastReadPage = payload['lastReadPage'] ?? 0;
          localBook.updatedAt = updatedAt;
          await _isar.books.put(localBook);
        });
      } else {
        // Local version is newer, push it to the server
        await _pushBookToServer(localBook);
      }
    } else {
      // Book doesn't exist locally, create it if it has a valid epubFilePath
      if (payload['epubFilePath'] != null) {
        final newBook = Book()
          ..epubFilePath = payload['epubFilePath']
          ..title = payload['title']
          ..author = payload['author']
          ..lastReadPage = payload['lastReadPage'] ?? 0
          ..updatedAt = updatedAt
          ..serverId = documentId;

        await _isar.writeTxn(() async {
          await _isar.books.put(newBook);
        });
      }
    }
  }

  /// Handle highlight change from Appwrite
  Future<void> _handleHighlightChange(String documentId, Map<String, dynamic> payload, DateTime updatedAt) async {
    // Find the highlight in the local database by serverId
    final localHighlight = await _isar.highlights.filter().serverIdEqualTo(documentId).findFirst();

    if (localHighlight != null) {
      // Check if the server version is newer
      if (localHighlight.updatedAt.isBefore(updatedAt)) {
        await _isar.writeTxn(() async {
          // Update the local highlight with the server data
          localHighlight.text = payload['text'];
          localHighlight.color = payload['color'];
          localHighlight.note = payload['note'];
          localHighlight.updatedAt = updatedAt;
          await _isar.highlights.put(localHighlight);
        });
      } else {
        // Local version is newer, push it to the server
        await _pushHighlightToServer(localHighlight);
      }
    } else {
      // Highlight doesn't exist locally, create it
      final newHighlight = Highlight()
        ..bookId = payload['bookId']
        ..chapterIndex = payload['chapterIndex']
        ..blockIndexInChapter = payload['blockIndexInChapter']
        ..text = payload['text']
        ..startOffset = payload['startOffset']
        ..endOffset = payload['endOffset']
        ..color = payload['color']
        ..note = payload['note']
        ..updatedAt = updatedAt
        ..serverId = documentId;

      await _isar.writeTxn(() async {
        await _isar.highlights.put(newHighlight);
      });
    }
  }

  /// Handle bookmark change from Appwrite
  Future<void> _handleBookmarkChange(String documentId, Map<String, dynamic> payload, DateTime updatedAt) async {
    // Find the bookmark in the local database by serverId
    final localBookmark = await _isar.bookmarks.filter().serverIdEqualTo(documentId).findFirst();

    if (localBookmark != null) {
      // Check if the server version is newer
      if (localBookmark.updatedAt.isBefore(updatedAt)) {
        await _isar.writeTxn(() async {
          // Update the local bookmark with the server data
          localBookmark.title = payload['title'];
          localBookmark.note = payload['note'];
          localBookmark.pageNumber = payload['pageNumber'];
          localBookmark.updatedAt = updatedAt;
          await _isar.bookmarks.put(localBookmark);
        });
      } else {
        // Local version is newer, push it to the server
        await _pushBookmarkToServer(localBookmark);
      }
    } else {
      // Bookmark doesn't exist locally, create it
      final newBookmark = Bookmark()
        ..bookId = payload['bookId']
        ..chapterIndex = payload['chapterIndex']
        ..blockIndexInChapter = payload['blockIndexInChapter']
        ..pageNumber = payload['pageNumber']
        ..title = payload['title']
        ..note = payload['note']
        ..updatedAt = updatedAt
        ..serverId = documentId;

      await _isar.writeTxn(() async {
        await _isar.bookmarks.put(newBookmark);
      });
    }
  }

  /// Handle settings change from Appwrite
  Future<void> _handleSettingsChange(String documentId, Map<String, dynamic> payload, DateTime updatedAt) async {
    // Find the settings in the local database by serverId
    final localSettings = await _isar.userSettings.filter().serverIdEqualTo(documentId).findFirst();

    if (localSettings != null) {
      // Check if the server version is newer
      if (localSettings.updatedAt.isBefore(updatedAt)) {
        await _isar.writeTxn(() async {
          // Update the local settings with the server data
          localSettings.fontSize = payload['fontSize'];
          localSettings.lineSpacing = payload['lineSpacing'];
          localSettings.themeMode = payload['themeMode'];
          localSettings.pageColor = payload['pageColor'];
          localSettings.textColor = payload['textColor'];
          localSettings.fontFamily = payload['fontFamily'];
          localSettings.updatedAt = updatedAt;
          await _isar.userSettings.put(localSettings);
        });
      } else {
        // Local version is newer, push it to the server
        await _pushSettingsToServer(localSettings);
      }
    } else {
      // Settings don't exist locally, create them
      final newSettings = UserSettings()
        ..fontSize = payload['fontSize']
        ..lineSpacing = payload['lineSpacing']
        ..themeMode = payload['themeMode']
        ..pageColor = payload['pageColor']
        ..textColor = payload['textColor']
        ..fontFamily = payload['fontFamily']
        ..updatedAt = updatedAt
        ..serverId = documentId;

      await _isar.writeTxn(() async {
        await _isar.userSettings.put(newSettings);
      });
    }
  }

  /// Push a book to the server
  Future<void> _pushBookToServer(Book book) async {
    try {
      final data = {
        'epubFilePath': book.epubFilePath,
        'title': book.title,
        'author': book.author,
        'lastReadPage': book.lastReadPage,
        'updatedAt': book.updatedAt.toIso8601String(),
      };

      if (book.serverId != null) {
        // Update existing document
        await _databases.updateDocument(
          databaseId: _databaseId,
          collectionId: _booksCollectionId,
          documentId: book.serverId!,
          data: data,
        );
      } else {
        // Create new document
        final result = await _databases.createDocument(
          databaseId: _databaseId,
          collectionId: _booksCollectionId,
          documentId: ID.unique(),
          data: data,
        );

        // Update the book with the server ID
        await _isar.writeTxn(() async {
          book.serverId = result.$id;
          await _isar.books.put(book);
        });
      }
    } catch (e) {
      print('Error pushing book to server: $e');
    }
  }

  /// Push a highlight to the server
  Future<void> _pushHighlightToServer(Highlight highlight) async {
    try {
      final data = {
        'bookId': highlight.bookId,
        'chapterIndex': highlight.chapterIndex,
        'blockIndexInChapter': highlight.blockIndexInChapter,
        'text': highlight.text,
        'startOffset': highlight.startOffset,
        'endOffset': highlight.endOffset,
        'color': highlight.color,
        'note': highlight.note,
        'updatedAt': highlight.updatedAt.toIso8601String(),
      };

      if (highlight.serverId != null) {
        // Update existing document
        await _databases.updateDocument(
          databaseId: _databaseId,
          collectionId: _highlightsCollectionId,
          documentId: highlight.serverId!,
          data: data,
        );
      } else {
        // Create new document
        final result = await _databases.createDocument(
          databaseId: _databaseId,
          collectionId: _highlightsCollectionId,
          documentId: ID.unique(),
          data: data,
        );

        // Update the highlight with the server ID
        await _isar.writeTxn(() async {
          highlight.serverId = result.$id;
          await _isar.highlights.put(highlight);
        });
      }
    } catch (e) {
      print('Error pushing highlight to server: $e');
    }
  }

  /// Push a bookmark to the server
  Future<void> _pushBookmarkToServer(Bookmark bookmark) async {
    try {
      final data = {
        'bookId': bookmark.bookId,
        'chapterIndex': bookmark.chapterIndex,
        'blockIndexInChapter': bookmark.blockIndexInChapter,
        'pageNumber': bookmark.pageNumber,
        'title': bookmark.title,
        'note': bookmark.note,
        'updatedAt': bookmark.updatedAt.toIso8601String(),
      };

      if (bookmark.serverId != null) {
        // Update existing document
        await _databases.updateDocument(
          databaseId: _databaseId,
          collectionId: _bookmarksCollectionId,
          documentId: bookmark.serverId!,
          data: data,
        );
      } else {
        // Create new document
        final result = await _databases.createDocument(
          databaseId: _databaseId,
          collectionId: _bookmarksCollectionId,
          documentId: ID.unique(),
          data: data,
        );

        // Update the bookmark with the server ID
        await _isar.writeTxn(() async {
          bookmark.serverId = result.$id;
          await _isar.bookmarks.put(bookmark);
        });
      }
    } catch (e) {
      print('Error pushing bookmark to server: $e');
    }
  }

  /// Push settings to the server
  Future<void> _pushSettingsToServer(UserSettings settings) async {
    try {
      final data = {
        'fontSize': settings.fontSize,
        'lineSpacing': settings.lineSpacing,
        'themeMode': settings.themeMode.index,
        'pageColor': settings.pageColor,
        'textColor': settings.textColor,
        'fontFamily': settings.fontFamily,
        'updatedAt': settings.updatedAt.toIso8601String(),
      };

      if (settings.serverId != null) {
        // Update existing document
        await _databases.updateDocument(
          databaseId: _databaseId,
          collectionId: _settingsCollectionId,
          documentId: settings.serverId!,
          data: data,
        );
      } else {
        // Create new document
        final result = await _databases.createDocument(
          databaseId: _databaseId,
          collectionId: _settingsCollectionId,
          documentId: ID.unique(),
          data: data,
        );

        // Update the settings with the server ID
        await _isar.writeTxn(() async {
          settings.serverId = result.$id;
          await _isar.userSettings.put(settings);
        });
      }
    } catch (e) {
      print('Error pushing settings to server: $e');
    }
  }

  /// Sync all local changes with the server
  Future<void> syncAll() async {
    // Sync books
    final books = await _isar.books.where().findAll();
    for (final book in books) {
      await _pushBookToServer(book);
    }

    // Sync highlights
    final highlights = await _isar.highlights.where().findAll();
    for (final highlight in highlights) {
      await _pushHighlightToServer(highlight);
    }

    // Sync bookmarks
    final bookmarks = await _isar.bookmarks.where().findAll();
    for (final bookmark in bookmarks) {
      await _pushBookmarkToServer(bookmark);
    }

    // Sync settings
    final settings = await _isar.userSettings.where().findAll();
    for (final setting in settings) {
      await _pushSettingsToServer(setting);
    }
  }

  /// Dispose the sync service
  void dispose() {
    _subscription?.close();
  }
}

/// Provider for the SyncService
final syncServiceProvider = Provider<SyncService>((ref) {
  final isar = ref.watch(isarDBProvider).value!;
  final databases = ref.watch(appwriteDatabasesProvider);
  final client = ref.watch(appwriteClientProvider);

  // Create a realtime subscription
  final realtime = Realtime(client);
  final subscription = realtime.subscribe([
    'databases.visualit.collections.books.documents',
    'databases.visualit.collections.highlights.documents',
    'databases.visualit.collections.bookmarks.documents',
    'databases.visualit.collections.settings.documents',
  ]);

  final syncService = SyncService(isar, databases, subscription);

  // Dispose the sync service when the provider is disposed
  ref.onDispose(() {
    syncService.dispose();
  });

  return syncService;
});
