import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:appwrite/appwrite.dart';
import 'package:visualit/core/api/appwrite_client.dart';
import 'package:visualit/core/models/highlight_schema.dart';
import 'package:visualit/core/providers/isar_provider.dart';

/// Provider for the HighlightService
final highlightServiceProvider = Provider<HighlightService>((ref) {
  final isar = ref.watch(isarDBProvider).requireValue;
  final databases = ref.watch(appwriteDatabasesProvider);
  final realtime = ref.watch(appwriteRealtimeProvider);
  return HighlightService(isar, databases, realtime);
});

/// Service for managing highlights
class HighlightService {
  final Isar _isar;
  final Databases _databases;
  final Realtime _realtime;
  static const String _collectionId = 'highlights';
  static const String _databaseId = 'visualit';

  // Store active subscriptions to clean up when needed
  final Map<String, RealtimeSubscription> _subscriptions = {};

  HighlightService(this._isar, this._databases, this._realtime);

  /// Get all highlights for a book
  Stream<List<HighlightSchema>> watchBookHighlights(int bookId) {
    return _isar.highlightSchemas
        .filter()
        .bookIdEqualTo(bookId)
        .watch(fireImmediately: true);
  }

  /// Get all highlights for a chapter in a book
  Stream<List<HighlightSchema>> watchChapterHighlights(int bookId, int chapterIndex) {
    return _isar.highlightSchemas
        .filter()
        .bookIdEqualTo(bookId)
        .chapterIndexEqualTo(chapterIndex)
        .watch(fireImmediately: true);
  }

  /// Create a new highlight
  Future<int> createHighlight(HighlightSchema highlight) async {
    // Set timestamps
    highlight.createdAt = DateTime.now();
    highlight.updatedAt = DateTime.now();

    // Save to Isar
    final highlightId = await _isar.writeTxn(() async {
      return await _isar.highlightSchemas.put(highlight);
    });

    // Sync to Appwrite if user is authenticated
    if (highlight.userId != null) {
      await _syncHighlightToAppwrite(highlight);
    }

    return highlightId;
  }

  /// Update an existing highlight
  Future<void> updateHighlight(HighlightSchema highlight) async {
    // Update timestamp
    highlight.updatedAt = DateTime.now();

    // Save to Isar
    await _isar.writeTxn(() async {
      await _isar.highlightSchemas.put(highlight);
    });

    // Sync to Appwrite if user is authenticated
    if (highlight.userId != null) {
      await _syncHighlightToAppwrite(highlight);
    }
  }

  /// Delete a highlight
  Future<void> deleteHighlight(int highlightId) async {
    // Get the highlight first to check if it needs to be deleted from Appwrite
    final highlight = await _isar.highlightSchemas.get(highlightId);

    // Delete from Isar
    await _isar.writeTxn(() async {
      await _isar.highlightSchemas.delete(highlightId);
    });

    // Delete from Appwrite if user is authenticated
    if (highlight != null && highlight.userId != null) {
      try {
        await _databases.deleteDocument(
          databaseId: _databaseId,
          collectionId: _collectionId,
          documentId: highlightId.toString(),
        );
      } catch (e) {
        print('Error deleting highlight from Appwrite: $e');
      }
    }
  }

  /// Sync a highlight to Appwrite
  Future<void> _syncHighlightToAppwrite(HighlightSchema highlight) async {
    try {
      // Convert to map for Appwrite
      final highlightMap = {
        'userId': highlight.userId,
        'bookId': highlight.bookId,
        'chapterIndex': highlight.chapterIndex,
        'startBlockIndex': highlight.startBlockIndex,
        'endBlockIndex': highlight.endBlockIndex,
        'startOffset': highlight.startOffset,
        'endOffset': highlight.endOffset,
        'text': highlight.text,
        'color': highlight.color.index,
        'note': highlight.note,
        'updatedAt': highlight.updatedAt.millisecondsSinceEpoch,
      };

      // Check if document exists
      try {
        final existingDoc = await _databases.getDocument(
          databaseId: _databaseId,
          collectionId: _collectionId,
          documentId: highlight.id.toString(),
        );

        // Update if exists
        if (existingDoc.$id == highlight.id.toString()) {
          await _databases.updateDocument(
            databaseId: _databaseId,
            collectionId: _collectionId,
            documentId: highlight.id.toString(),
            data: highlightMap,
          );
        }
      } catch (e) {
        // Create if doesn't exist
        await _databases.createDocument(
          databaseId: _databaseId,
          collectionId: _collectionId,
          documentId: highlight.id.toString(),
          data: highlightMap,
        );
      }
    } catch (e) {
      print('Error syncing highlight to Appwrite: $e');
    }
  }

  /// Subscribe to changes in highlights for a user
  void subscribeToHighlightChanges(String userId) {
    // Cancel any existing subscription for this user
    if (_subscriptions.containsKey('highlights_$userId')) {
      _subscriptions['highlights_$userId']?.close();
      _subscriptions.remove('highlights_$userId');
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
          final highlightId = int.parse(payload['\$id']);

          // Get the local highlight
          _isar.highlightSchemas.get(highlightId).then((localHighlight) {
            // If we don't have local highlight or the remote update is newer, update local
            if (localHighlight == null || remoteUpdatedAt.isAfter(localHighlight.updatedAt)) {
              // Create updated highlight from remote data
              final updatedHighlight = HighlightSchema()
                ..id = highlightId
                ..userId = payload['userId']
                ..bookId = payload['bookId']
                ..chapterIndex = payload['chapterIndex']
                ..startBlockIndex = payload['startBlockIndex']
                ..endBlockIndex = payload['endBlockIndex']
                ..startOffset = payload['startOffset']
                ..endOffset = payload['endOffset']
                ..text = payload['text']
                ..color = HighlightColor.values[payload['color']]
                ..note = payload['note']
                ..createdAt = localHighlight?.createdAt ?? DateTime.now()
                ..updatedAt = remoteUpdatedAt;

              // Save to local database
              _isar.writeTxn(() async {
                await _isar.highlightSchemas.put(updatedHighlight);
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
            final int highlightId = int.parse(documentId);

            // Delete from local database
            _isar.writeTxn(() async {
              await _isar.highlightSchemas.delete(highlightId);
            });
          }
        } catch (e) {
          print('Error handling highlight deletion: $e');
        }
      }
    });

    // Store the subscription
    _subscriptions['highlights_$userId'] = subscription;
  }

  /// Cancel subscription for a user
  void cancelSubscription(String userId) {
    if (_subscriptions.containsKey('highlights_$userId')) {
      _subscriptions['highlights_$userId']?.close();
      _subscriptions.remove('highlights_$userId');
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
