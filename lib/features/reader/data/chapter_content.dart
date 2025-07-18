import 'package:isar/isar.dart';

part 'chapter_content.g.dart';

@collection
class ChapterContent {
  Id id = Isar.autoIncrement;

  @Index()
  int bookId = 0;      // Reference to the parent book

  String? title;       // Chapter title
  String? src;         // Source path in the EPUB file
  String? textContent; // Plain text content of the chapter
  String? htmlContent; // HTML/XHTML content of the chapter

  // Constructor
  ChapterContent({
    this.title,
    this.src,
    this.textContent,
    this.htmlContent,
    this.bookId = 0,
  });
}

// Extension methods for debugging
extension ChapterContentDebug on ChapterContent {
  // Log the chapter content details
  void debugLog([String prefix = ""]) {
    print("$prefix ChapterContent: title: $title, src: $src");
    print("$prefix TextContent length: ${textContent?.length ?? 0}");
    print("$prefix HTMLContent length: ${htmlContent?.length ?? 0}");
  }

  // Get a string representation of the chapter content
  String toDebugString() {
    return "ChapterContent(title: $title, src: $src, textLength: ${textContent?.length ?? 0}, htmlLength: ${htmlContent?.length ?? 0})";
  }
}
