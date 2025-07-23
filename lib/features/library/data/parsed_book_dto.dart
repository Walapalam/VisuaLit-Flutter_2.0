import 'dart:typed_data';
import 'package:visualit/features/reader/data/book_data.dart'; // For BlockType enum
import 'package:visualit/features/reader/data/toc_entry.dart'; // For TOCEntry

/// A Data Transfer Object to carry all parsed book data from the isolate
/// back to the main thread. This is a plain Dart object with no Isar annotations.
class ParsedBookDTO {
  final String title;
  final String? author;
  final String? publisher;
  final String? language;
  final DateTime? publicationDate;
  final Uint8List? coverImageBytes;
  final List<TOCEntry> toc;
  final List<ParsedContentBlockDTO> blocks;

  ParsedBookDTO({
    required this.title,
    this.author,
    this.publisher,
    this.language,
    this.publicationDate,
    this.coverImageBytes,
    required this.toc,
    required this.blocks,
  });
}

/// A DTO for a single content block.
class ParsedContentBlockDTO {
  final int chapterIndex;
  final int blockIndexInChapter;
  final String? src;
  final BlockType blockType;
  final String? htmlContent;
  final String? textContent;
  final Uint8List? imageBytes;

  ParsedContentBlockDTO({
    required this.chapterIndex,
    required this.blockIndexInChapter,
    this.src,
    required this.blockType,
    this.htmlContent,
    this.textContent,
    this.imageBytes,
  });
}