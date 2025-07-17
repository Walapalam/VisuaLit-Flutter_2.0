import 'dart:io';
import 'package:epubx/epubx.dart';
import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:path/path.dart' as p;

class BookProcessor {
  static Future<void> launchIsolate(String filePath) async {
    debugPrint("[DEBUG] BookProcessor: Starting isolate for file: $filePath");
    Isar? isar;

    try {
      final dir = await getApplicationDocumentsDirectory();
      debugPrint("[DEBUG] BookProcessor: Opening Isar instance in directory: ${dir.path}");

      isar = await Isar.open(
        [BookSchema, ContentBlockSchema],
        directory: dir.path,
        name: 'background_instance_${filePath.hashCode}', // Unique name per isolate
      );

      debugPrint("[DEBUG] BookProcessor: Isar instance opened successfully");
      await _processBook(isar, filePath);
    } catch (e, stack) {
      debugPrint("[ERROR] BookProcessor: Error in isolate: $e");
      debugPrintStack(stackTrace: stack);
    } finally {
      if (isar != null) {
        debugPrint("[DEBUG] BookProcessor: Closing Isar instance");
        await isar.close();
      }
    }

    debugPrint("[DEBUG] BookProcessor: Isolate completed for file: $filePath");
  }

  static Future<void> _processBook(Isar isar, String filePath) async {
    debugPrint("[DEBUG] BookProcessor: Processing book: $filePath");

    try {
      final existingBook = await isar.books.where().epubFilePathEqualTo(filePath).findFirst();

      if (existingBook == null) {
        debugPrint("[WARN] BookProcessor: Book not found in database: $filePath");
        return;
      }

      if (existingBook.status != ProcessingStatus.queued) {
        debugPrint("[WARN] BookProcessor: Book is not queued for processing. Current status: ${existingBook.status}");
        return;
      }

      debugPrint("[DEBUG] BookProcessor: Updating book status to processing for book ID: ${existingBook.id}");
      existingBook.status = ProcessingStatus.processing;
      await isar.writeTxn(() async => await isar.books.put(existingBook));

      try {
        debugPrint("[DEBUG] BookProcessor: Reading file bytes from: $filePath");
        final fileBytes = await File(filePath).readAsBytes();
        debugPrint("[DEBUG] BookProcessor: Read ${fileBytes.length} bytes from file");

        debugPrint("[DEBUG] BookProcessor: Parsing EPUB book");
        final epubBook = await EpubReader.readBook(fileBytes);

        debugPrint("[DEBUG] BookProcessor: Extracted metadata - Title: ${epubBook.Title}, Author: ${epubBook.Author}");
        existingBook.title = epubBook.Title;
        existingBook.author = epubBook.Author;

        if (epubBook.CoverImage != null) {
          debugPrint("[DEBUG] BookProcessor: Extracting cover image");
          // Use the _extractBytes helper method to handle different types
          final coverBytes = _extractBytes(epubBook.CoverImage);
          if (coverBytes != null) {
            existingBook.coverImageBytes = coverBytes;
          } else {
            debugPrint("[WARN] BookProcessor: Could not extract cover image bytes");
          }
        } else {
          debugPrint("[DEBUG] BookProcessor: No cover image found");
        }

        debugPrint("[DEBUG] BookProcessor: Clearing existing content blocks for book ID: ${existingBook.id}");
        await isar.writeTxn(() async {
          final deletedCount = await isar.contentBlocks
              .filter()
              .bookIdEqualTo(existingBook.id)
              .deleteAll();
          debugPrint("[DEBUG] BookProcessor: Deleted $deletedCount existing content blocks");
        });

        final newBlocks = <ContentBlock>[];
        if (epubBook.Chapters != null) {
          debugPrint("[DEBUG] BookProcessor: Processing ${epubBook.Chapters!.length} chapters");

          for (int i = 0; i < epubBook.Chapters!.length; i++) {
            final chapter = epubBook.Chapters![i];
            if (chapter.HtmlContent == null) {
              debugPrint("[WARN] BookProcessor: Chapter $i has no HTML content, skipping");
              continue;
            }

            String? sourcePath = chapter.Anchor;
            if (sourcePath == null) {
              debugPrint("[WARN] BookProcessor: Chapter $i has no anchor path");
            }
            debugPrint("[DEBUG] BookProcessor: Processing chapter $i with source path: $sourcePath");

            final document = html_parser.parse(chapter.HtmlContent!);
            final initialBlockCount = newBlocks.length;

            _processElements(
              document.body?.nodes ?? [],
              i,
              existingBook.id,
              sourcePath,
              newBlocks,
              epubBook,
            );

            final blocksAdded = newBlocks.length - initialBlockCount;
            debugPrint("[DEBUG] BookProcessor: Added $blocksAdded blocks from chapter $i");
          }
        } else {
          debugPrint("[WARN] BookProcessor: Book has no chapters");
        }

        debugPrint("[DEBUG] BookProcessor: Saving ${newBlocks.length} content blocks and updating book status");
        await isar.writeTxn(() async {
          await isar.contentBlocks.putAll(newBlocks);
          existingBook.status = ProcessingStatus.ready;
          await isar.books.put(existingBook);
        });

        debugPrint("[DEBUG] BookProcessor: Book processing completed successfully for book ID: ${existingBook.id}");
      } catch (e, s) {
        debugPrint("[ERROR] BookProcessor: Error processing book: $e");
        debugPrintStack(stackTrace: s);

        existingBook.status = ProcessingStatus.error;
        await isar.writeTxn(() async => await isar.books.put(existingBook));
      }
    } catch (e, s) {
      debugPrint("[ERROR] BookProcessor: Error accessing book in database: $e");
      debugPrintStack(stackTrace: s);
    }
  }

