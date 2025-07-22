import 'package:isar/isar.dart';
import 'package:visualit/core/models/syncable_entity.dart';

part 'highlight.g.dart';

@collection
class Highlight implements SyncableEntity {
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

  /// Unique identifier for synchronization across devices.
  @override
  String? syncId;

  /// Timestamp of when this entity was last modified.
  @override
  DateTime lastModified = DateTime.now();

  /// Flag indicating whether this entity has local changes
  /// that need to be synchronized to the server.
  @override
  bool isDirty = true;

  /// Updates the lastModified timestamp to the current time
  /// and marks the entity as dirty.
  @override
  void markDirty() {
    lastModified = DateTime.now();
    isDirty = true;
  }
}
