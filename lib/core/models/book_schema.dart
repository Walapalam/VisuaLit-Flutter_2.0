import 'dart:typed_data';
import 'package:isar/isar.dart';

part 'book_schema.g.dart';

enum ProcessingStatus {
  queued,
  processing,
  ready,
  partiallyReady,
  error
}

@collection
class BookSchema {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String epubFilePath;

  String? title;
  String? author;
  String? publisher;
  String? language;
  DateTime? publicationDate;

  @enumerated
  late ProcessingStatus status;

  // Error handling
  String? errorMessage;
  String? errorStackTrace;
  int retryCount = 0;
  bool failedPermanently = false;

  // Processing progress (0.0 to 1.0)
  double processingProgress = 0.0;

  // Cover image
  List<int>? coverImageBytes;

  // Timestamps
  DateTime createdAt = DateTime.now();
  DateTime? updatedAt;
}
