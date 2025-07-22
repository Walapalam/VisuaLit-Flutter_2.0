import 'dart:typed_data';
import 'package:isar/isar.dart';

part 'content_block_schema.g.dart';

/// Enum representing the type of content block
enum BlockType {
  p,      // Paragraph
  h1,     // Heading 1
  h2,     // Heading 2
  h3,     // Heading 3
  h4,     // Heading 4
  h5,     // Heading 5
  h6,     // Heading 6
  img,    // Image
  unsupported // Any other block type we don't specifically handle
}

/// Schema for content blocks in a book
@collection
class ContentBlockSchema {
  Id id = Isar.autoIncrement;

  /// The ID of the book this content block belongs to
  @Index(composite: [CompositeIndex('chapterIndex'), CompositeIndex('blockIndexInChapter')])
  late int bookId;

  /// The index of the chapter this block belongs to
  late int chapterIndex;

  /// The index of this block within its chapter
  late int blockIndexInChapter;

  /// The source file path of this block (usually the chapter XHTML file)
  String? src;

  /// The type of content block (paragraph, heading, image, etc.)
  @enumerated
  late BlockType blockType;

  /// The HTML content of this block
  late String htmlContent;

  /// The plain text content of this block (without HTML tags)
  late String textContent;

  /// The image data if this is an image block
  List<int>? imageBytes;
}
