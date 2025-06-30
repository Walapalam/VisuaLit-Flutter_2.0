import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/models/book.dart';
import 'package:visualit/features/library/data/local_library_service.dart';

// StateNotifier for managing the library state
class LibraryController extends StateNotifier<AsyncValue<List<Book>>> {
  final LocalLibraryService _localLibraryService;

  LibraryController(this._localLibraryService) : super(const AsyncValue.loading()) {
    _loadCachedBooks();
  }

  Future<void> _loadCachedBooks() async {
    try {
      final books = await _localLibraryService.loadBooksFromCache();
      state = AsyncValue.data(books);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> scanAndLoadBooks() async {
    state = const AsyncValue.loading();
    try {
      final books = await _localLibraryService.scanDeviceForBooks();
      await _localLibraryService.cacheBooks(books);
      state = AsyncValue.data(books);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> pickAndLoadBooks() async {
    state = const AsyncValue.loading();
    try {
      final books = await _localLibraryService.pickAndLoadBooks();
      await _localLibraryService.cacheBooks(books);
      state = AsyncValue.data(books);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}



// Provider for the controller
final libraryControllerProvider = StateNotifierProvider<LibraryController, AsyncValue<List<Book>>>((ref) {
  final localLibraryService = LocalLibraryService();
  return LibraryController(localLibraryService);
});