import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart' hide Query;
import 'package:uuid/uuid.dart';
import 'package:visualit/core/api/appwrite_client.dart';
import 'package:visualit/core/models/syncable_entity.dart';
import 'package:visualit/core/providers/logger_provider.dart';
import 'package:visualit/core/services/isar_service.dart';
import 'package:visualit/core/services/interfaces/i_logger_service.dart';
import 'package:visualit/core/services/interfaces/i_sync_service.dart';
import 'package:visualit/features/auth/data/auth_repository.dart';
import 'package:visualit/features/auth/presentation/auth_controller.dart';
import 'package:visualit/features/reader/data/bookmark.dart';
import 'package:visualit/features/reader/data/highlight.dart';
import 'package:visualit/features/reader/data/reading_progress.dart';

import '../providers/isar_provider.dart';

/// Service for synchronizing data between local Isar database and Appwrite.
class SyncService implements ISyncService {
  final Isar _isar;
  final Databases _databases;
  final String? _userId;
  final ILoggerService _logger;
  final Uuid _uuid = const Uuid();

  // Appwrite collection IDs
  static const String _highlightsCollectionId = 'highlights';
  static const String _bookmarksCollectionId = 'bookmarks';
  static const String _readingProgressCollectionId = 'reading_progress';

  // Appwrite database ID
  static const String _databaseId = 'visualit';

  SyncService(this._isar, this._databases, this._userId, this._logger);

