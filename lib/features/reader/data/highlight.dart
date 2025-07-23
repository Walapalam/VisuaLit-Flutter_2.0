import 'package:isar/isar.dart';
import 'package:visualit/core/models/syncable_entity.dart';

part 'highlight.g.dart';

@collection
class Highlight implements SyncableEntity {
  Id id = Isar.autoIncrement;

  @Index()
  late int bookId;

  /// Composite index to efficiently query highlights within a chapter and by block order
  @Index(composite: [
    CompositeIndex('blockIndexInChapter', type: IndexType.value),
  ])
  int? chapterIndex;

  /// Index of the block within the chapter where the highlight exists
  int? blockIndexInChapter;

  /// The selected text content
  late String text;

  /// The start offset of the selection within the block's plain text
  late int startOffset;

  /// The end offset of the selection within the block's plain text
  late int endOffset;

  /// The ARGB color value of the highlight
  late int color;

  /// Timestamp when the highlight was created
  DateTime timestamp = DateTime.now();

  /// Optional user annotation/note
  String? note;

  // ---------- SyncableEntity fields ----------

  /// Unique identifier for synchronization across devices
  @override
  String? syncId;

  /// Timestamp of last local modification
  @override
  DateTime lastModified = DateTime.now();

  /// Whether this entity has unsynced local changes
  @override
  bool isDirty = true;

  /// Marks this entity as dirty and updates lastModified
  @override
  void markDirty() {
    lastModified = DateTime.now();
    isDirty = true;
  }
}
