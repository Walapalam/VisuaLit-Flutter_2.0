import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/services/storage_service.dart';
import 'package:visualit/features/reader/data/new_models.dart';

/// Provider for the StorageService
final storageProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// Provider for all books
final allBooksProvider = StreamProvider<List<Book>>((ref) {
  final storage = ref.watch(storageProvider);
  return storage.watchAllBooks();
});

/// Provider for a specific book
final bookProvider = FutureProvider.family<Book?, int>((ref, bookId) async {
  final storage = ref.watch(storageProvider);
  return storage.getBook(bookId);
});

/// Provider for content blocks of a specific book
final contentBlocksProvider = FutureProvider.family<List<ContentBlock>, int>((ref, bookId) async {
  final storage = ref.watch(storageProvider);
  return storage.getContentBlocksForBook(bookId);
});

/// Provider for highlights of a specific book
final highlightsProvider = StreamProvider.family<List<Highlight>, int>((ref, bookId) {
  final storage = ref.watch(storageProvider);
  return storage.watchHighlightsForBook(bookId);
});