  static void _processElements(
      List<dynamic> nodes,
      int chapterIndex,
      int bookId,
      String? sourcePath,
      List<ContentBlock> blocks,
      EpubBook epubBook,
      {int blockIndexOffset = 0}
      ) {
    try {
      int currentBlockIndex = blockIndexOffset;
      int processedNodes = 0;
      int addedBlocks = 0;

      for (var node in nodes) {
        try {
          if (node.nodeType != 1) continue;
          processedNodes++;

          final element = node;
          final tagName = element.localName?.toLowerCase();

          final textContent = element.text.trim();
          final hasContent = textContent.isNotEmpty;

          if (tagName == 'img') {
            final src = element.attributes['src'];
            if (src != null) {
              debugPrint("[DEBUG] BookProcessor: Processing image with src: $src in chapter $chapterIndex");
              final imageBytes = _getImageBytes(epubBook, src, sourcePath);

              if (imageBytes != null) {
                debugPrint("[DEBUG] BookProcessor: Found image bytes (${imageBytes.length} bytes)");
              } else {
                debugPrint("[WARN] BookProcessor: Could not find image bytes for src: $src");
              }

              final block = ContentBlock()
                ..bookId = bookId
                ..chapterIndex = chapterIndex
                ..blockIndexInChapter = currentBlockIndex++
                ..htmlContent = element.outerHtml
                ..textContent = element.attributes['alt'] ?? ''
                ..blockType = BlockType.img
                ..src = sourcePath
                ..imageBytes = imageBytes;

              blocks.add(block);
              addedBlocks++;
            }
          } else if (hasContent) {
            final blockType = _getBlockType(tagName);

            final block = ContentBlock()
              ..bookId = bookId
              ..chapterIndex = chapterIndex
              ..blockIndexInChapter = currentBlockIndex++
              ..htmlContent = element.outerHtml
              ..textContent = textContent
              ..blockType = blockType
              ..src = sourcePath;

            blocks.add(block);
            addedBlocks++;

            if (blockType == BlockType.h1 || blockType == BlockType.h2) {
              debugPrint("[DEBUG] BookProcessor: Added heading block: '$textContent' (${blockType.toString()})");
            }
          }

          if (element.nodes.isNotEmpty) {
            final childrenCount = element.nodes.length;
            debugPrint("[DEBUG] BookProcessor: Processing $childrenCount child nodes of $tagName element");

            final initialBlocksCount = blocks.length;
            // We need to pass the current block index as the offset for child elements
            // but we shouldn't process child nodes if they've already been processed
            // by a parent element to avoid duplicate blocks
            if (element.parent == null || element.parent.localName == 'body') {
              _processElements(
                element.nodes,
                chapterIndex,
                bookId,
                sourcePath,
                blocks,
                epubBook,
                blockIndexOffset: currentBlockIndex,
              );

              final addedByChildren = blocks.length - initialBlocksCount;
              currentBlockIndex += addedByChildren;
              debugPrint("[DEBUG] BookProcessor: Added $addedByChildren blocks from child nodes");
            } else {
              debugPrint("[DEBUG] BookProcessor: Skipping child nodes processing as they will be handled by parent element");
            }
          }
        } catch (e) {
          debugPrint("[ERROR] BookProcessor: Error processing node in chapter $chapterIndex: $e");
        }
      }

      debugPrint("[DEBUG] BookProcessor: Processed $processedNodes nodes and added $addedBlocks blocks in chapter $chapterIndex");
    } catch (e, stack) {
      debugPrint("[ERROR] BookProcessor: Error in _processElements: $e");
      debugPrintStack(stackTrace: stack);
    }
  }

