import 'package:isar/isar.dart';

part 'bookmark.g.dart';

@collection
class Bookmark {
  Id id = Isar.autoIncrement;

  @Index()
  late int bookId;

  @Index()
  int? chapterIndex;

  int? blockIndexInChapter;

  // The page number of the bookmark
  late int pageNumber;

  // Optional title for the bookmark
  String? title;

  // Optional note for the bookmark
  String? note;

  // Creation timestamp
  DateTime createdAt = DateTime.now();

  // Last update timestamp for sync conflict resolution
  DateTime updatedAt = DateTime.now();

  // ID of the corresponding document in Appwrite
  String? serverId;
}