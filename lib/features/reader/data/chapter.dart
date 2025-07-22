import 'package:isar/isar.dart';

part 'chapter.g.dart';

/// A model representing a chapter in a book.
/// This model improves content organization and enables efficient navigation/rendering.
@collection
class Chapter {
  Id id = Isar.autoIncrement;
  
  /// Reference to the parent book
  @Index()
  int? bookId;
  
  /// Chapter title
  String title;
  
  /// Order index in the book
  int orderIndex;
  
  /// Reference to parent chapter for nested chapters (optional)
  int? parentChapterId;
  
  /// Path to the chapter file in the EPUB
  String? sourcePath;
  
  /// Constructor
  Chapter({
    this.bookId,
    required this.title,
    required this.orderIndex,
    this.parentChapterId,
    this.sourcePath,
  });
}