import 'package:isar/isar.dart';

part 'layout_cache.g.dart';

@collection
class LayoutCache {
  Id id = Isar.autoIncrement;

  /// A unique key generated from bookId, device dimensions, and font settings
  @Index(unique: true, replace: true)
  late String layoutKey;

  /// The book ID this layout is for
  @Index()
  late int bookId;

  /// A map of page indices to block indices
  /// Stored as a serialized JSON string
  late String pageToBlockMap;

  /// When this layout was created or last updated
  late DateTime timestamp;
}