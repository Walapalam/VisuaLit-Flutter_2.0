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

  @enumerated
  ProcessingStatus status = ProcessingStatus.queued;

  // --- FIX: Add the required fields for reading state ---
  int lastReadPage = 0;
  DateTime? lastReadTimestamp;

  /// The chapter index the user was last reading. Essential for the JIT loader.
  int? lastReadChapter;

  /// The total number of chapters in the book. Essential for pre-fetching logic.
  int chaptersCount = 0;

  /// The total number of content blocks in the book. Essential for robust cache validation.
  int blocksCount = 0;
  // --- END OF FIX ---

  List<TOCEntry> toc = [];
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
  String? src;
  @enumerated
  late BlockType blockType;
  String? htmlContent;
  String? textContent;
  List<byte>? imageBytes;
}