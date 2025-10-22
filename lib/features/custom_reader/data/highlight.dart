// dart
import 'package:isar/isar.dart';

part 'highlight.g.dart';

@collection
class Highlight {
  Id id = Isar.autoIncrement;
  int bookId;
  int chapterIndex;
  int startOffset;
  int endOffset;
  int colorValue;

  Highlight({
    required this.bookId,
    required this.chapterIndex,
    required this.startOffset,
    required this.endOffset,
    required this.colorValue,
  });
}
