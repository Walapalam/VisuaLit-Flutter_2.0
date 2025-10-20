// dart
import 'package:isar/isar.dart';

part 'new_reading_progress.g.dart';

@collection
class NewReadingProgress {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late int bookId; // The ID of the book this progress belongs to

  late String lastChapterHref; // The last chapter the user was reading
  late double lastScrollOffset; // The scroll position within the chapter
}
