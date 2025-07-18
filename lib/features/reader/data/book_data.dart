import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:visualit/features/reader/data/toc_entry.dart';
import 'package:visualit/features/reader/data/chapter_content.dart';
import 'package:visualit/features/reader/data/book_image.dart';
import 'package:visualit/features/reader/data/book_styling.dart';

part 'book_data.g.dart';

// ---- Enums ----
enum ProcessingStatus { queued, processing, ready, error }

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
  String? lastReadCfi; // EPUB Content Fragment Identifier for precise location tracking
  DateTime? lastReadTimestamp;

  List<TOCEntry> toc = [];

  // New fields for storing book content
  // Chapters are now stored in a separate collection
  IsarLinks<ChapterContent> chapters = IsarLinks<ChapterContent>();
  List<BookImage> images = []; // Store images other than cover
  BookStyling? styling; // Store styling information
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

    // Log chapter content
    // Note: IsarLinks requires special handling and can't be accessed directly in debug methods
    // This will be populated after the code generator runs
    debugPrint("[DEBUG] Book: Chapters stored in IsarLinks (count not available in debug method)");
    // Detailed chapter logging is skipped as IsarLinks requires special handling

    // Log images
    debugPrint("[DEBUG] Book: Images: ${images.length}");
    if (images.isNotEmpty) {
      for (int i = 0; i < images.length && i < 3; i++) {
        debugPrint("[DEBUG] Book: Image[$i]: ${images[i].name ?? 'Unnamed'}, type: ${images[i].mimeType}, size: ${images[i].imageBytes?.length ?? 0} bytes");
      }
      if (images.length > 3) {
        debugPrint("[DEBUG] Book: ... and ${images.length - 3} more images");
      }
    }

    // Log styling
    if (styling != null) {
      debugPrint("[DEBUG] Book: Styling: ${styling!.styleSheets.length} stylesheets");
      for (int i = 0; i < styling!.styleSheets.length && i < 3; i++) {
        debugPrint("[DEBUG] Book: StyleSheet[$i]: ${styling!.styleSheets[i].href}, length: ${styling!.styleSheets[i].content?.length ?? 0}");
      }
      if (styling!.styleSheets.length > 3) {
        debugPrint("[DEBUG] Book: ... and ${styling!.styleSheets.length - 3} more stylesheets");
      }
    }
  }

  // Get a string representation of the book
  String toDebugString() {
    return "Book(id: $id, title: ${title ?? 'Untitled'}, author: ${author ?? 'Unknown'}, " +
           "status: $status, lastReadPage: $lastReadPage, TOC: ${toc.length} entries, " +
           "chapters: IsarLinks, images: ${images.length}, stylesheets: ${styling?.styleSheets.length ?? 0})";
  }
}

// ContentBlock class removed - EPUB View doesn't need it

// BookPage class removed - EPUB View doesn't need it


// Static helper methods for debugging
class BookDataUtils {
  // Log a list of books
  static void debugLogBooks(List<Book> books, [String message = ""]) {
    debugPrint("[DEBUG] BookDataUtils: $message - ${books.length} books");
    for (int i = 0; i < books.length; i++) {
      debugPrint("[DEBUG] BookDataUtils: [$i] ${books[i].toDebugString()}");
    }
  }

  // ContentBlock debug methods removed - EPUB View doesn't need them

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

  // blockTypeToString method removed - EPUB View doesn't need it
}
