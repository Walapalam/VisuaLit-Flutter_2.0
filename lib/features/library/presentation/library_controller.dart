import 'package:flutter/foundation.dart'; // Required for compute
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/library/data/local_library_service.dart';
import 'package:visualit/features/library/data/book_processor.dart'; // Import the processor
import 'package:visualit/features/library/data/parsed_book_dto.dart'; // Import the DTOs
import 'package:visualit/features/reader/data/book_data.dart' as db;

final localLibraryServiceProvider = Provider<LocalLibraryService>((ref) {
  return LocalLibraryService();
});

final libraryControllerProvider =
StateNotifierProvider.autoDispose<LibraryController, AsyncValue<List<db.Book>>>((ref) {
  final isar = ref.watch(isarDBProvider).requireValue;
  final localLibraryService = ref.watch(localLibraryServiceProvider);
  return LibraryController(localLibraryService, isar);
});

class LibraryController extends StateNotifier<AsyncValue<List<db.Book>>> {
  final LocalLibraryService _localLibraryService;
  final Isar _isar;

  LibraryController(this._localLibraryService, this._isar) : super(const AsyncValue.loading()) {
    print("✅ [LibraryController] Initialized.");
    loadBooksFromDb();
  }

  Future<void> loadBooksFromDb() async {
    print("🔄 [LibraryController] Loading all books from database...");
    state = const AsyncValue.loading();
    try {
      final books = await _isar.books.where().sortByTitle().findAll();
      print("  [LibraryController] Found ${books.length} books in DB.");
      state = AsyncValue.data(books);
    } catch (e, st) {
      print("❌ [LibraryController] FATAL ERROR loading books: $e");
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> pickAndProcessBooks() async {
    print("ℹ️ [LibraryController] User initiated 'pickAndProcessBooks'.");
    final files = await _localLibraryService.pickFiles();
    if (files.isNotEmpty) {
      _processFilesInBackground(files);
    }
  }

  Future<void> scanAndProcessBooks() async {
    print("ℹ️ [LibraryController] User initiated 'scanAndProcessBooks'.");
    final files = await _localLibraryService.scanAndLoadBooks();
    if (files.isNotEmpty) {
      _processFilesInBackground(files);
    }
  }

  /// The main orchestration method.
  Future<void> _processFilesInBackground(List<PickedFileData> files) async {
    for (final fileData in files) {
      final filePath = fileData.path;

      // Skip if already exists
      final existingBook = await _isar.books.where().epubFilePathEqualTo(filePath).findFirst();
      if (existingBook != null) {
        print("  ⚠️ [LibraryController] Book '$filePath' already exists. Skipping.");
        continue;
      }

      // --- Step 1: Immediate UI Feedback ---
      print("\n--- 📖 Staging Book for Processing: $filePath ---");
      final stagingBook = db.Book()
        ..epubFilePath = filePath
        ..status = db.ProcessingStatus.processing;

      final bookId = await _isar.writeTxn(() async => await _isar.books.put(stagingBook));
      print("  ✅ [LibraryController] Staged book entry with ID: $bookId. Status: processing");
      await loadBooksFromDb(); // Refresh UI to show "Processing..."

      // --- Step 2: Isolate Processing ---
      try {
        print("  ⏳ [LibraryController] Spawning isolate with compute() for book ID: $bookId...");
        // This is the core of the new architecture. 'processEpub' runs on a separate thread.
        final ParsedBookDTO dto = await compute(processEpub, fileData.bytes);
        print("  ✅ [LibraryController] Isolate finished. DTO received for book ID: $bookId.");

        // --- Step 3: Persist the Result ---
        await _saveProcessedBook(dto, bookId);

      } catch (e, s) {
        print("  ❌ [LibraryController] FATAL ERROR from compute/isolate for book ID $bookId: $e\n$s");
        await _markBookAsError(bookId);
      }
    }
    // Final refresh of the library view
    await loadBooksFromDb();
  }

  /// Takes the DTO from the isolate and saves it to Isar in a single transaction.
  Future<void> _saveProcessedBook(ParsedBookDTO dto, int bookId) async {
    await _isar.writeTxn(() async {
      final bookToUpdate = await _isar.books.get(bookId);
      if (bookToUpdate == null) return;

      // Update the book with rich metadata from the DTO
      bookToUpdate.title = dto.title;
      bookToUpdate.author = dto.author;
      bookToUpdate.publisher = dto.publisher;
      bookToUpdate.language = dto.language;
      bookToUpdate.publicationDate = dto.publicationDate;
      bookToUpdate.coverImageBytes = dto.coverImageBytes;
      bookToUpdate.toc = dto.toc;
      bookToUpdate.status = db.ProcessingStatus.ready; // Mark as ready!

      // Convert block DTOs to Isar ContentBlock objects
      final contentBlocks = dto.blocks.map((blockDto) => db.ContentBlock()
        ..bookId = bookId
        ..chapterIndex = blockDto.chapterIndex
        ..blockIndexInChapter = blockDto.blockIndexInChapter
        ..src = blockDto.src
        ..blockType = blockDto.blockType
        ..htmlContent = blockDto.htmlContent
        ..textContent = blockDto.textContent
        ..imageBytes = blockDto.imageBytes
      ).toList();

      // Perform the final writes
      await _isar.books.put(bookToUpdate);
      await _isar.contentBlocks.putAll(contentBlocks);

      print("  ✅ [LibraryController] Saved final book data and ${contentBlocks.length} blocks for book ID: $bookId.");
    });
  }

  /// Updates a book's status to 'error' in case the isolate fails.
  Future<void> _markBookAsError(int bookId) async {
    await _isar.writeTxn(() async {
      final bookToUpdate = await _isar.books.get(bookId);
      if (bookToUpdate != null) {
        bookToUpdate.status = db.ProcessingStatus.error;
        await _isar.books.put(bookToUpdate);
      }
    });
  }

// NOTE: All helper methods for parsing (_flattenAndParseElements, _parseNavXhtml, etc.)
// have been REMOVED from this file as they now live in book_processor.dart.
}