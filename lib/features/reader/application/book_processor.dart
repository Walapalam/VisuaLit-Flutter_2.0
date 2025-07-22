import 'dart:io';
import 'package:epubx/epubx.dart';
import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:visualit/features/reader/data/book_data.dart';

class BookProcessor {
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
    } finally {
      // Ensure the Isar instance is closed, even if an error occurs.
      await isar.close();
    }
  }

  // This private method contains the core book processing logic.
  static Future<void> _processBook(Isar isar, String filePath) async {
    final existingBook =
    await isar.books.where().epubFilePathEqualTo(filePath).findFirst();

    if (existingBook == null || existingBook.status != ProcessingStatus.queued) {
      return;
    }

    existingBook.status = ProcessingStatus.processing;
    await isar.writeTxn(() async => await isar.books.put(existingBook));

    try {
      final fileBytes = await File(filePath).readAsBytes();
      final epubBook = await EpubReader.readBook(fileBytes);

      existingBook.title = epubBook.Title;
      existingBook.author = epubBook.Author;
      if (epubBook.CoverImage != null) {
        existingBook.coverImageBytes = epubBook.CoverImage!.getBytes();
      }

      await isar.writeTxn(() async {
        await isar.contentBlocks
            .filter()
            .bookIdEqualTo(existingBook.id)
            .deleteAll();
      });

      final newBlocks = <ContentBlock>[];
      if (epubBook.Chapters != null) {
        for (int i = 0; i < epubBook.Chapters!.length; i++) {
          final chapter = epubBook.Chapters![i];
          if (chapter.HtmlContent == null) continue;
          final document = html_parser.parse(chapter.HtmlContent!);
          final elements = document.body?.children ?? [];

          for (int j = 0; j < elements.length; j++) {
            final element = elements[j];
            final textContent = _decodeHtmlEntities(element.text.trim());
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

      await isar.writeTxn(() async {
        await isar.contentBlocks.putAll(newBlocks);
        existingBook.status = ProcessingStatus.ready;
        await isar.books.put(existingBook);
      });
    } catch (e, s) {
      existingBook.status = ProcessingStatus.error;
      await isar.writeTxn(() async => await isar.books.put(existingBook));
      debugPrint("Error processing book in isolate: $e");
      debugPrintStack(stackTrace: s);
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

  /// Decodes HTML entities in the given text
  /// Handles common entities like apostrophes, quotes, etc.
  static String _decodeHtmlEntities(String text) {
    // Replace common HTML entities
    return text
        .replaceAll('&apos;', "'")
        .replaceAll('&#39;', "'")
        .replaceAll('&#x27;', "'")
        .replaceAll('&quot;', '"')
        .replaceAll('&#34;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ');
  }
}
