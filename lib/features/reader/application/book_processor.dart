import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
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

        // Save blocks in batches to avoid transaction timeouts with large books
        const int batchSize = 500; // Configurable batch size
        int totalSaved = 0;

        for (int i = 0; i < newBlocks.length; i += batchSize) {
          final int end = (i + batchSize < newBlocks.length) ? i + batchSize : newBlocks.length;
          final batch = newBlocks.sublist(i, end);

          debugPrint("[DEBUG] BookProcessor: Saving batch ${i ~/ batchSize + 1} with ${batch.length} blocks (${i + 1}-$end of ${newBlocks.length})");

          await isar.writeTxn(() async {
            await isar.contentBlocks.putAll(batch);
          });

          totalSaved += batch.length;
          debugPrint("[DEBUG] BookProcessor: Saved ${batch.length} blocks, total saved: $totalSaved/${newBlocks.length}");
        }

        // Calculate pagination
        debugPrint("[DEBUG] BookProcessor: Calculating pagination for book");
        final pages = _calculatePagination(newBlocks, existingBook.id);

        // Convert pages to pageToBlockMap format
        List<int> pageToBlockMap = [];
        for (final page in pages) {
          pageToBlockMap.add(page.pageIndex);
          pageToBlockMap.add(page.startingBlockIndex);
        }

        // Update book with pagination data and status
        await isar.writeTxn(() async {
          existingBook.pageToBlockMap = pageToBlockMap;
          existingBook.totalPages = pages.isNotEmpty ? pages.last.pageIndex + 1 : 0;
          existingBook.status = ProcessingStatus.ready;
          await isar.books.put(existingBook);
          debugPrint("[DEBUG] BookProcessor: Updated book with pagination data (${existingBook.totalPages} pages) and status");
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
          // Skip non-element nodes (text nodes, comments, etc.)
          if (node.nodeType != 1) continue;
          processedNodes++;

          final element = node;
          final tagName = element.localName?.toLowerCase();

          // Skip empty or null tags
          if (tagName == null) {
            debugPrint("[WARN] BookProcessor: Skipping node with null tag name");
            continue;
          }

          // Get text content and check if it has content
          final textContent = element.text.trim();
          final hasContent = textContent.isNotEmpty;
          final hasAttributes = element.attributes.isNotEmpty;
          final hasChildren = element.nodes.isNotEmpty;

          // Process image elements
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
                ..htmlContent = _basicSanitizeHtml(element.outerHtml)
                ..textContent = element.attributes['alt'] ?? ''
                ..blockType = BlockType.img
                ..src = sourcePath
                ..imageBytes = imageBytes;

              blocks.add(block);
              addedBlocks++;
            }
          } 
          // Process elements with content or attributes (like links, spans with styles, etc.)
          else if (hasContent || (hasAttributes && _isSignificantElement(tagName))) {
            final blockType = _getBlockType(tagName);

            final block = ContentBlock()
              ..bookId = bookId
              ..chapterIndex = chapterIndex
              ..blockIndexInChapter = currentBlockIndex++
              ..htmlContent = _basicSanitizeHtml(element.outerHtml)
              ..textContent = textContent
              ..blockType = blockType
              ..src = sourcePath;

            blocks.add(block);
            addedBlocks++;

            if (blockType == BlockType.h1 || blockType == BlockType.h2) {
              debugPrint("[DEBUG] BookProcessor: Added heading block: '$textContent' (${blockType.toString()})");
            }
          }
          // Process container elements with no direct content but with children
          else if (hasChildren && _isContainerElement(tagName)) {
            debugPrint("[DEBUG] BookProcessor: Processing container element: $tagName");

            // For container elements, we want to process their children
            // but we don't create a block for the container itself
            final childrenCount = element.nodes.length;
            debugPrint("[DEBUG] BookProcessor: Processing $childrenCount child nodes of $tagName element");

            final initialBlocksCount = blocks.length;

            // Process child nodes
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
            debugPrint("[DEBUG] BookProcessor: Added $addedByChildren blocks from child nodes of $tagName");
          }
          // Process child nodes for elements that might contain important content
          else if (hasChildren) {
            final childrenCount = element.nodes.length;
            debugPrint("[DEBUG] BookProcessor: Element $tagName has no direct content but has $childrenCount children");

            final initialBlocksCount = blocks.length;

            // Only process children if this is a top-level element or a container
            // This helps avoid duplicate processing
            if (element.parent == null || 
                element.parent.localName == 'body' || 
                _isContainerElement(element.parent.localName)) {

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
              debugPrint("[DEBUG] BookProcessor: Skipping child nodes of $tagName as they will be handled by parent element");
            }
          }
        } catch (e, stack) {
          debugPrint("[ERROR] BookProcessor: Error processing node in chapter $chapterIndex: $e");
          debugPrintStack(stackTrace: stack);
          // Continue with next node instead of skipping the entire chapter
        }
      }

      debugPrint("[DEBUG] BookProcessor: Processed $processedNodes nodes and added $addedBlocks blocks in chapter $chapterIndex");
    } catch (e, stack) {
      debugPrint("[ERROR] BookProcessor: Error in _processElements: $e");
      debugPrintStack(stackTrace: stack);
    }
  }

  // Helper method to determine if an element is a significant inline element
  // that should be preserved even without text content
  static bool _isSignificantElement(String tagName) {
    const significantElements = [
      'a', 'span', 'em', 'strong', 'b', 'i', 'u', 'sup', 'sub', 
      'code', 'mark', 'small', 'big', 'strike', 'tt', 'cite'
    ];
    return significantElements.contains(tagName);
  }

  // Helper method to determine if an element is a container that should have its children processed
  static bool _isContainerElement(String? tagName) {
    if (tagName == null) return false;

    const containerElements = [
      'div', 'section', 'article', 'main', 'aside', 'nav',
      'header', 'footer', 'ul', 'ol', 'li', 'dl', 'dt', 'dd',
      'table', 'tr', 'td', 'th', 'thead', 'tbody', 'tfoot',
      'blockquote', 'figure', 'figcaption'
    ];
    return containerElements.contains(tagName.toLowerCase());
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
      // Clean the source URL by removing query parameters and fragments
      final cleanSrc = src.split('?').first.split('#').first;
      final cleanSrcLower = cleanSrc.toLowerCase();
      debugPrint("[DEBUG] BookProcessor: Looking for image with cleaned src: $cleanSrc");

      // Check if the book has images
      if (epubBook.Content?.Images == null) {
        debugPrint("[WARN] BookProcessor: Book content or images collection is null");
        return null;
      }

      final images = epubBook.Content!.Images!;
      if (images.isEmpty) {
        debugPrint("[WARN] BookProcessor: Book has no images");
        return null;
      }

      debugPrint("[DEBUG] BookProcessor: Book has ${images.length} images");

      // Build a comprehensive list of possible paths to try
      final List<String> possiblePaths = [];
      final List<String> exactPaths = [];
      final Map<String, String> pathMapping = {}; // Maps normalized paths to original keys

      // 1. Direct match with the src (both original case and lowercase)
      exactPaths.add(cleanSrc);
      exactPaths.add(cleanSrcLower);

      // 2. Try to resolve relative to the chapter path
      if (sourcePath != null && sourcePath.isNotEmpty) {
        try {
          // Get directory of the current chapter
          final sourceDir = p.dirname(sourcePath);

          // Resolve path relative to chapter
          final resolvedPath = p.normalize(p.join(sourceDir, cleanSrc));
          final resolvedPathLower = resolvedPath.toLowerCase();

          exactPaths.add(resolvedPath);
          exactPaths.add(resolvedPathLower);

          debugPrint("[DEBUG] BookProcessor: Added resolved path: $resolvedPath");

          // Try with different directory separators
          final forwardSlashPath = resolvedPath.replaceAll('\\', '/');
          final backslashPath = resolvedPath.replaceAll('/', '\\');

          if (forwardSlashPath != resolvedPath) {
            exactPaths.add(forwardSlashPath);
            exactPaths.add(forwardSlashPath.toLowerCase());
            debugPrint("[DEBUG] BookProcessor: Added path with forward slashes: $forwardSlashPath");
          }

          if (backslashPath != resolvedPath) {
            exactPaths.add(backslashPath);
            exactPaths.add(backslashPath.toLowerCase());
            debugPrint("[DEBUG] BookProcessor: Added path with backslashes: $backslashPath");
          }
        } catch (e) {
          debugPrint("[WARN] BookProcessor: Failed to resolve path for src: $cleanSrc, sourcePath: $sourcePath, error: $e");
        }
      }

      // 3. Try just the filename without path (both original case and lowercase)
      final fileName = p.basename(cleanSrc);
      final fileNameLower = fileName.toLowerCase();
      possiblePaths.add(fileName);
      possiblePaths.add(fileNameLower);
      debugPrint("[DEBUG] BookProcessor: Added filename-only paths: $fileName, $fileNameLower");

      // 4. Build a normalized map of all images for easier lookup
      for (var entry in images.entries) {
        final originalKey = entry.key;
        final normalizedKey = p.normalize(originalKey).toLowerCase();
        pathMapping[normalizedKey] = originalKey;

        // Also add variants with different separators
        pathMapping[normalizedKey.replaceAll('\\', '/')] = originalKey;
        pathMapping[normalizedKey.replaceAll('/', '\\')] = originalKey;

        // Add just the filename
        final entryFileName = p.basename(originalKey).toLowerCase();
        if (!pathMapping.containsKey(entryFileName)) {
          pathMapping[entryFileName] = originalKey;
        }
      }

      debugPrint("[DEBUG] BookProcessor: Created ${pathMapping.length} normalized path mappings");
      debugPrint("[DEBUG] BookProcessor: Trying ${exactPaths.length} exact paths and ${possiblePaths.length} partial paths");

      // First try exact matches (case sensitive and insensitive)
      for (final exactPath in exactPaths) {
        // Direct lookup in the images map
        if (images.containsKey(exactPath)) {
          debugPrint("[DEBUG] BookProcessor: Found direct match for image: $exactPath");
          final bytes = _extractBytes(images[exactPath]);
          if (bytes != null) {
            debugPrint("[DEBUG] BookProcessor: Successfully extracted ${bytes.length} bytes");
            return bytes;
          }
        }

        // Lookup in our normalized path mapping
        final normalizedPath = p.normalize(exactPath).toLowerCase();
        if (pathMapping.containsKey(normalizedPath)) {
          final originalKey = pathMapping[normalizedPath]!;
          debugPrint("[DEBUG] BookProcessor: Found normalized match: $normalizedPath -> $originalKey");
          final bytes = _extractBytes(images[originalKey]);
          if (bytes != null) {
            debugPrint("[DEBUG] BookProcessor: Successfully extracted ${bytes.length} bytes");
            return bytes;
          }
        }
      }

      // Then try partial matches (ends with, contains)
      for (final partialPath in [...exactPaths, ...possiblePaths]) {
        for (var entry in images.entries) {
          final key = entry.key;
          final keyLower = key.toLowerCase();

          // Check if the key ends with our path or vice versa
          if (keyLower.endsWith(partialPath.toLowerCase()) || 
              partialPath.toLowerCase().endsWith(keyLower)) {
            debugPrint("[DEBUG] BookProcessor: Found partial match: $key ~ $partialPath");
            final bytes = _extractBytes(entry.value);
            if (bytes != null) {
              debugPrint("[DEBUG] BookProcessor: Successfully extracted ${bytes.length} bytes");
              return bytes;
            }
          }
        }
      }

      // As a last resort, try to find an image with a similar name
      final fileNameWithoutExt = p.basenameWithoutExtension(fileName).toLowerCase();
      if (fileNameWithoutExt.isNotEmpty) {
        debugPrint("[DEBUG] BookProcessor: Trying to find image with similar name: $fileNameWithoutExt");
        for (var entry in images.entries) {
          final entryFileName = p.basenameWithoutExtension(entry.key).toLowerCase();
          if (entryFileName.contains(fileNameWithoutExt) || 
              fileNameWithoutExt.contains(entryFileName)) {
            debugPrint("[DEBUG] BookProcessor: Found similar filename: ${entry.key}");
            final bytes = _extractBytes(entry.value);
            if (bytes != null) {
              debugPrint("[DEBUG] BookProcessor: Successfully extracted ${bytes.length} bytes");
              return bytes;
            }
          }
        }
      }

      // Log all available image keys for debugging
      debugPrint("[WARN] BookProcessor: No matching image found for: $cleanSrc");
      debugPrint("[WARN] BookProcessor: Available images:");
      for (var entry in images.entries) {
        debugPrint("[WARN] BookProcessor: - ${entry.key}");
      }

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

  // Basic HTML sanitization to remove potentially problematic content
  static String _basicSanitizeHtml(String html) {
    try {
      debugPrint("[DEBUG] BookProcessor: Performing basic HTML sanitization");

      // Very simple sanitization - just remove the most problematic elements
      String sanitized = html;

      // Remove script tags (simple approach)
      if (sanitized.contains("<script")) {
        sanitized = sanitized.replaceAll("<script", "<!-- script");
        sanitized = sanitized.replaceAll("</script>", "end script -->");
      }

      // Remove style tags (simple approach)
      if (sanitized.contains("<style")) {
        sanitized = sanitized.replaceAll("<style", "<!-- style");
        sanitized = sanitized.replaceAll("</style>", "end style -->");
      }

      return sanitized;
    } catch (e) {
      debugPrint("[ERROR] BookProcessor: Error in basic HTML sanitization: $e");
      return html; // Return original HTML if there's an error
    }
  }

  // Calculate pagination based on block content and type
  static List<BookPage> _calculatePagination(List<ContentBlock> blocks, int bookId) {
    try {
      debugPrint("[DEBUG] BookProcessor: Calculating pagination for ${blocks.length} blocks");

      // Constants for pagination calculation
      const int averageCharsPerPage = 2000; // Approximate characters per page
      const double headingMultiplier = 2.5; // Headings take more space
      const double imageMultiplier = 5.0; // Images take more space

      List<BookPage> pages = [];
      int currentPageIndex = 0;
      int currentPageSize = 0;
      int startingBlockIndex = 0;
      int? currentChapterIndex;

      for (int i = 0; i < blocks.length; i++) {
        final block = blocks[i];
        int blockSize = 0;

        // Update current chapter if needed
        if (currentChapterIndex != block.chapterIndex) {
          currentChapterIndex = block.chapterIndex;

          // Start a new page for each chapter
          if (i > 0 && currentPageSize > 0) {
            // Save the current page
            pages.add(BookPage()
              ..bookId = bookId
              ..pageIndex = currentPageIndex
              ..startingBlockIndex = startingBlockIndex
              ..endingBlockIndex = i - 1
              ..chapterIndex = blocks[startingBlockIndex].chapterIndex);

            // Start a new page
            currentPageIndex++;
            startingBlockIndex = i;
            currentPageSize = 0;
          }
        }

        // Calculate block size based on content and type
        switch (block.blockType) {
          case BlockType.h1:
          case BlockType.h2:
          case BlockType.h3:
          case BlockType.h4:
          case BlockType.h5:
          case BlockType.h6:
            // Headings take more space
            blockSize = (block.textContent?.length ?? 0) * headingMultiplier.toInt();
            break;
          case BlockType.img:
            // Images take a lot of space
            blockSize = averageCharsPerPage * imageMultiplier.toInt();
            break;
          case BlockType.p:
          case BlockType.unsupported:
          default:
            // Regular paragraphs
            blockSize = block.textContent?.length ?? 0;
            break;
        }

        // Check if we need to start a new page
        if (currentPageSize + blockSize > averageCharsPerPage && i > startingBlockIndex) {
          // Save the current page
          pages.add(BookPage()
            ..bookId = bookId
            ..pageIndex = currentPageIndex
            ..startingBlockIndex = startingBlockIndex
            ..endingBlockIndex = i - 1
            ..chapterIndex = blocks[startingBlockIndex].chapterIndex);

          // Start a new page
          currentPageIndex++;
          startingBlockIndex = i;
          currentPageSize = blockSize;
        } else {
          // Add to current page
          currentPageSize += blockSize;
        }
      }

      // Add the last page if there are any blocks left
      if (startingBlockIndex < blocks.length) {
        pages.add(BookPage()
          ..bookId = bookId
          ..pageIndex = currentPageIndex
          ..startingBlockIndex = startingBlockIndex
          ..endingBlockIndex = blocks.length - 1
          ..chapterIndex = blocks[startingBlockIndex].chapterIndex);
      }

      debugPrint("[DEBUG] BookProcessor: Calculated ${pages.length} pages for ${blocks.length} blocks");
      return pages;
    } catch (e, stack) {
      debugPrint("[ERROR] BookProcessor: Error calculating pagination: $e");
      debugPrintStack(stackTrace: stack);
      return [];
    }
  }

}
