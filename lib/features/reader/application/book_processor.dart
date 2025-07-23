import 'dart:io';
import 'package:epubx/epubx.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:visualit/core/services/interfaces/i_logger_service.dart';
import 'package:visualit/features/reader/application/interfaces/i_book_processor.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:xml/xml.dart'; // For XmlDocument and XmlElement parsing


/// A class responsible for processing EPUB files in a background isolate.
/// It extracts metadata, parses content, and stores it in the Isar database.
class BookProcessor implements IBookProcessor {
  final ILoggerService _logger;

  BookProcessor(this._logger);

  /// This is the primary, synchronous entry point required by the IBookProcessor interface.
  /// The main processing work is offloaded to a separate isolate via `launchIsolate`.
  @override
  Future<void> processBook(Book book) async {
    _logger.info('Sync processBook called for: ${book.title}. Offloading to isolate.', tag: 'BookProcessor');
    // In a real-world scenario, you might do some pre-processing here before launching the isolate.
    // For now, the primary logic is fully contained within the isolate.
  }

  /// Launches a new isolate to process the book at the given file path.
  /// This prevents the UI from freezing while parsing large EPUB files.
  static Future<void> launchIsolate(String filePath) async {
    // Each isolate needs its own Isar instance. Using a unique name
    // prevents conflicts with the main UI isolate's instance.
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [BookSchema, ContentBlockSchema], // Schemas needed for book processing
      directory: dir.path,
      name: 'background_instance',
    );

