import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:visualit/features/reader/data/toc_entry.dart';

part 'book_data.g.dart';

// ---- Enums ----
enum ProcessingStatus { queued, processing, ready, error }

enum BlockType { p, h1, h2, h3, h4, h5, h6, img, unsupported }

// ---- Collections ----
@collection
class Book {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String epubFilePath;

  String? title;
  String? author;
  List<byte>? coverImageBytes;

  // New metadata fields
  String? publisher;
  String? language;
  DateTime? publicationDate;
  String? isbn;

  @enumerated
  ProcessingStatus status = ProcessingStatus.queued;

  int lastReadPage = 0;
  DateTime? lastReadTimestamp;

  List<TOCEntry> toc = [];
}

// Extension methods for debugging Book class
extension BookDebug on Book {
  // Log the book details
  void debugLog() {
    debugPrint("[DEBUG] Book: id: $id, title: ${title ?? 'Untitled'}, author: ${author ?? 'Unknown'}");
    debugPrint("[DEBUG] Book: path: $epubFilePath, status: $status");
    debugPrint("[DEBUG] Book: lastReadPage: $lastReadPage, lastReadTimestamp: $lastReadTimestamp");

    if (publisher != null || language != null || publicationDate != null || isbn != null) {
      debugPrint("[DEBUG] Book: metadata - publisher: $publisher, language: $language, date: $publicationDate, ISBN: $isbn");
    }

    debugPrint("[DEBUG] Book: TOC entries: ${toc.length}");
    if (toc.isNotEmpty) {
      for (int i = 0; i < toc.length && i < 5; i++) {
        debugPrint("[DEBUG] Book: TOC[$i]: ${toc[i].title ?? 'Untitled'} -> ${toc[i].src}");
      }
      if (toc.length > 5) {
        debugPrint("[DEBUG] Book: ... and ${toc.length - 5} more TOC entries");
      }
    }
  }

  // Get a string representation of the book
  String toDebugString() {
    return "Book(id: $id, title: ${title ?? 'Untitled'}, author: ${author ?? 'Unknown'}, " +
           "status: $status, lastReadPage: $lastReadPage, TOC: ${toc.length} entries)";
  }
}

@collection
class ContentBlock {
  Id id = Isar.autoIncrement;

  @Index()
  int? bookId;

  @Index()
  int? chapterIndex;

  int? blockIndexInChapter;

  @Index()
  String? src; // The source XHTML file of this block

  @enumerated
  late BlockType blockType;

  // Now the primary source for rendering
  String? htmlContent;

  // Keep plain text for searching, indexing, or simple displays
  String? textContent;

  // Store image data directly if the block is an image
  List<byte>? imageBytes;
}

// Extension methods for debugging ContentBlock class
extension ContentBlockDebug on ContentBlock {
  // Log the content block details
  void debugLog() {
    debugPrint("[DEBUG] ContentBlock: id: $id, bookId: $bookId, chapter: $chapterIndex, blockIndex: $blockIndexInChapter");
    debugPrint("[DEBUG] ContentBlock: type: $blockType, src: $src");

    if (textContent != null && textContent!.isNotEmpty) {
      final displayText = textContent!.length > 50 ? '${textContent!.substring(0, 47)}...' : textContent;
      debugPrint("[DEBUG] ContentBlock: text: '$displayText'");
    }

    if (imageBytes != null) {
      debugPrint("[DEBUG] ContentBlock: image data: ${imageBytes!.length} bytes");
    }

    if (htmlContent != null) {
      final htmlPreview = htmlContent!.length > 50 ? '${htmlContent!.substring(0, 47)}...' : htmlContent;
      debugPrint("[DEBUG] ContentBlock: html: '$htmlPreview'");
    }
  }

  // Get a string representation of the content block
  String toDebugString() {
    final textPreview = textContent != null && textContent!.isNotEmpty
        ? (textContent!.length > 20 ? "'${textContent!.substring(0, 17)}...'" : "'$textContent'")
        : "null";

    return "ContentBlock(id: $id, bookId: $bookId, chapter: $chapterIndex, " +
           "blockIndex: $blockIndexInChapter, type: $blockType, " +
           "text: $textPreview, hasImage: ${imageBytes != null})";
  }
}

// Static helper methods for debugging
class BookDataUtils {
  // Log a list of books
  static void debugLogBooks(List<Book> books, [String message = ""]) {
    debugPrint("[DEBUG] BookDataUtils: $message - ${books.length} books");
    for (int i = 0; i < books.length; i++) {
      debugPrint("[DEBUG] BookDataUtils: [$i] ${books[i].toDebugString()}");
    }
  }

  // Log a list of content blocks
  static void debugLogContentBlocks(List<ContentBlock> blocks, [String message = ""]) {
    debugPrint("[DEBUG] BookDataUtils: $message - ${blocks.length} content blocks");
    for (int i = 0; i < blocks.length && i < 10; i++) {
      debugPrint("[DEBUG] BookDataUtils: [$i] ${blocks[i].toDebugString()}");
    }
    if (blocks.length > 10) {
      debugPrint("[DEBUG] BookDataUtils: ... and ${blocks.length - 10} more blocks");
    }
  }

  // Get a string representation of a processing status
  static String processingStatusToString(ProcessingStatus status) {
    switch (status) {
      case ProcessingStatus.queued: return "Queued";
      case ProcessingStatus.processing: return "Processing";
      case ProcessingStatus.ready: return "Ready";
      case ProcessingStatus.error: return "Error";
      default: return "Unknown";
    }
  }

  // Get a string representation of a block type
  static String blockTypeToString(BlockType type) {
    switch (type) {
      case BlockType.p: return "Paragraph";
      case BlockType.h1: return "Heading 1";
      case BlockType.h2: return "Heading 2";
      case BlockType.h3: return "Heading 3";
      case BlockType.h4: return "Heading 4";
      case BlockType.h5: return "Heading 5";
      case BlockType.h6: return "Heading 6";
      case BlockType.img: return "Image";
      case BlockType.unsupported: return "Unsupported";
      default: return "Unknown";
    }
  }
}
