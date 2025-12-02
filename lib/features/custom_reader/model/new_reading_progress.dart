// dart
import 'package:isar/isar.dart';

part 'new_reading_progress.g.dart';

@collection
class NewReadingProgress {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late int bookId; // The ID of the book this progress belongs to

  late String
  lastChapterHref; // The last chapter the user was reading (Scroll Mode)
  late double
  lastScrollOffset; // The scroll position within the chapter (Scroll Mode)
  String?
  lastScrollChapterHref; // The chapter that lastScrollOffset belongs to (Scroll Mode)

  String?
  lastPaginatedChapterHref; // The last chapter the user was reading (Pagination Mode)
  int?
  lastPaginatedPageIndex; // The page index within the chapter (Pagination Mode)
}