  // Helper method to extract bytes from EpubByteContentFile
  static List<int>? _extractBytes(dynamic contentFile) {
    try {
      if (contentFile == null) return null;

      // Try different ways to access the content
      if (contentFile is List<int>) {
        return contentFile;
      }

      // For EpubByteContentFile, try to access the Content field
      // This is based on the epubx package version 4.0.0
      try {
        // Try to access the Content field directly
        final content = contentFile.Content;
        if (content is List<int>) {
          return content;
        }
      } catch (_) {}

      // Try to access content field if available (lowercase)
      try {
        final content = contentFile.content;
        if (content is List<int>) {
          return content;
        }
      } catch (_) {}

      // Try to access bytes field if available
      try {
        final bytes = contentFile.bytes;
        if (bytes is List<int>) {
          return bytes;
        }
      } catch (_) {}

      // Try to access Bytes field if available
      try {
        final bytes = contentFile.Bytes;
        if (bytes is List<int>) {
          return bytes;
        }
      } catch (_) {}

      // Try to access the raw content if available
      try {
        final raw = contentFile.Content;
        if (raw != null) {
          // Try to convert to List<int> if it's not already
          if (raw is! List<int>) {
            if (raw is String) {
              return raw.codeUnits;
            } else {
              // Reflection is not available in this context
              // Try to access bytes directly
              try {
                final bytes = raw.bytes;
                if (bytes is List<int>) {
                  return bytes;
                }
              } catch (_) {}
            }
          }
        }
      } catch (_) {}

      // Last resort: try to convert the object to string and then to bytes
      try {
        return contentFile.toString().codeUnits;
      } catch (_) {}

      return null;
    } catch (e) {
      debugPrint("[ERROR] BookProcessor: Error extracting bytes: $e");
      return null;
    }
  }

