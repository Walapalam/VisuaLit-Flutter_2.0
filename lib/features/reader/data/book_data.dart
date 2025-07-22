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

  @enumerated
  ProcessingStatus status = ProcessingStatus.queued;

  int lastReadPage = 0;
  DateTime? lastReadTimestamp;

  // Last update timestamp for sync conflict resolution
  DateTime updatedAt = DateTime.now();

  // ID of the corresponding document in Appwrite
  String? serverId;

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
