import 'package:isar/isar.dart';
import 'package:visualit/core/models/syncable_entity.dart';

part 'bookmark.g.dart';

/// Model for bookmarks in a book.
@collection
class Bookmark implements SyncableEntity {
  Id id = Isar.autoIncrement;
  
  /// Reference to the book
  @Index()
  late int bookId;
  
  /// Chapter index where the bookmark is placed
  int? chapterIndex;
  
  /// Page index where the bookmark is placed
  int pageIndex = 0;
  
  /// Position within the page (scroll position)
  double scrollPosition = 0.0;
  
  /// Optional title or note for the bookmark
  String? title;
  
  /// Timestamp when the bookmark was created
  DateTime createdAt = DateTime.now();
  
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
  
  /// Constructor
  Bookmark({
    required this.bookId,
    this.chapterIndex,
    required this.pageIndex,
    this.scrollPosition = 0.0,
    this.title,
  }) {
    markDirty();
  }
}