  static List<int>? _getImageBytes(EpubBook epubBook, String src, String? sourcePath) {
    try {
      final cleanSrc = src.split('?').first.split('#').first.toLowerCase();
      debugPrint("[DEBUG] BookProcessor: Looking for image with cleaned src: $cleanSrc");

      if (epubBook.Content?.Images == null) {
        debugPrint("[WARN] BookProcessor: Book content or images are null");
        return null;
      }

      // Try multiple path resolution strategies
      final List<String> possiblePaths = [];

      // 1. Direct match with the src
      possiblePaths.add(cleanSrc);

      // 2. Try to resolve relative to the chapter path
      if (sourcePath != null && sourcePath.isNotEmpty) {
        try {
          final resolvedPath = p.normalize(p.join(p.dirname(sourcePath), cleanSrc)).toLowerCase();
          possiblePaths.add(resolvedPath);
          debugPrint("[DEBUG] BookProcessor: Added resolved path: $resolvedPath");

          // 3. Also try with different directory separators
          final altPath = resolvedPath.replaceAll('\\', '/');
          if (altPath != resolvedPath) {
            possiblePaths.add(altPath);
            debugPrint("[DEBUG] BookProcessor: Added alternative path with forward slashes: $altPath");
          }
        } catch (e) {
          debugPrint("[WARN] BookProcessor: Failed to resolve path for src: $cleanSrc, sourcePath: $sourcePath, error: $e");
        }
      }

      // 4. Try just the filename without path
      final fileName = p.basename(cleanSrc).toLowerCase();
      possiblePaths.add(fileName);
      debugPrint("[DEBUG] BookProcessor: Added filename-only path: $fileName");

      final images = epubBook.Content!.Images!;
      debugPrint("[DEBUG] BookProcessor: Searching through ${images.length} images using ${possiblePaths.length} possible paths");

      // First try exact matches
      for (var entry in images.entries) {
        final key = entry.key.toLowerCase();

        for (final path in possiblePaths) {
          if (key == path) {
            debugPrint("[DEBUG] BookProcessor: Found exact match for image: ${entry.key}");
            try {
              final bytes = _extractBytes(entry.value);
              if (bytes != null) {
                debugPrint("[DEBUG] BookProcessor: Extracted ${bytes.length} bytes for image");
                return bytes;
              } else {
                debugPrint("[WARN] BookProcessor: Could not extract bytes from image: ${entry.key}");
              }
            } catch (e, stack) {
              debugPrint("[ERROR] BookProcessor: Failed to extract image bytes for ${entry.key}: $e");
              debugPrintStack(stackTrace: stack);
              continue; // Try next path
            }
          }
        }
      }

      // Then try partial matches
      for (var entry in images.entries) {
        final key = entry.key.toLowerCase();

        for (final path in possiblePaths) {
          if (key.endsWith(path) || path.endsWith(key)) {
            debugPrint("[DEBUG] BookProcessor: Found partial match for image: ${entry.key} with path: $path");
            try {
              final bytes = _extractBytes(entry.value);
              if (bytes != null) {
                debugPrint("[DEBUG] BookProcessor: Extracted ${bytes.length} bytes for image");
                return bytes;
              } else {
                debugPrint("[WARN] BookProcessor: Could not extract bytes from image: ${entry.key}");
              }
            } catch (e, stack) {
              debugPrint("[ERROR] BookProcessor: Failed to extract image bytes for ${entry.key}: $e");
              debugPrintStack(stackTrace: stack);
              continue; // Try next path
            }
          }
        }
      }

      // Log all available image keys for debugging
      debugPrint("[WARN] BookProcessor: No matching image found. Available images:");
      for (var entry in images.entries) {
        debugPrint("[WARN] BookProcessor: - ${entry.key}");
      }

      debugPrint("[WARN] BookProcessor: No matching image found for any of these paths: $possiblePaths");
      return null;
    } catch (e, stack) {
      debugPrint("[ERROR] BookProcessor: Unexpected error in _getImageBytes: $e");
      debugPrintStack(stackTrace: stack);
      return null;
    }
  }

  static BlockType _getBlockType(String? tagName) {
    if (tagName == null) {
      debugPrint("[WARN] BookProcessor: Null tag name, returning unsupported block type");
      return BlockType.unsupported;
    }

    final lowerTagName = tagName.toLowerCase();
    BlockType result;

    switch (lowerTagName) {
      case 'p':
        result = BlockType.p;
        break;
      case 'h1':
        result = BlockType.h1;
        break;
      case 'h2':
        result = BlockType.h2;
        break;
      case 'h3':
        result = BlockType.h3;
        break;
      case 'h4':
        result = BlockType.h4;
        break;
      case 'h5':
        result = BlockType.h5;
        break;
      case 'h6':
        result = BlockType.h6;
        break;
      case 'img':
        result = BlockType.img;
        break;
      default:
        result = BlockType.unsupported;
        break;
    }

    return result;
  }
}
