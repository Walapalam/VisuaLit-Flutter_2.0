// import 'package:appwrite/appwrite.dart';
// import 'package:flutter/material.dart';
// import 'package:isar/isar.dart';
// import 'package:mockito/mockito.dart';
// import 'package:visualit/core/models/syncable_entity.dart';
// import 'package:visualit/core/services/interfaces/i_logger_service.dart';
// import 'package:visualit/core/services/interfaces/i_sync_service.dart';
// import 'package:visualit/features/reader/application/interfaces/i_book_processor.dart';
// import 'package:visualit/features/reader/application/interfaces/i_page_render_service.dart';
// import 'package:visualit/features/reader/application/page_render_service.dart';
// import 'package:visualit/features/reader/data/book_data.dart';
// import 'package:visualit/features/reader/data/bookmark.dart';
// import 'package:visualit/features/reader/data/highlight.dart';
// import 'package:visualit/features/reader/data/page_cache.dart';
// import 'package:visualit/features/reader/data/reading_progress.dart';
//
// /// Mock implementation of ILoggerService for testing.
// class MockLoggerService extends Mock implements ILoggerService {}
//
// /// Mock implementation of ISyncService for testing.
// class MockSyncService extends Mock implements ISyncService {}
//
// /// Mock implementation of IBookProcessor for testing.
// class MockBookProcessor extends Mock implements IBookProcessor {}
//
// /// Mock implementation of IPageRenderService for testing.
// class MockPageRenderService extends Mock implements IPageRenderService {}
//
// /// Mock for Isar database
// class MockIsar extends Mock implements Isar {
//   @override
//   late IsarCollection<Highlight> highlights;
//   @override
//   late IsarCollection<Bookmark> bookmarks;
//   @override
//   late IsarCollection<ReadingProgress> readingProgresses;
//   @override
//   late IsarCollection<PageCache> pageCaches;
//
//   MockIsar() {
//     highlights = MockIsarCollection<Highlight>();
//     bookmarks = MockIsarCollection<Bookmark>();
//     readingProgresses = MockIsarCollection<ReadingProgress>();
//     pageCaches = MockIsarCollection<PageCache>();
//   }
// }
//
// /// Mock for IsarCollection
// class MockIsarCollection<T> extends Mock implements IsarCollection<T> {}
//
// /// Mock for Appwrite Databases
// class MockDatabases extends Mock implements Databases {}
//
// /// Mock for the original PageRenderService
// class MockOriginalPageRenderService extends Mock implements PageRenderService {
//   @override
//   final _isar = MockIsar();
// }
//
// /// Mock BuildContext for testing
// class MockBuildContext extends Mock implements BuildContext {}
//
// /// Mock for PageCache query builder
// class MockPageCacheQueryBuilder extends Mock implements QueryBuilder<PageCache, PageCache, QWhere> {
//   void mockFindAll(List<PageCache> result) {
//     when(findAll()).thenAnswer((_) async => result);
//   }
//
//   void mockFindFirst(T? result) {
//     when(findFirst()).thenAnswer((_) async => result);
//   }
// }
//
// /// Mock extensions for testing
// class MockIsarQueryBuilder<T> extends Mock implements QueryBuilder<T, T, QWhere> {
//   void mockFindAll(List<T> result) {
//     when(findAll()).thenAnswer((_) async => result);
//   }
//
//   void mockFindFirst(T? result) {
//     when(findFirst()).thenAnswer((_) async => result);
//   }
// }
//
// /// Helper method to set up the MockPageRenderService to return test data.
// void setupMockPageRenderService(MockPageRenderService mockService, List<PageMetadata> pages) {
//   when(mockService.getOrCalculatePages(
//     bookId: anyNamed('bookId'),
//     fontSize: anyNamed('fontSize'),
//     width: anyNamed('width'),
//     height: anyNamed('height'),
//     context: anyNamed('context'),
//   )).thenAnswer((_) async => pages);
//
//   when(mockService.clearCache(any)).thenAnswer((_) async => null);
// }
//
// /// Helper method to set up the MockSyncService to handle entity syncing.
// void setupMockSyncService(MockSyncService mockService) {
//   when(mockService.syncUserData()).thenAnswer((_) async => null);
//   when(mockService.syncEntity(any)).thenAnswer((_) async => null);
// }
//
// /// Helper method to set up the MockBookProcessor to handle book processing.
// void setupMockBookProcessor(MockBookProcessor mockProcessor) {
//   when(mockProcessor.processBook(any)).thenAnswer((_) async => null);
// }
//
// /// Helper method to create test PageMetadata objects.
// List<PageMetadata> createTestPages(int count, int bookId) {
//   return List.generate(count, (index) => PageMetadata(
//     pageIndex: index,
//     blockId: 1000 + index,
//     offsetInBlock: 0,
//     height: 500,
//   ));
// }
//
// /// Helper method to create a test Book object.
// Book createTestBook(int id, String? title, String? author) {
//   return Book()
//     ..id = id
//     ..title = title ?? "Default Title"
//     ..author = author ?? "Default Author"
//     ..status = ProcessingStatus.ready;
// }
//
// /// Helper method to create a test SyncableEntity.
// T createTestSyncableEntity<T extends SyncableEntity>(T entity) {
//   entity.syncId = 'test-sync-id-${DateTime.now().millisecondsSinceEpoch}';
//   entity.lastModified = DateTime.now();
//   entity.isDirty = true;
//   return entity;
// }
