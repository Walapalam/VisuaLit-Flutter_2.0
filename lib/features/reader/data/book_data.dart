import 'package:isar/isar.dart';

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

  @enumerated
  ProcessingStatus status = ProcessingStatus.queued;
}

@collection
class ContentBlock {
  Id id = Isar.autoIncrement;

  @Index()
  int? bookId;

  @Index()
  int? chapterIndex;

  int? blockIndexInChapter;

  @enumerated
  late BlockType blockType;

  String? htmlContent;
  String? textContent;
}