import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:visualit/core/models/book_schema.dart';
import 'package:visualit/core/models/content_block_schema.dart';
import 'package:visualit/core/models/parsed_book_dto.dart';
import 'package:visualit/core/models/toc_entry_schema.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/core/services/book_processor.dart';
import 'package:visualit/features/library/data/local_library_service.dart';
import 'package:path/path.dart' as p;

final localLibraryServiceProvider = Provider<LocalLibraryService>((ref) {
  return LocalLibraryService();
});

final libraryControllerProvider = StateNotifierProvider.autoDispose<LibraryController, AsyncValue<List<BookSchema>>>(
  (ref) {
    final isar = ref.watch(isarDBProvider).requireValue;
    final localLibraryService = ref.watch(localLibraryServiceProvider);
    return LibraryController(localLibraryService, isar);
  }
);

class LibraryController extends StateNotifier<AsyncValue<List<BookSchema>>> {
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
      final books = await _isar.bookSchemas.where().sortByTitle().findAll();
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
    await _processFiles(files);
  }

  Future<void> scanAndProcessBooks() async {
    print("ℹ️ [LibraryController] User initiated 'scanAndProcessBooks'.");
    final files = await _localLibraryService.scanAndLoadBooks();
    await _processFiles(files);
  }

  Future<void> retryProcessingBook(int bookId) async {
    print("ℹ️ [LibraryController] User initiated retry for book ID: $bookId");

    // Get the book from the database
    final book = await _isar.bookSchemas.get(bookId);
    if (book == null) {
      print("❌ [LibraryController] Book not found with ID: $bookId");
      return;
    }

    if (book.status != ProcessingStatus.error) {
      print("⚠️ [LibraryController] Book is not in error state. Current status: ${book.status}");
      return;
    }

    try {
      // Load the file data
      final filePath = book.epubFilePath;
      final fileData = await _localLibraryService.loadFileFromPath(filePath);

      if (fileData == null) {
        throw Exception("Could not load file from path: $filePath");
      }

      // Reset the book status to processing
      await _isar.writeTxn(() async {
        book.status = ProcessingStatus.processing;
        book.errorMessage = null;
        book.errorStackTrace = null;
        await _isar.bookSchemas.put(book);
      });

      // Reload the book list to show the updated status
      await loadBooksFromDb();

      // Process the book in the background
      _processBookInBackground(bookId, fileData.bytes);

    } catch (e, s) {
      print("❌ [LibraryController] Error preparing book for retry: $e\n$s");

      // Update the book status back to error with the new error message
      await _isar.writeTxn(() async {
        final bookToUpdate = await _isar.bookSchemas.get(bookId);
        if (bookToUpdate != null) {
          bookToUpdate.status = ProcessingStatus.error;
          bookToUpdate.errorMessage = e.toString();
          bookToUpdate.errorStackTrace = s.toString();
          await _isar.bookSchemas.put(bookToUpdate);
        }
      });

      // Reload the book list to show the updated status
      await loadBooksFromDb();
    }
  }

  Future<void> _processFiles(List<PickedFileData> files) async {
    if (files.isEmpty) {
      await loadBooksFromDb();
      return;
    }

    print("⏳ [LibraryController] Starting to process ${files.length} file(s).");

    for (final fileData in files) {
      final filePath = fileData.path;
      print("\n--- 📖 Preparing Book: $filePath ---");

      final existingBook = await _isar.bookSchemas.where().epubFilePathEqualTo(filePath).findFirst();
      if (existingBook != null) {
        print("  ⚠️ [LibraryController] Book already exists in DB. Skipping.");
        continue;
      }

      // Create initial book entry with processing status
      final fileName = p.basename(filePath);
      final newBook = BookSchema()
        ..epubFilePath = filePath
        ..title = p.basenameWithoutExtension(fileName) // Use filename as initial title
        ..status = ProcessingStatus.processing
        ..createdAt = DateTime.now();

      final bookId = await _isar.writeTxn(() async => await _isar.bookSchemas.put(newBook));
      print("  ✅ [LibraryController] Created initial book entry with ID: $bookId, status: processing");

      // Process the book in the background
      _processBookInBackground(bookId, fileData.bytes);
    }

    // Reload books to show processing status
    await loadBooksFromDb();
  }

  void _processBookInBackground(int bookId, Uint8List fileBytes) {
    // Use compute to run the processing in a separate isolate
    compute(BookProcessor.processEpub, fileBytes).then((parsedBook) async {
      // When processing completes successfully, update the database
      await _saveProcessedBook(bookId, parsedBook);
    }).catchError((e, stackTrace) async {
      print("❌ [LibraryController] Error processing book: $e");
      
      // Update the book status to error
      await _isar.writeTxn(() async {
        final book = await _isar.bookSchemas.get(bookId);
        if (book != null) {
          book.status = ProcessingStatus.error;
          book.errorMessage = e.toString();
          book.errorStackTrace = stackTrace.toString();
          await _isar.bookSchemas.put(book);
        }
      });
      
      // Reload the book list to show the updated status
      await loadBooksFromDb();
    });
  }

  Future<void> _saveProcessedBook(int bookId, ParsedBookDTO parsedBook) async {
    print("✅ [LibraryController] Book processing completed, saving to database...");
    
    try {
      await _isar.writeTxn(() async {
        // 1. Update the book metadata
        final book = await _isar.bookSchemas.get(bookId);
        if (book == null) {
          print("❌ [LibraryController] Book not found with ID: $bookId");
          return;
        }
        
        book.title = parsedBook.title;
        book.author = parsedBook.author;
        book.publisher = parsedBook.publisher;
        book.language = parsedBook.language;
        book.publicationDate = parsedBook.publicationDate;
        book.coverImageBytes = parsedBook.coverImageBytes;
        book.status = ProcessingStatus.ready;
        book.updatedAt = DateTime.now();
        
        await _isar.bookSchemas.put(book);
        
        // 2. Save content blocks
        final contentBlocks = <ContentBlockSchema>[];
        for (final chapter in parsedBook.chapters) {
          for (int i = 0; i < chapter.blocks.length; i++) {
            final block = chapter.blocks[i];
            final contentBlock = ContentBlockSchema()
              ..bookId = bookId
              ..blockType = block.blockType
              ..htmlContent = block.htmlContent
              ..textContent = block.textContent
              ..imageBytes = block.imageBytes
              ..chapterIndex = chapter.index
              ..blockIndexInChapter = i
              ..src = chapter.path;
            
            contentBlocks.add(contentBlock);
          }
        }
        
        await _isar.contentBlockSchemas.putAll(contentBlocks);
        print("  ✅ [LibraryController] Saved ${contentBlocks.length} content blocks");
        
        // 3. Save TOC entries
        final tocEntries = _convertTocEntriesToSchema(parsedBook.tocEntries, bookId);
        await _isar.tOCEntrySchemas.putAll(tocEntries);
        print("  ✅ [LibraryController] Saved ${tocEntries.length} TOC entries");
      });
      
      // Reload the book list to show the updated status
      await loadBooksFromDb();
      
    } catch (e, stackTrace) {
      print("❌ [LibraryController] Error saving processed book: $e");
      print(stackTrace);
      
      // Update the book status to error
      await _isar.writeTxn(() async {
        final book = await _isar.bookSchemas.get(bookId);
        if (book != null) {
          book.status = ProcessingStatus.error;
          book.errorMessage = "Error saving processed book: $e";
          book.errorStackTrace = stackTrace.toString();
          await _isar.bookSchemas.put(book);
        }
      });
      
      // Reload the book list to show the updated status
      await loadBooksFromDb();
    }
  }

  List<TOCEntrySchema> _convertTocEntriesToSchema(List<ParsedTOCEntryDTO> entries, int bookId, {int level = 0, int orderIndex = 0, int? parentId}) {
    final result = <TOCEntrySchema>[];
    
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final schema = TOCEntrySchema()
        ..bookId = bookId
        ..title = entry.title
        ..src = entry.src
        ..fragment = entry.fragment
        ..level = level
        ..orderIndex = orderIndex + i
        ..parentId = parentId;
      
      result.add(schema);
      
      // Process children recursively
      if (entry.children.isNotEmpty) {
        // We need to save the parent first to get its ID
        final parentId = _isar.writeTxnSync(() => _isar.tOCEntrySchemas.putSync(schema));
        
        final children = _convertTocEntriesToSchema(
          entry.children, 
          bookId, 
          level: level + 1, 
          orderIndex: 0, // Children start at 0 within their parent
          parentId: parentId
        );
        
        result.addAll(children);
      }
    }
    
    return result;
  }
}