    try {
      // Execute the core processing logic within the isolate.
      await _processBook(isar, filePath);
    } catch (e, stackTrace) {
      // Top-level catch for any unexpected errors during isolate execution.
      debugPrint("FATAL Error processing book in isolate: $e");
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      // It's crucial to close the Isar instance to release resources.
      if (isar.isOpen) {
        await isar.close();
      }
    }
  }

  /// The core book processing logic that runs inside the isolate.
  static Future<void> _processBook(Isar isar, String filePath) async {
    // Find the book record that was queued by the main application.
    final existingBook = await isar.books.where().epubFilePathEqualTo(filePath).findFirst();

    if (existingBook == null || existingBook.status != ProcessingStatus.queued) {
      debugPrint("[BookProcessor] Book not found or not in 'queued' state. Skipping: $filePath");
      return;
    }

    // Update the book's status to 'processing' to inform the UI.
    debugPrint("[BookProcessor] Started processing book ID: ${existingBook.id}");
    existingBook.status = ProcessingStatus.processing;
    await isar.writeTxn(() async => await isar.books.put(existingBook));

    try {
      final fileBytes = await File(filePath).readAsBytes();
      final epubBook = await EpubReader.readBook(fileBytes);

      // Extract metadata from the EPUB package.
      existingBook.title = epubBook.Title;
      existingBook.author = epubBook.Author;
      if (epubBook.CoverImage != null) {
        existingBook.coverImageBytes = epubBook.CoverImage!.getBytes();
      }

      // --- New Feature: Parse ISBN from EPUB metadata ---
      existingBook.isbn = _parseIsbn(epubBook);
      debugPrint("[BookProcessor] Parsed ISBN: '${existingBook.isbn}'");

      // --- Content Processing ---
      // Clear any old content blocks before reprocessing.
      await isar.writeTxn(() async {
        await isar.contentBlocks.filter().bookIdEqualTo(existingBook.id).deleteAll();
      });
      debugPrint("[BookProcessor] Cleared old content blocks for book ID: ${existingBook.id}");

      final newBlocks = <ContentBlock>[];
      if (epubBook.Chapters != null) {
        for (int i = 0; i < epubBook.Chapters!.length; i++) {
          final chapter = epubBook.Chapters![i];
          if (chapter.HtmlContent == null) continue;

          final document = html_parser.parse(chapter.HtmlContent!);
          final body = document.body;
          if (body == null) continue;

          // Recursively flatten HTML elements into a list of ContentBlocks.
          _flattenAndParseElements(
            elements: body.children,
            targetBlockList: newBlocks,
            bookId: existingBook.id,
            chapterIndex: i,
            getNextBlockIndex: () => newBlocks.length,
          );
        }
      }
      debugPrint("[BookProcessor] Extracted ${newBlocks.length} new content blocks.");

      // Persist all new blocks and update the book's status to 'ready'.
      await isar.writeTxn(() async {
        await isar.contentBlocks.putAll(newBlocks);
        existingBook.status = ProcessingStatus.ready;
        await isar.books.put(existingBook); // Save the book with new metadata (including ISBN)
      });
      debugPrint("[BookProcessor] Book ID ${existingBook.id} processing complete. Status: ready.");

    } catch (e, s) {
      debugPrint("[BookProcessor] FATAL ERROR during processing for book ID ${existingBook.id}: $e\n$s");
      // If an error occurs, update the book's status and save the error details for debugging.
      existingBook.status = ProcessingStatus.error;
      existingBook.errorMessage = e.toString();
      existingBook.errorStackTrace = s.toString();
      await isar.writeTxn(() async => await isar.books.put(existingBook));
    }
  }

  /// A recursive helper function to flatten a list of HTML elements into `ContentBlock`s.
  /// This can handle nested structures like `<div><p>...</p></div>`.
  static void _flattenAndParseElements({
    required List<dom.Element> elements,
    required List<ContentBlock> targetBlockList,
    required int bookId,
    required int chapterIndex,
    required int Function() getNextBlockIndex,
  }) {
    for (final element in elements) {
      final tagName = element.localName;
      final blockType = _getBlockType(tagName);

      // For container tags, recurse into their children.
      if (tagName == 'div' || tagName == 'section' || tagName == 'article' || tagName == 'main') {
        _flattenAndParseElements(
          elements: element.children,
          targetBlockList: targetBlockList,
          bookId: bookId,
          chapterIndex: chapterIndex,
          getNextBlockIndex: getNextBlockIndex,
        );
        continue; // Move to the next element in the current list
      }

      // Process actual content blocks (p, h1, img, etc.).
      if (blockType != BlockType.unsupported) {
        final textContent = element.text.replaceAll('\u00A0', ' ').trim(); // Replace non-breaking spaces

        // Skip blocks that are purely whitespace, but allow image blocks.
        if (textContent.isEmpty && blockType != BlockType.img) {
          continue;
        }

        final block = ContentBlock()
          ..bookId = bookId
          ..chapterIndex = chapterIndex
          ..blockIndexInChapter = getNextBlockIndex()
          ..blockType = blockType
          ..htmlContent = element.outerHtml
          ..textContent = textContent;

        // Handle image data extraction for img blocks
        if (blockType == BlockType.img) {
          // Note: Image bytes extraction from epubBook.Content is needed.
          // The EpubReader.readBook already gives bytes in EpubBook.CoverImage.
          // For in-content images, you'd usually resolve paths and fetch from the archive.
          // This part requires access to the full EPUB archive or file system in the isolate.
          // For now, block.imageBytes will likely be null unless further logic is added.
        }
        targetBlockList.add(block);
      }
    }
  }

  /// Parses the ISBN from the EPUB's OPF (Open Packaging Format) file.
  static String? _parseIsbn(EpubBook epubBook) {
    try {
      final identifiers = epubBook.Schema?.Package?.Metadata?.Identifiers;
      // Ensure identifiers is not null before using firstWhereOrNull
      final isbnIdentifier = identifiers?._firstWhereOrNull( // Use the local extension
            (id) => id?.Scheme?.toLowerCase() == 'isbn', // Check id and scheme for nullability
      );

      if (isbnIdentifier?.Id != null && isbnIdentifier!.Id!.isNotEmpty) {
        return isbnIdentifier.Id!.trim().replaceAll(RegExp(r'[- ]'), '');
      }
      return null;
    } catch (e) {
      debugPrint("[BookProcessor] Could not parse ISBN: $e");
      return null;
    }
  }

  /// Maps an HTML tag name to a `BlockType` enum.
  static BlockType _getBlockType(String? tagName) {
    switch (tagName?.toLowerCase()) {
      case 'p': return BlockType.p;
      case 'h1': return BlockType.h1;
      case 'h2': return BlockType.h2;
      case 'h3': return BlockType.h3;
      case 'h4': return BlockType.h4;
      case 'h5': return BlockType.h5;
      case 'h6': return BlockType.h6;
      case 'img': return BlockType.img;
      case 'image': return BlockType.img; // Common in EPUBs for SVG wrappers
      case 'svg': return BlockType.img;   // Treat standalone SVGs as images
      default: return BlockType.unsupported;
    }
  }
}

// Ensure FirstWhereOrNullExtension is accessible if it's not globally defined.
// Since it's used as `_firstWhereOrNull`, it needs to be accessible in this scope.
// If not already defined globally or in a common utility file, add it here.
extension _IterableExtension<E> on Iterable<E> {
  E? _firstWhereOrNull(bool Function(E) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}