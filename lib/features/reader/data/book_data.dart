import 'package:isar/isar.dart';
import 'package:visualit/features/reader/data/toc_entry.dart';

part 'book_data.g.dart';

// ---- Enums ----
enum ProcessingStatus { queued, processing, ready, error, partiallyReady }

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

  // Metadata fields
  String? isbn;
  String? publisher;
  String? language;
  DateTime? publicationDate;

  @enumerated
  ProcessingStatus status = ProcessingStatus.queued;

  // Error tracking
  String? errorMessage;
  String? errorStackTrace;
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
  double processingProgress = 0.0;

  // TOC is ignored by Isar (stored/loaded separately or as embedded later)
  @ignore
  List<TOCEntry> toc = [];
}

@collection
class ContentBlock {
  Id id = Isar.autoIncrement;

  @Index()
  int? bookId;

  @Index()
  int? chapterId; // Reserved for future chapter model linking

  @Index()
  int? chapterIndex; // Fallback if chapterId not used

  int? blockIndexInChapter;

  @Index()
  String? src;

  @enumerated
  late BlockType blockType;

  String? htmlContent;
  String? textContent;

  List<String>? tokenizedText;
  List<String>? stemmedText;

  List<byte>? imageBytes;

  int? sizeInBytes;
}