  /// Synchronizes all user data between local database and Appwrite.
  @override
  Future<void> syncUserData() async {
    if (_userId == null) {
      // User is not logged in, can't sync
      _logger.info('User not logged in, skipping sync', tag: 'SyncService');
      return;
    }

    try {
      _logger.info('Starting sync for user $_userId', tag: 'SyncService');
      // Sync all entity types
      await _syncEntities<Highlight>(_highlightsCollectionId);
      await _syncEntities<Bookmark>(_bookmarksCollectionId);
      await _syncEntities<ReadingProgress>(_readingProgressCollectionId);
      _logger.info('Sync completed successfully', tag: 'SyncService');
    } catch (e, stackTrace) {
      // Handle sync errors
      _logger.error('Sync error: $e', tag: 'SyncService', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Synchronizes a specific entity to remote storage.
  @override
  Future<void> syncEntity(dynamic entity) async {
    if (_userId == null) {
      _logger.info('User not logged in, skipping entity sync', tag: 'SyncService');
      return;
    }

    if (entity is! SyncableEntity) {
      _logger.error('Entity is not a SyncableEntity: ${entity.runtimeType}', tag: 'SyncService');
      throw ArgumentError('Entity must be a SyncableEntity');
    }

    try {
      _logger.info('Syncing entity of type ${entity.runtimeType}', tag: 'SyncService');

      String collectionId;
      if (entity is Highlight) {
        collectionId = _highlightsCollectionId;
      } else if (entity is Bookmark) {
        collectionId = _bookmarksCollectionId;
      } else if (entity is ReadingProgress) {
        collectionId = _readingProgressCollectionId;
      } else {
        _logger.error('Unsupported entity type: ${entity.runtimeType}', tag: 'SyncService');
        throw ArgumentError('Unsupported entity type: ${entity.runtimeType}');
      }

      // Ensure entity has a syncId
      if (entity.syncId == null) {
        entity.syncId = _uuid.v4();
      }

      // Convert entity to a map for Appwrite
      final Map<String, dynamic> data = _entityToMap(entity);
      data['userId'] = _userId;

      try {
        // Check if document already exists in Appwrite
        await _databases.getDocument(
          databaseId: _databaseId,
          collectionId: collectionId,
          documentId: entity.syncId!,
        );

        // Document exists, update it
        await _databases.updateDocument(
          databaseId: _databaseId,
          collectionId: collectionId,
          documentId: entity.syncId!,
          data: data,
        );
        _logger.info('Updated entity in Appwrite', tag: 'SyncService');
      } catch (e) {
        // Document doesn't exist, create it
        await _databases.createDocument(
          databaseId: _databaseId,
          collectionId: collectionId,
          documentId: entity.syncId!,
          data: data,
        );
        _logger.info('Created entity in Appwrite', tag: 'SyncService');
      }

      // Mark entity as not dirty after successful sync
      entity.isDirty = false;
      await _updateEntity(entity);

    } catch (e, stackTrace) {
      _logger.error('Error syncing entity: $e', tag: 'SyncService', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Synchronizes entities of a specific type.
  Future<void> _syncEntities<T extends SyncableEntity>(String collectionId) async {
    await _pushDirtyEntities<T>(collectionId);
    await _pullRemoteEntities<T>(collectionId);
  }

  /// Pushes local dirty entities to Appwrite.
  Future<void> _pushDirtyEntities<T extends SyncableEntity>(String collectionId) async {
    // Get all dirty entities from local database
    final dirtyEntities = await _getDirtyEntities<T>();

    for (final entity in dirtyEntities) {
      // Ensure entity has a syncId
      if (entity.syncId == null) {
        entity.syncId = _uuid.v4();
      }

      try {
        // Convert entity to a map for Appwrite
        final Map<String, dynamic> data = _entityToMap(entity);
        data['userId'] = _userId;

        // Check if document already exists in Appwrite
        try {
          await _databases.getDocument(
            databaseId: _databaseId,
            collectionId: collectionId,
            documentId: entity.syncId!,
          );

          // Document exists, update it
          await _databases.updateDocument(
            databaseId: _databaseId,
            collectionId: collectionId,
            documentId: entity.syncId!,
            data: data,
          );
        } catch (e) {
          // Document doesn't exist, create it
          await _databases.createDocument(
            databaseId: _databaseId,
            collectionId: collectionId,
            documentId: entity.syncId!,
            data: data,
          );
        }

        // Mark entity as not dirty after successful sync
        entity.isDirty = false;
        await _updateEntity(entity);
      } catch (e, stackTrace) {
        _logger.error('Error pushing entity to Appwrite: $e', tag: 'SyncService', stackTrace: stackTrace);
        // Continue with next entity
      }
    }
  }

  /// Pulls remote entities from Appwrite and updates local database.
  Future<void> _pullRemoteEntities<T extends SyncableEntity>(String collectionId) async {
    try {
      // Get all documents for this user from Appwrite
      final result = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: collectionId,
        queries: [
          Query.equal('userId', _userId!),
        ],
      );

      for (final document in result.documents) {
        final remoteEntity = _documentToEntity<T>(document);

        // Check if entity exists locally
        final localEntity = await _getEntityBySyncId<T>(remoteEntity.syncId!);

        if (localEntity != null) {
          // Entity exists locally, resolve conflicts
          _resolveConflict(localEntity, remoteEntity);
        } else {
          // Entity doesn't exist locally, add it
          await _addEntity(remoteEntity);
        }
      }
    } catch (e, stackTrace) {
      _logger.error('Error pulling entities from Appwrite: $e', tag: 'SyncService', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Resolves conflicts between local and remote entities.
  void _resolveConflict<T extends SyncableEntity>(T local, T remote) {
    // If local is dirty, it means it has changes that haven't been synced yet
    if (local.isDirty) {
      // If remote is newer, use remote and mark as not dirty
      if (remote.lastModified.isAfter(local.lastModified)) {
        _copyEntityProperties(remote, local);
        local.isDirty = false;
        _updateEntity(local);
      } else {
        // Local is newer, keep local and it will be pushed in the next sync
      }
    } else {
      // Local is not dirty, just update with remote data
      _copyEntityProperties(remote, local);
      _updateEntity(local);
    }
  }

  /// Gets all dirty entities of a specific type from local database.
  Future<List<T>> _getDirtyEntities<T extends SyncableEntity>() async {
    if (T == Highlight) {
      return _isar.highlights
          .filter()
          .isDirtyEqualTo(true)
          .findAll() as Future<List<T>>;
    } else if (T == Bookmark) {
      return _isar.bookmarks
          .filter()
          .isDirtyEqualTo(true)
          .findAll() as Future<List<T>>;
    } else if (T == ReadingProgress) {
      return _isar.readingProgress
          .filter()
          .isDirtyEqualTo(true)
          .findAll() as Future<List<T>>;
    }

    return [];
  }

  /// Gets an entity by its syncId.
  Future<T?> _getEntityBySyncId<T extends SyncableEntity>(String syncId) async {
    if (T == Highlight) {
      return _isar.highlights
          .filter()
          .syncIdEqualTo(syncId)
          .findFirst() as Future<T?>;
    } else if (T == Bookmark) {
      return _isar.bookmarks
          .filter()
          .syncIdEqualTo(syncId)
          .findFirst() as Future<T?>;
    } else if (T == ReadingProgress) {
      return _isar.readingProgress
          .filter()
          .syncIdEqualTo(syncId)
          .findFirst() as Future<T?>;
    }

    return null;
  }

  /// Updates an entity in the local database.
  Future<void> _updateEntity<T extends SyncableEntity>(T entity) async {
    await _isar.writeTxn(() async {
      if (T == Highlight) {
        await _isar.highlights.put(entity as Highlight);
      } else if (T == Bookmark) {
        await _isar.bookmarks.put(entity as Bookmark);
      } else if (T == ReadingProgress) {
        await _isar.readingProgress.put(entity as ReadingProgress);
      }
    });
  }

  /// Adds an entity to the local database.
  Future<void> _addEntity<T extends SyncableEntity>(T entity) async {
    await _isar.writeTxn(() async {
      if (T == Highlight) {
        await _isar.highlights.put(entity as Highlight);
      } else if (T == Bookmark) {
        await _isar.bookmarks.put(entity as Bookmark);
      } else if (T == ReadingProgress) {
        await _isar.readingProgress.put(entity as ReadingProgress);
      }
    });
  }

  /// Converts an entity to a map for Appwrite.
  Map<String, dynamic> _entityToMap<T extends SyncableEntity>(T entity) {
    if (T == Highlight) {
      final highlight = entity as Highlight;
      return {
        'bookId': highlight.bookId,
        'chapterIndex': highlight.chapterIndex,
        'blockIndexInChapter': highlight.blockIndexInChapter,
        'text': highlight.text,
        'startOffset': highlight.startOffset,
        'endOffset': highlight.endOffset,
        'color': highlight.color,
        'timestamp': highlight.timestamp.toIso8601String(),
        'note': highlight.note,
        'syncId': highlight.syncId,
        'lastModified': highlight.lastModified.toIso8601String(),
      };
    } else if (T == Bookmark) {
      final bookmark = entity as Bookmark;
      return {
        'bookId': bookmark.bookId,
        'chapterIndex': bookmark.chapterIndex,
        'pageIndex': bookmark.pageIndex,
        'scrollPosition': bookmark.scrollPosition,
        'title': bookmark.title,
        'createdAt': bookmark.createdAt.toIso8601String(),
        'syncId': bookmark.syncId,
        'lastModified': bookmark.lastModified.toIso8601String(),
      };
    } else if (T == ReadingProgress) {
      final progress = entity as ReadingProgress;
      return {
        'bookId': progress.bookId,
        'pageIndex': progress.pageIndex,
        'scrollPosition': progress.scrollPosition,
        'lastUpdated': progress.lastUpdated.toIso8601String(),
        'syncId': progress.syncId,
        'lastModified': progress.lastModified.toIso8601String(),
      };
    }

    return {};
  }

  /// Converts an Appwrite document to an entity.
  T _documentToEntity<T extends SyncableEntity>(models.Document document) {
    if (T == Highlight) {
      final highlight = Highlight()
        ..bookId = document.data['bookId']
        ..chapterIndex = document.data['chapterIndex']
        ..blockIndexInChapter = document.data['blockIndexInChapter']
        ..text = document.data['text']
        ..startOffset = document.data['startOffset']
        ..endOffset = document.data['endOffset']
        ..color = document.data['color']
        ..timestamp = DateTime.parse(document.data['timestamp'])
        ..note = document.data['note']
        ..syncId = document.data['syncId']
        ..lastModified = DateTime.parse(document.data['lastModified'])
        ..isDirty = false;
      return highlight as T;
    } else if (T == Bookmark) {
      final bookmark = Bookmark(
        bookId: document.data['bookId'],
        chapterIndex: document.data['chapterIndex'],
        pageIndex: document.data['pageIndex'],
        scrollPosition: document.data['scrollPosition'],
        title: document.data['title'],
      )
        ..createdAt = DateTime.parse(document.data['createdAt'])
        ..syncId = document.data['syncId']
        ..lastModified = DateTime.parse(document.data['lastModified'])
        ..isDirty = false;
      return bookmark as T;
    } else if (T == ReadingProgress) {
      final progress = ReadingProgress(
        bookId: document.data['bookId'],
        pageIndex: document.data['pageIndex'],
        scrollPosition: document.data['scrollPosition'],
      )
        ..lastUpdated = DateTime.parse(document.data['lastUpdated'])
        ..syncId = document.data['syncId']
        ..lastModified = DateTime.parse(document.data['lastModified'])
        ..isDirty = false;
      return progress as T;
    }

    throw Exception('Unsupported entity type: $T');
  }

  /// Copies properties from source entity to target entity.
  void _copyEntityProperties<T extends SyncableEntity>(T source, T target) {
    if (T == Highlight) {
      final sourceHighlight = source as Highlight;
      final targetHighlight = target as Highlight;

      targetHighlight.bookId = sourceHighlight.bookId;
      targetHighlight.chapterIndex = sourceHighlight.chapterIndex;
      targetHighlight.blockIndexInChapter = sourceHighlight.blockIndexInChapter;
      targetHighlight.text = sourceHighlight.text;
      targetHighlight.startOffset = sourceHighlight.startOffset;
      targetHighlight.endOffset = sourceHighlight.endOffset;
      targetHighlight.color = sourceHighlight.color;
      targetHighlight.timestamp = sourceHighlight.timestamp;
      targetHighlight.note = sourceHighlight.note;
      targetHighlight.lastModified = sourceHighlight.lastModified;
    } else if (T == Bookmark) {
      final sourceBookmark = source as Bookmark;
      final targetBookmark = target as Bookmark;

      targetBookmark.bookId = sourceBookmark.bookId;
      targetBookmark.chapterIndex = sourceBookmark.chapterIndex;
      targetBookmark.pageIndex = sourceBookmark.pageIndex;
      targetBookmark.scrollPosition = sourceBookmark.scrollPosition;
      targetBookmark.title = sourceBookmark.title;
      targetBookmark.createdAt = sourceBookmark.createdAt;
      targetBookmark.lastModified = sourceBookmark.lastModified;
    } else if (T == ReadingProgress) {
      final sourceProgress = source as ReadingProgress;
      final targetProgress = target as ReadingProgress;

      targetProgress.bookId = sourceProgress.bookId;
      targetProgress.pageIndex = sourceProgress.pageIndex;
      targetProgress.scrollPosition = sourceProgress.scrollPosition;
      targetProgress.lastUpdated = sourceProgress.lastUpdated;
      targetProgress.lastModified = sourceProgress.lastModified;
    }
  }
}

/// Provider for the SyncService.
final syncServiceProvider = Provider<ISyncService>((ref) {
  final isarService = ref.watch(isarProvider);
  final databases = ref.watch(appwriteDatabasesProvider);
  final authState = ref.watch(authControllerProvider);
  final logger = ref.watch(loggerServiceProvider);

  // For now, pass null as userId to avoid the error
  // In a real implementation, you would extract the user ID from authState.user
  final userId = null;

  // We can't use async in a Provider, so we need to handle this differently
  return SyncService(
    // Access the Isar instance synchronously if available, or use a placeholder
    Isar.getInstance() ?? Isar.getInstance('default')!,
    databases, 
    userId, 
    logger
  );
});

/// Provider for triggering sync operations.
final syncProvider = FutureProvider<void>((ref) async {
  final syncService = ref.watch(syncServiceProvider);
  await syncService.syncUserData();
});
