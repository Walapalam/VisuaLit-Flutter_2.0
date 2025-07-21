import 'package:isar/isar.dart';
import 'package:visualit/core/models/syncable_entity.dart';

part 'reading_progress.g.dart';

/// Model for tracking reading progress in a book.
@collection
class ReadingProgress implements SyncableEntity {
  Id id = Isar.autoIncrement;

  /// Reference to the book
  @Index(unique: true)
  late int bookId;

  /// Current page index
  int pageIndex = 0;

  /// Scroll position within the page
  double scrollPosition = 0.0;

  /// Last time the progress was updated
  DateTime lastUpdated = DateTime.now();

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
    lastUpdated = lastModified; // Keep lastUpdated in sync with lastModified
  }

  /// Constructor
  ReadingProgress({
    required this.bookId,
    this.pageIndex = 0,
    this.scrollPosition = 0.0,
  }) {
    markDirty();
  }
}
