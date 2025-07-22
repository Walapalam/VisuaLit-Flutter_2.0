import 'dart:io';
import 'package:epubx/epubx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:visualit/core/providers/logger_provider.dart';
import 'package:visualit/core/services/interfaces/i_logger_service.dart';
import 'package:visualit/features/reader/application/interfaces/i_book_processor.dart';
import 'package:visualit/features/reader/data/book_data.dart';

class BookProcessor implements IBookProcessor {
  final ILoggerService _logger;

  // Error notification callback
  static void Function(String title, String message)? onError;

  BookProcessor(this._logger);

  /// Notifies the user about an error
  void _notifyUserAboutError(String bookTitle, String errorMessage) {
    // Call the error callback if it's set
    if (onError != null) {
      onError!(bookTitle, errorMessage);
    }

    // Log the error
    _logger.error('Book processing error: $bookTitle - $errorMessage', 
        tag: 'BookProcessor');
  }

  // This is the clean, static entry point for the Isolate.
  static Future<void> launchIsolate(String filePath) async {
    // The isolate opens its own Isar instance.
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [BookSchema, ContentBlockSchema],
      directory: dir.path,
      name: 'background_instance', // Use a unique name for the isolate's instance
    );

    try {
      // Call the processing logic.
      await _processBook(isar, filePath);
    } catch (e, stackTrace) {
      debugPrint("Error processing book in isolate: $e");
      debugPrintStack(stackTrace: stackTrace);

      // Update book status to error
      try {
        // Find the book by file path
        final book = await isar.books.where().epubFilePathEqualTo(filePath).findFirst();
        if (book != null) {
          await isar.writeTxn(() async {
            book.status = ProcessingStatus.error;
            book.errorMessage = 'Error processing book: ${e.toString()}';
            await isar.books.put(book);
          });

          // We can't directly notify the user from an isolate,
          // but we've updated the book status so the UI can show the error
          debugPrint("Updated book status to error: ${book.title}");
        }
      } catch (innerError) {
        debugPrint("Failed to update book status after error: $innerError");
      }
    } finally {
      // Ensure the Isar instance is closed, even if an error occurs.
      await isar.close();
    }
  }

  @override
  Future<void> processBook(Book book) async {
    _logger.info('Processing book: ${book.title}', tag: 'BookProcessor');

    // Check if the book needs migration to the new format
    if (!book.isNewFormat && book.status == ProcessingStatus.ready) {
      _logger.info('Book needs migration to new format, triggering reprocessing', 
          tag: 'BookProcessor');

      // Queue the book for reprocessing in the background
      await _migrateBookToNewFormat(book);
    } else {
      // Process the book normally
      _logger.info('Book processing completed', tag: 'BookProcessor');
    }
  }

  /// Migrates a book from the old format to the new block-based format
  Future<void> _migrateBookToNewFormat(Book book) async {
    _logger.info('Starting migration for book: ${book.title}', tag: 'BookProcessor');

    try {
      // Set the book status to queued to trigger reprocessing
      book.status = ProcessingStatus.queued;

      // Get the Isar instance
      final isar = Isar.getInstance();
      if (isar == null) {
        _logger.error('Failed to get Isar instance for migration', tag: 'BookProcessor');
        return;
      }

      // Update the book status
      await isar.writeTxn(() async {
        await isar.books.put(book);
      });

      // Launch the isolate to reprocess the book
      _logger.info('Launching isolate for book migration: ${book.epubFilePath}', 
          tag: 'BookProcessor');
      await launchIsolate(book.epubFilePath);

    } catch (e, stackTrace) {
      _logger.error('Error migrating book to new format: $e', 
          tag: 'BookProcessor', stackTrace: stackTrace);

      // Update book status to error and store error message
      if (isar != null) {
        try {
          await isar.writeTxn(() async {
            book.status = ProcessingStatus.error;
            book.errorMessage = 'Failed to migrate book: ${e.toString()}';
            await isar.books.put(book);
          });

          // Notify user about the error
          _notifyUserAboutError(book.title ?? 'Unknown book', e.toString());
        } catch (innerError) {
          _logger.error('Failed to update book status after error: $innerError', 
              tag: 'BookProcessor');
        }
      }
    }
  }

  // This private method contains the core book processing logic.
  static Future<void> _processBook(Isar isar, String filePath) async {
    debugPrint("[BookProcessor] Starting to process book: $filePath");

    final existingBook =
    await isar.books.where().epubFilePathEqualTo(filePath).findFirst();

    if (existingBook == null || existingBook.status != ProcessingStatus.queued) {
      debugPrint("[BookProcessor] Book not found or not queued: $filePath");
      return;
    }

    debugPrint("[BookProcessor] Processing book: ${existingBook.title ?? 'Untitled'}");
    existingBook.status = ProcessingStatus.processing;
    await isar.writeTxn(() async => await isar.books.put(existingBook));

    try {
      debugPrint("[BookProcessor] Reading file: $filePath");
      final fileBytes = await File(filePath).readAsBytes();
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
        debugPrint("[BookProcessor] Processing ${epubBook.Chapters!.length} chapters");
        for (int i = 0; i < epubBook.Chapters!.length; i++) {
          final chapter = epubBook.Chapters![i];
          if (chapter.HtmlContent == null) {
            debugPrint("[BookProcessor] Chapter $i has no HTML content, skipping");
            continue;
          }

          final document = html_parser.parse(chapter.HtmlContent!);
          final elements = document.body?.children ?? [];
          debugPrint("[BookProcessor] Chapter $i has ${elements.length} elements");

          int blockIndex = 0;
          for (int j = 0; j < elements.length; j++) {
            final element = elements[j];

            // Only create blocks for block-level elements
            if (isBlockLevelTag(element.localName)) {
              final textContent = element.text.trim();

              // Skip empty blocks unless they're special elements like hr or img
              if (textContent.isNotEmpty || 
                  element.localName == 'hr' || 
                  element.localName == 'img') {
                final block = ContentBlock()
                  ..bookId = existingBook.id
                  ..chapterIndex = i
                  ..blockIndexInChapter = blockIndex++
                  ..htmlContent = element.outerHtml
                  ..textContent = textContent
                  ..blockType = _getBlockType(element.localName);
                newBlocks.add(block);
              }
            } else if (element.localName == 'div') {
              // Handle divs specially - they can be block or inline depending on content
              // If a div contains block elements, skip it (those blocks will be processed separately)
              // If a div only contains text or inline elements, treat it as a block
              bool containsBlockElements = element.children.any((child) => isBlockLevelTag(child.localName));

              if (!containsBlockElements) {
                final textContent = element.text.trim();
                if (textContent.isNotEmpty) {
                  final block = ContentBlock()
                    ..bookId = existingBook.id
                    ..chapterIndex = i
                    ..blockIndexInChapter = blockIndex++
                    ..htmlContent = element.outerHtml
                    ..textContent = textContent
                    ..blockType = BlockType.div;
                  newBlocks.add(block);
                }
              }
            }
            // Skip inline elements at the top level - they should be inside blocks
          }
        }
      }

      debugPrint("[BookProcessor] Saving ${newBlocks.length} content blocks");
      await isar.writeTxn(() async {
        await isar.contentBlocks.putAll(newBlocks);
        existingBook.status = ProcessingStatus.ready;
        existingBook.isNewFormat = true; // Mark as processed with new format
        await isar.books.put(existingBook);
      });

      debugPrint("[BookProcessor] Book processing completed successfully: ${existingBook.title}");
    } catch (e, s) {
      debugPrint("[BookProcessor] Error processing book: $e");
      debugPrintStack(stackTrace: s);

      // Store detailed error information
      existingBook.status = ProcessingStatus.error;
      existingBook.errorMessage = "Error processing book: ${e.toString()}";

      // Add error details to help with debugging
      final errorDetails = {
        'error': e.toString(),
        'stackTrace': s.toString().split('\n').take(10).join('\n'),
        'bookId': existingBook.id,
        'bookTitle': existingBook.title,
        'timestamp': DateTime.now().toIso8601String(),
      };

      existingBook.processingMetadata = errorDetails.toString();

      // Save the updated book with error information
      await isar.writeTxn(() async => await isar.books.put(existingBook));

      // Log detailed error for analytics
      debugPrint("[BookProcessor] Detailed error info: $errorDetails");
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
      case 'blockquote':
        return BlockType.blockquote;
      case 'li':
        return BlockType.li;
      case 'hr':
        return BlockType.hr;
      case 'img':
        return BlockType.img;
      case 'pre':
        return BlockType.pre;
      case 'div':
        return BlockType.div;
      default:
        return BlockType.unsupported;
    }
  }

  /// Determines if a tag is a block-level tag that should create a new ContentBlock
  static bool isBlockLevelTag(String? tagName) {
    if (tagName == null) return false;

    final blockLevelTags = [
      'p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 
      'blockquote', 'li', 'hr', 'img', 'pre', 'div'
    ];

    return blockLevelTags.contains(tagName.toLowerCase());
  }

  /// Determines if a tag is an inline tag that should be preserved inside a ContentBlock
  static bool isInlineTag(String? tagName) {
    if (tagName == null) return false;

    final inlineTags = [
      'b', 'strong', 'i', 'em', 'a', 'span', 'code', 'br'
    ];

    return inlineTags.contains(tagName.toLowerCase());
  }
}
