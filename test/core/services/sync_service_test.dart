/*
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:uuid/uuid.dart';
import 'package:visualit/core/services/interfaces/i_logger_service.dart';
import 'package:visualit/core/services/interfaces/i_sync_service.dart';
import 'package:visualit/core/services/sync_service.dart';
import 'package:visualit/features/reader/data/bookmark.dart';
import 'package:visualit/features/reader/data/highlight.dart';
import 'package:visualit/features/reader/data/new_reading_progress.dart';

import '../../mocks/mock_services.dart';
import 'sync_service_test.mocks.dart';

@GenerateMocks([Isar, Databases])
void main() {
  late MockIsar mockIsar;
  late MockDatabases mockDatabases;
  late MockLoggerService mockLogger;
  late ISyncService syncService;
  const String userId = 'test-user-id';

  setUp(() {
    mockIsar = MockIsar();
    mockDatabases = MockDatabases();
    mockLogger = MockLoggerService();
    syncService = SyncService(mockIsar, mockDatabases, userId, mockLogger);
  });

  group('SyncService', () {
    test('syncUserData should not sync if user is not logged in', () async {
      // Create a SyncService with null userId
      final localSyncService = SyncService(mockIsar, mockDatabases, null, mockLogger);

      // Call syncUserData
      await localSyncService.syncUserData();

      // Verify that no database operations were performed
      verifyZeroInteractions(mockDatabases);

      // Verify that a log message was created
      verify(mockLogger.info(any, tag: any)).called(1);
    });

    test('syncEntity should sync a single entity', () async {
      // Create a highlight to sync
      final highlight = Highlight()
        ..bookId = 1
        ..text = 'Test highlight for direct sync'
        ..startOffset = 0
        ..endOffset = 30
        ..color = 0xFF0000FF
        ..isDirty = true;

      // Mock the Appwrite createDocument method
      when(mockDatabases.getDocument(
        databaseId: anyNamed('databaseId'),
        collectionId: anyNamed('collectionId'),
        documentId: anyNamed('documentId'),
      )).thenThrow(Exception('Document not found'));

      when(mockDatabases.createDocument(
        databaseId: anyNamed('databaseId'),
        collectionId: anyNamed('collectionId'),
        documentId: anyNamed('documentId'),
        data: anyNamed('data'),
      )).thenAnswer((_) async => models.Document(
        $id: 'test-doc-id',
        $collectionId: 'highlights',
        $databaseId: 'visualit',
        $createdAt: '2023-01-01T00:00:00.000Z',
        $updatedAt: '2023-01-01T00:00:00.000Z',
        $permissions: [],
        data: {},
      ));

      // Call syncEntity
      await syncService.syncEntity(highlight);

      // Verify that createDocument was called
      verify(mockDatabases.createDocument(
        databaseId: 'visualit',
        collectionId: 'highlights',
        documentId: any,
        data: any,
      )).called(1);

      // Verify that the highlight is no longer dirty
      expect(highlight.isDirty, false);

      // Verify that log messages were created
      verify(mockLogger.info(any, tag: any)).called(greaterThan(0));
    });

    test('_pushDirtyEntities should push dirty highlights to Appwrite', () async {
      // Create a dirty highlight
      final highlight = Highlight()
        ..bookId = 1
        ..text = 'Test highlight'
        ..startOffset = 0
        ..endOffset = 13
        ..color = 0xFF0000FF
        ..isDirty = true;

      // Mock the _getDirtyEntities method to return the highlight
      when(mockIsar.highlights.filter()).thenReturn(
        MockIsarQueryBuilder<Highlight>()
          ..mockFindAll([highlight]),
      );

      // Mock the Appwrite createDocument method
      when(mockDatabases.getDocument(
        databaseId: anyNamed('databaseId'),
        collectionId: anyNamed('collectionId'),
        documentId: anyNamed('documentId'),
      )).thenThrow(Exception('Document not found'));

      when(mockDatabases.createDocument(
        databaseId: anyNamed('databaseId'),
        collectionId: anyNamed('collectionId'),
        documentId: anyNamed('documentId'),
        data: anyNamed('data'),
      )).thenAnswer((_) async => models.Document(
        $id: 'test-doc-id',
        $collectionId: 'highlights',
        $databaseId: 'visualit',
        $createdAt: '2023-01-01T00:00:00.000Z',
        $updatedAt: '2023-01-01T00:00:00.000Z',
        $permissions: [],
        data: {},
      ));

      // Call _pushDirtyEntities
      await syncService.syncUserData();

      // Verify that createDocument was called
      verify(mockDatabases.createDocument(
        databaseId: 'visualit',
        collectionId: 'highlights',
        documentId: any,
        data: any,
      )).called(1);

      // Verify that the highlight is no longer dirty
      expect(highlight.isDirty, false);
    });

    test('_pullRemoteEntities should pull remote entities from Appwrite', () async {
      // Mock the Appwrite listDocuments method
      final document = models.Document(
        $id: 'test-doc-id',
        $collectionId: 'highlights',
        $databaseId: 'visualit',
        $createdAt: '2023-01-01T00:00:00.000Z',
        $updatedAt: '2023-01-01T00:00:00.000Z',
        $permissions: [],
        data: {
          'bookId': 1,
          'text': 'Remote highlight',
          'startOffset': 0,
          'endOffset': 15,
          'color': 0xFF00FF00,
          'timestamp': '2023-01-01T00:00:00.000Z',
          'syncId': 'test-sync-id',
          'lastModified': '2023-01-01T00:00:00.000Z',
        },
      );

      when(mockDatabases.listDocuments(
        databaseId: anyNamed('databaseId'),
        collectionId: anyNamed('collectionId'),
        queries: anyNamed('queries'),
      )).thenAnswer((_) async => models.DocumentList(
        documents: [document],
        total: 1,
      ));

      // Mock the _getEntityBySyncId method to return null (entity doesn't exist locally)
      when(mockIsar.highlights.filter()).thenReturn(
        MockIsarQueryBuilder<Highlight>()
          ..mockFindFirst(null),
      );

      // Call syncUserData
      await syncService.syncUserData();

      // Verify that listDocuments was called
      verify(mockDatabases.listDocuments(
        databaseId: 'visualit',
        collectionId: 'highlights',
        queries: any,
      )).called(1);

      // Verify that the entity was added to the local database
      verify(mockIsar.writeTxn(any)).called(greaterThan(0));
    });

    test('_resolveConflict should use remote entity if it is newer', () async {
      // Create a local entity
      final localEntity = Highlight()
        ..bookId = 1
        ..text = 'Local highlight'
        ..startOffset = 0
        ..endOffset = 14
        ..color = 0xFF0000FF
        ..lastModified = DateTime(2023, 1, 1)
        ..isDirty = true;

      // Create a remote entity that is newer
      final remoteEntity = Highlight()
        ..bookId = 1
        ..text = 'Remote highlight'
        ..startOffset = 0
        ..endOffset = 15
        ..color = 0xFF00FF00
        ..lastModified = DateTime(2023, 1, 2)
        ..isDirty = false;

      // Call _resolveConflict
      syncService._resolveConflict(localEntity, remoteEntity);

      // Verify that the local entity was updated with remote data
      expect(localEntity.text, 'Remote highlight');
      expect(localEntity.endOffset, 15);
      expect(localEntity.color, 0xFF00FF00);
      expect(localEntity.isDirty, false);
    });

    test('_resolveConflict should keep local entity if it is newer', () async {
      // Create a local entity that is newer
      final localEntity = Highlight()
        ..bookId = 1
        ..text = 'Local highlight'
        ..startOffset = 0
        ..endOffset = 14
        ..color = 0xFF0000FF
        ..lastModified = DateTime(2023, 1, 2)
        ..isDirty = true;

      // Create a remote entity
      final remoteEntity = Highlight()
        ..bookId = 1
        ..text = 'Remote highlight'
        ..startOffset = 0
        ..endOffset = 15
        ..color = 0xFF00FF00
        ..lastModified = DateTime(2023, 1, 1)
        ..isDirty = false;

      // Call _resolveConflict
      syncService._resolveConflict(localEntity, remoteEntity);

      // Verify that the local entity was not updated
      expect(localEntity.text, 'Local highlight');
      expect(localEntity.endOffset, 14);
      expect(localEntity.color, 0xFF0000FF);
      expect(localEntity.isDirty, true);
    });
  });
}

// Mock extensions for testing
extension MockIsarQueryBuilderExtension<T> on MockIsarQueryBuilder<T> {
  void mockFindAll(List<T> result) {
    when(findAll()).thenAnswer((_) async => result);
  }

  void mockFindFirst(T? result) {
    when(findFirst()).thenAnswer((_) async => result);
  }
}

class MockIsarQueryBuilder<T> extends Mock implements QueryBuilder<T, T, QWhere> {}
*/
