import 'package:isar/isar.dart';
import 'package:visualit/features/reader/data/toc_entry.dart';

part 'book_data.g.dart';

// ---- Enums ----
enum ProcessingStatus { queued, processing, ready, error, partiallyReady }

enum BlockType { p, h1, h2, h3, h4, h5, h6, blockquote, li, hr, img, pre, div, unsupported }

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

  @enumerated
  ProcessingStatus status = ProcessingStatus.queued;

  // Error tracking
  String? errorMessage;
  String? errorStackTrace;
  String? processingMetadata; // Additional metadata for debugging
  bool failedPermanently = false;
  int retryCount = 0;

  // Reading progress
  int lastReadPage = 0;
  DateTime? lastReadTimestamp;

  // File size tracking for cache management
  int? fileSizeInBytes;
  DateTime? lastAccessedAt;

  // Progressive loading tracking
  List<int> processedChapters = [];
  int totalChapters = 0;
  double processingProgress = 0.0; // 0.0 to 1.0

  // Format versioning
  bool isNewFormat = false; // Indicates if the book is stored using the new block-based format

  List<TOCEntry> toc = [];
}

@collection
class ContentBlock {
  Id id = Isar.autoIncrement;

  @Index()
  int? bookId;

  @Index()
  int? chapterId; // Reference to Chapter model

  // Keep for backward compatibility
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

  // Search index fields
  List<String>? tokenizedText; // Words split and normalized for search
  List<String>? stemmedText;   // Stemmed words for better search matching

  // Store image data directly if the block is an image
  List<byte>? imageBytes;

  // Size tracking for cache management
  int? sizeInBytes;
}
