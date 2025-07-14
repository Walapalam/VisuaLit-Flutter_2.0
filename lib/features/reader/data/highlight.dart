import 'package:isar/isar.dart';

part 'highlight.g.dart';

@collection
class Highlight {
  Id id = Isar.autoIncrement;

  @Index()
  late int bookId;

  // A composite index to quickly find all highlights for a specific chapter.
  @Index(composite: [
    CompositeIndex('blockIndexInChapter', type: IndexType.value)
  ])
  int? chapterIndex;

  int? blockIndexInChapter;

  /// The selected text content.
  late String text;

  /// The start offset of the selection within the block's plain text.
  late int startOffset;

  /// The end offset of the selection within the block's plain text.
  late int endOffset;

  /// The ARGB color value of the highlight.
  late int color;

  DateTime timestamp = DateTime.now();

  String? note; // For future annotation features
}