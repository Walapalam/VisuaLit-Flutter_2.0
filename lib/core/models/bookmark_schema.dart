import 'package:isar/isar.dart';

part 'bookmark_schema.g.dart';

/// Schema for bookmarks in a book
@collection
class BookmarkSchema {
  Id id = Isar.autoIncrement;

  /// The user ID (if authenticated)
  String? userId;

  /// The ID of the book this bookmark belongs to
  @Index(composite: [CompositeIndex('chapterIndex')])
  late int bookId;

  /// The index of the chapter this bookmark belongs to
  late int chapterIndex;

  /// The index of the content block this bookmark points to
  late int blockIndex;

  /// The page number in the book (if available)
  int? pageNumber;

  /// The title of the bookmark (optional)
  String? title;

  /// The text snippet at the bookmark location (optional)
  String? textSnippet;

  /// Timestamps for synchronization
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}