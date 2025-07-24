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
  String? publisher;
  String? language;
  DateTime? publicationDate;
  int chapterCount = 0;

  @enumerated
  ProcessingStatus status = ProcessingStatus.queued;

  // --- CORRECTED PROGRESS TRACKING ---
  /// Stores the index of the last read chapter.
  int lastReadChapterIndex = 0;

  /// Stores the page number within the last read chapter.
  int lastReadPageInChapter = 0;

  DateTime? lastReadTimestamp;

  List<TOCEntry> toc = [];
}

// The ContentBlock class remains unchanged.
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

  String? htmlContent;
  String? textContent;
  List<byte>? imageBytes;
}