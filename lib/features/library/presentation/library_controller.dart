import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/dom.dart' as dom;
import 'package:isar/isar.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/library/data/local_library_service.dart';
import 'package:visualit/features/reader/data/book_data.dart' as db;
import 'package:visualit/features/reader/data/toc_entry.dart';
import 'package:visualit/features/reader/data/book_processor.dart';
import 'package:visualit/features/reader/data/parsed_book_dto.dart';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:path/path.dart' as p;

final localLibraryServiceProvider = Provider<LocalLibraryService>((ref) {
  return LocalLibraryService();
});

final libraryControllerProvider = StateNotifierProvider.autoDispose<LibraryController, AsyncValue<List<db.Book>>>(
        (ref) {
      final isar = ref.watch(isarDBProvider).requireValue;
      final localLibraryService = ref.watch(localLibraryServiceProvider);
      return LibraryController(localLibraryService, isar);
    }
);

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
    await _processFiles(files);
  }

  Future<void> scanAndProcessBooks() async {
    print("ℹ️ [LibraryController] User initiated 'scanAndProcessBooks'.");
    final files = await _localLibraryService.scanAndLoadBooks();
    await _processFiles(files);
  }


  Future<void> _processFiles(List<PickedFileData> files) async {
    if (files.isEmpty) {
      await loadBooksFromDb();
      return;
    }

    print("⏳ [LibraryController] Starting to process ${files.length} file(s).");

    for (final fileData in files) {
      final filePath = fileData.path;
      print("\n--- 📖 Processing Book: $filePath ---");

      final existingBook = await _isar.books.where().epubFilePathEqualTo(filePath).findFirst();
      if (existingBook != null) {
        print("  ⚠️ [LibraryController] Book already exists in DB. Skipping.");
        continue;
      }

      // Create a placeholder title from the filename
      final placeholderTitle = p.basenameWithoutExtension(filePath);

      // Create initial book entry with "processing" status
      final newBook = db.Book()
        ..epubFilePath = filePath
        ..title = placeholderTitle
        ..status = db.ProcessingStatus.processing;

      final bookId = await _isar.writeTxn(() async => await _isar.books.put(newBook));
      print("  ✅ [LibraryController] Created initial book entry with ID: $bookId, status: processing");

      // Refresh the UI to show the processing state
      await loadBooksFromDb();

      try {
        final bytes = fileData.bytes;

        print("  🔄 [LibraryController] Spawning isolate to process EPUB file...");

        // Process the EPUB file in an isolate using compute()
        final ParsedBookDTO parsedBook = await compute(BookProcessor.processEpub, bytes);

        print("  ✅ [LibraryController] Isolate processing complete.");
        print("  [LibraryController] Parsed Metadata -> Title: '${parsedBook.title}', Author: '${parsedBook.author}', Publisher: '${parsedBook.publisher}'");
        print("  ✅ [LibraryController] FINAL RESULT: Extracted a total of ${parsedBook.contentBlocks.length} content blocks from the entire book.");

        if (parsedBook.contentBlocks.isEmpty) {
          print("  ❌ [LibraryController] CRITICAL FAILURE: No content blocks were extracted from the book.");
        }

        // Convert ParsedContentBlockDTO objects to ContentBlock objects
        final List<db.ContentBlock> allBlocks = [];
        for (final blockDto in parsedBook.contentBlocks) {
          final block = db.ContentBlock()
            ..bookId = bookId
            ..chapterIndex = blockDto.chapterIndex
            ..blockIndexInChapter = blockDto.blockIndexInChapter
            ..src = blockDto.src
            ..blockType = _stringToBlockType(blockDto.blockType)
            ..htmlContent = blockDto.htmlContent
            ..textContent = blockDto.textContent
            ..imageBytes = blockDto.imageBytes;

          allBlocks.add(block);
        }

        // Update the book in the database with the parsed data
        await _isar.writeTxn(() async {
          final bookToUpdate = await _isar.books.get(bookId);
          if (bookToUpdate != null) {
            bookToUpdate.title = parsedBook.title;
            bookToUpdate.author = parsedBook.author;
            bookToUpdate.coverImageBytes = parsedBook.coverImageBytes;
            bookToUpdate.status = db.ProcessingStatus.ready;
            bookToUpdate.toc = parsedBook.toc;
            bookToUpdate.publisher = parsedBook.publisher;
            bookToUpdate.language = parsedBook.language;
            bookToUpdate.publicationDate = parsedBook.publicationDate;
            await _isar.books.put(bookToUpdate);
          }
          await _isar.contentBlocks.putAll(allBlocks);
        });
        print("  ✅ [LibraryController] Successfully saved book metadata and ${allBlocks.length} blocks. Status: ready.");

      } catch (e, s) {
        print("  ❌ [LibraryController] FATAL ERROR during processing for book ID $bookId: $e\n$s");
        await _isar.writeTxn(() async {
          final bookToUpdate = await _isar.books.get(bookId);
          if (bookToUpdate != null) {
            bookToUpdate.status = db.ProcessingStatus.error;
            await _isar.books.put(bookToUpdate);
          }
        });
      }
    }
    await loadBooksFromDb();
  }


  /// Converts string block type to BlockType enum
  db.BlockType _stringToBlockType(String blockType) {
    switch (blockType) {
      case 'p': return db.BlockType.p;
      case 'h1': return db.BlockType.h1;
      case 'h2': return db.BlockType.h2;
      case 'h3': return db.BlockType.h3;
      case 'h4': return db.BlockType.h4;
      case 'h5': return db.BlockType.h5;
      case 'h6': return db.BlockType.h6;
      case 'img': return db.BlockType.img;
      default: return db.BlockType.unsupported;
    }
  }
}
