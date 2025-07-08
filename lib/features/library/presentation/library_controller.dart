import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/library/data/local_library_service.dart';
import 'package:visualit/features/reader/application/book_processor.dart';
import 'package:visualit/features/reader/data/book_data.dart' as db;
import 'package:epubx/epubx.dart';
import 'package:html/parser.dart' as html_parser;

final libraryControllerProvider =
StateNotifierProvider.autoDispose<LibraryController, AsyncValue<List<db.Book>>>(
        (ref) {
      final isar = ref.watch(isarDBProvider).requireValue;
      final localLibraryService = ref.watch(localLibraryServiceProvider);
      return LibraryController(localLibraryService, isar);
    });

class LibraryController extends StateNotifier<AsyncValue<List<db.Book>>> {
  final LocalLibraryService _localLibraryService;
  final Isar _isar;

  LibraryController(this._localLibraryService, this._isar)
      : super(const AsyncValue.loading()) {
    loadBooksFromDb();
  }

  void loadBooksFromDb() async {
    print('LibraryController: Loading books from database...');
    state = const AsyncValue.loading();
    try {
      final books = await _isar.books.where().sortByTitle().findAll();
      print('LibraryController: Loaded ${books.length} books from database');

      // Debug: Print details of each book
      for (int i = 0; i < books.length; i++) {
        final book = books[i];
        print('LibraryController: Book $i - ID: ${book.id}, Title: ${book.title ?? 'NULL'}, Author: ${book.author ?? 'NULL'}');
        print('LibraryController: Book $i - Path: ${book.epubFilePath}');
        print('LibraryController: Book $i - Status: ${book.status}, Cover: ${book.coverImageBytes != null ? 'Available' : 'NULL'}');
      }

      state = AsyncValue.data(books);
    } catch (e, st) {
      print('LibraryController: Error loading books from database: $e');
      state = AsyncValue.error(e, st);
    }
  }

  // Extract the core processing logic from BookProcessor to use with main Isar instance
  Future<void> _processBookDirectly(String filePath, int bookId) async {
    print('LibraryController: Starting direct book processing for: $filePath');

    final existingBook = await _isar.books.get(bookId);
    if (existingBook == null) {
      print('LibraryController: Book not found in database: $bookId');
      return;
    }

    print('LibraryController: Setting book status to processing...');
    existingBook.status = db.ProcessingStatus.processing;
    await _isar.writeTxn(() async => await _isar.books.put(existingBook));

    try {
      print('LibraryController: Reading EPUB file...');
      final fileBytes = await File(filePath).readAsBytes();
      print('LibraryController: File read successfully, ${fileBytes.length} bytes');

      print('LibraryController: Parsing EPUB with EpubReader...');
      final epubBook = await EpubReader.readBook(fileBytes);
      print('LibraryController: EPUB parsed successfully');

      // Extract metadata
      existingBook.title = epubBook.Title;
      existingBook.author = epubBook.Author;
      print('LibraryController: Extracted metadata - Title: ${epubBook.Title}, Author: ${epubBook.Author}');

      if (epubBook.CoverImage != null) {
        existingBook.coverImageBytes = epubBook.CoverImage!.getBytes();
        print('LibraryController: Cover image extracted - ${existingBook.coverImageBytes!.length} bytes');
      } else {
        print('LibraryController: No cover image found');
      }

      // Clear existing content blocks
      print('LibraryController: Clearing existing content blocks...');
      await _isar.writeTxn(() async {
        await _isar.contentBlocks
            .filter()
            .bookIdEqualTo(existingBook.id)
            .deleteAll();
      });

      // Process chapters and create content blocks
      final newBlocks = <db.ContentBlock>[];
      print('LibraryController: Processing chapters...');

      // Replace the chapter processing section in _processBookDirectly
      if (epubBook.Chapters != null) {
        print('LibraryController: Found ${epubBook.Chapters!.length} chapters');

        for (int i = 0; i < epubBook.Chapters!.length; i++) {
          final chapter = epubBook.Chapters![i];
          print('LibraryController: Processing chapter $i: ${chapter.Title ?? 'Untitled'}');

          if (chapter.HtmlContent == null) {
            print('LibraryController: Chapter $i has no HTML content, skipping');
            continue;
          }

          final document = html_parser.parse(chapter.HtmlContent!);

          // Get all text-containing elements, not just direct children
          final allElements = document.querySelectorAll('p, h1, h2, h3, h4, h5, h6, div');
          print('LibraryController: Chapter $i has ${allElements.length} text elements');

          int blockIndex = 0;
          for (final element in allElements) {
            final textContent = element.text.trim();
            if (textContent.isNotEmpty && textContent.length > 10) { // Filter out very short content
              final block = db.ContentBlock()
                ..bookId = existingBook.id
                ..chapterIndex = i
                ..blockIndexInChapter = blockIndex
                ..htmlContent = element.outerHtml
                ..textContent = textContent
                ..blockType = _getBlockType(element.localName);
              newBlocks.add(block);
              blockIndex++;
            }
          }

          print('LibraryController: Chapter $i created $blockIndex content blocks');
        }
      } else {
        print('LibraryController: No chapters found in EPUB');
      }

      print('LibraryController: Created ${newBlocks.length} content blocks');

      // Save everything to database
      print('LibraryController: Saving to database...');
      await _isar.writeTxn(() async {
        await _isar.contentBlocks.putAll(newBlocks);
        existingBook.status = db.ProcessingStatus.ready;
        await _isar.books.put(existingBook);
      });

      print('LibraryController: Book processing completed successfully');

    } catch (e, s) {
      print('LibraryController: Error processing book: $e');
      print('LibraryController: Stack trace: $s');

      existingBook.status = db.ProcessingStatus.error;
      await _isar.writeTxn(() async => await _isar.books.put(existingBook));
      rethrow;
    }
  }

