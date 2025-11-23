import 'dart:io';
import 'package:epubx/epubx.dart';
import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:visualit/core/services/interfaces/i_logger_service.dart';
import 'package:visualit/features/reader/application/interfaces/i_book_processor.dart';
import 'package:visualit/features/reader/data/book_data.dart';

class BookProcessor implements IBookProcessor {
  final ILoggerService _logger;

  BookProcessor(this._logger);

  // This is the clean, static entry point for the Isolate.
  static Future<void> launchIsolate(String filePath) async {
    // The isolate opens its own Isar instance.
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [BookSchema, ContentBlockSchema],
      directory: dir.path,
      name:
          'background_instance', // Use a unique name for the isolate's instance
    );

    try {
      // Call the processing logic.
      await _processBook(isar, filePath);
    } catch (e, stackTrace) {
      debugPrint("Error processing book in isolate: $e");
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      // Ensure the Isar instance is closed, even if an error occurs.
      await isar.close();
    }
  }

  @override
  Future<void> processBook(Book book) async {
    _logger.info('Processing book: ${book.title}', tag: 'BookProcessor');

    // This method would contain the synchronous version of the book processing logic
    // For now, we'll just log that it was called
    _logger.info('Book processing completed', tag: 'BookProcessor');
  }

  // This private method contains the core book processing logic.
  static Future<void> _processBook(Isar isar, String filePath) async {
    debugPrint("[BookProcessor] Starting to process book: $filePath");

    final existingBook = await isar.books
        .where()
        .epubFilePathEqualTo(filePath)
        .findFirst();

    if (existingBook == null ||
        existingBook.status != ProcessingStatus.queued) {
      debugPrint("[BookProcessor] Book not found or not queued: $filePath");
      return;
    }

    debugPrint(
      "[BookProcessor] Processing book: ${existingBook.title ?? 'Untitled'}",
    );
    existingBook.status = ProcessingStatus.processing;
    await isar.writeTxn(() async => await isar.books.put(existingBook));

    try {
      debugPrint("[BookProcessor] Reading file: $filePath");

      // RESOLVE PATH: Convert potentially relative path to absolute
      String absolutePath = filePath;
      if (!filePath.startsWith('/')) {
        final dir = Platform.isAndroid
            ? await getExternalStorageDirectory() // Note: This might be null on some Android contexts, but usually fine.
            : await getApplicationDocumentsDirectory();

        if (dir != null) {
          // Assuming standard structure VisuaLit/books/...
          // If filePath is "books/foo.epub", and root is ".../Documents", we want ".../Documents/VisuaLit/books/foo.epub"
          // BUT LocalLibraryService.getLibraryRoot adds "VisuaLit".
          // So we should construct it similarly.
          final libraryRoot = Directory('${dir.path}/VisuaLit');
          absolutePath = '${libraryRoot.path}/$filePath';
        }
      }

      final fileBytes = await File(absolutePath).readAsBytes();
      final epubBook = await EpubReader.readBook(fileBytes);

      debugPrint("[BookProcessor] Parsed EPUB book: ${epubBook.Title}");
      existingBook.title = epubBook.Title;
      existingBook.author = epubBook.Author;
      if (epubBook.CoverImage != null) {
        existingBook.coverImageBytes = epubBook.CoverImage!.getBytes();
        debugPrint("[BookProcessor] Extracted cover image");
      }

      debugPrint("[BookProcessor] Clearing existing content blocks");
      await isar.writeTxn(() async {
        await isar.contentBlocks
            .filter()
            .bookIdEqualTo(existingBook.id)
            .deleteAll();
      });

      final newBlocks = <ContentBlock>[];
      if (epubBook.Chapters != null) {
        debugPrint(
          "[BookProcessor] Processing ${epubBook.Chapters!.length} chapters",
        );
        for (int i = 0; i < epubBook.Chapters!.length; i++) {
          final chapter = epubBook.Chapters![i];
          if (chapter.HtmlContent == null) {
            debugPrint(
              "[BookProcessor] Chapter $i has no HTML content, skipping",
            );
            continue;
          }

          final document = html_parser.parse(chapter.HtmlContent!);
          final elements = document.body?.children ?? [];
          debugPrint(
            "[BookProcessor] Chapter $i has ${elements.length} elements",
          );

          for (int j = 0; j < elements.length; j++) {
            final element = elements[j];
            final textContent = element.text.trim();
            if (textContent.isNotEmpty) {
              final block = ContentBlock()
                ..bookId = existingBook.id
                ..chapterIndex = i
                ..blockIndexInChapter = j
                ..htmlContent = element.outerHtml
                ..textContent = textContent
                ..blockType = _getBlockType(element.localName);
              newBlocks.add(block);
            }
          }
        }
      }

      debugPrint("[BookProcessor] Saving ${newBlocks.length} content blocks");
      await isar.writeTxn(() async {
        await isar.contentBlocks.putAll(newBlocks);
        existingBook.status = ProcessingStatus.ready;
        await isar.books.put(existingBook);
      });

      debugPrint(
        "[BookProcessor] Book processing completed successfully: ${existingBook.title}",
      );
    } catch (e, s) {
      debugPrint("[BookProcessor] Error processing book: $e");
      debugPrintStack(stackTrace: s);

      existingBook.status = ProcessingStatus.error;
      await isar.writeTxn(() async => await isar.books.put(existingBook));
    }
  }

  static BlockType _getBlockType(String? tagName) {
    switch (tagName?.toLowerCase()) {
      case 'p':
        return BlockType.p;
      case 'h1':
        return BlockType.h1;
      case 'h2':
        return BlockType.h2;
      case 'h3':
        return BlockType.h3;
      case 'h4':
        return BlockType.h4;
      case 'h5':
        return BlockType.h5;
      case 'h6':
        return BlockType.h6;
      case 'img':
        return BlockType.img;
      default:
        return BlockType.unsupported;
    }
  }
}