  db.BlockType _getBlockType(String? tagName) {
    switch (tagName?.toLowerCase()) {
      case 'p':
      case 'div': // Add div support
        return db.BlockType.p;
      case 'h1':
        return db.BlockType.h1;
      case 'h2':
        return db.BlockType.h2;
      case 'h3':
        return db.BlockType.h3;
      case 'h4':
        return db.BlockType.h4;
      case 'h5':
        return db.BlockType.h5;
      case 'h6':
        return db.BlockType.h6;
      case 'img':
        return db.BlockType.img;
      default:
        return db.BlockType.unsupported;
    }
  }

  Future<void> _processFiles(List<File> files) async {
    print('LibraryController: Processing ${files.length} files...');
    if (files.isEmpty) {
      print('LibraryController: No files to process');
      return;
    }

    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      print('LibraryController: Processing file ${i + 1}/${files.length}: ${file.path}');

      final existingBook =
      await _isar.books.where().epubFilePathEqualTo(file.path).findFirst();

      if (existingBook != null) {
        print('LibraryController: Book already exists in database, skipping: ${file.path}');
        print('LibraryController: Existing book - ID: ${existingBook.id}, Title: ${existingBook.title ?? 'NULL'}');
        continue;
      }

      print('LibraryController: Adding new book to database: ${file.path}');
      final newBook = db.Book()..epubFilePath = file.path;

      final bookId = await _isar.writeTxn(() async {
        return await _isar.books.put(newBook);
      });

      print('LibraryController: Book added to database with ID: $bookId');

      // Verify file exists and is readable before processing
      if (!file.existsSync()) {
        print('LibraryController: ERROR - File no longer exists: ${file.path}');
        continue;
      }

      print('LibraryController: File verification - Size: ${file.lengthSync()} bytes');

      print('LibraryController: Starting book processing on main isolate for: ${file.path}');
      try {
        final stopwatch = Stopwatch()..start();

        // Process the book directly using our own method
        await _processBookDirectly(file.path, bookId);

        stopwatch.stop();
        print('LibraryController: Book processing completed in ${stopwatch.elapsedMilliseconds}ms');

        // Verify the book was actually processed by checking for metadata
        print('LibraryController: Verifying book processing results...');
        final processedBook = await _isar.books.get(bookId);

        if (processedBook != null) {
          print('LibraryController: Post-processing verification:');
          print('LibraryController: - Title: ${processedBook.title ?? 'STILL NULL'}');
          print('LibraryController: - Author: ${processedBook.author ?? 'STILL NULL'}');
          print('LibraryController: - Cover: ${processedBook.coverImageBytes != null ? 'Available (${processedBook.coverImageBytes!.length} bytes)' : 'STILL NULL'}');
          print('LibraryController: - Status: ${processedBook.status}');

          if (processedBook.title == null || processedBook.author == null) {
            print('LibraryController: WARNING - Book metadata was not extracted properly!');
          } else {
            print('LibraryController: SUCCESS - Book metadata extracted successfully');
          }
        } else {
          print('LibraryController: ERROR - Book not found in database after processing!');
        }

      } catch (e) {
        print('LibraryController: Error processing book: $e');
        print('LibraryController: Error type: ${e.runtimeType}');
        print('LibraryController: Stack trace: ${StackTrace.current}');

        // Check if the book entry still exists after error
        final bookAfterError = await _isar.books.get(bookId);
        if (bookAfterError != null) {
          print('LibraryController: Book entry still exists after error - keeping in database');
        }
      }
    }

    print('LibraryController: Finished processing all files, reloading database...');
    loadBooksFromDb();
  }

  Future<void> pickAndProcessBooks() async {
    print('LibraryController: Starting pick and process books...');
    final files = await _localLibraryService.pickFiles();
    print('LibraryController: Received ${files.length} files from picker');
    await _processFiles(files);
  }

  Future<void> scanAndProcessBooks() async {
    print('LibraryController: Starting scan and process books...');
    final files = await _localLibraryService.scanAndLoadBooks();
    print('LibraryController: Received ${files.length} files from scanner');
    await _processFiles(files);
  }
}

final localLibraryServiceProvider = Provider<LocalLibraryService>((ref) {
  return LocalLibraryService();
});

// Replace the chapter processing section in _processBookDirectly
