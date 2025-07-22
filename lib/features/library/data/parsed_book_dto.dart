import 'dart:typed_data';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/data/toc_entry.dart';

/// Data Transfer Object for parsed book data.
/// This class decouples the parsing logic from storage operations.
class ParsedBookDTO {
  final String title;
  final String author;
  final Uint8List? coverImageBytes;
  final List<TOCEntry> toc;
  final String? publisher;
  final String? language;
  final DateTime? publicationDate;
  final List<ParsedChapterDTO> chapters;
  
  ParsedBookDTO({
    required this.title,
    required this.author,
    this.coverImageBytes,
    required this.toc,
    this.publisher,
    this.language,
    this.publicationDate,
    required this.chapters,
  });
}

/// Data Transfer Object for a parsed chapter.
class ParsedChapterDTO {
  final int index;
  final String title;
  final String path;
  final List<ParsedContentBlockDTO> blocks;
  
  ParsedChapterDTO({
    required this.index,
    required this.title,
    required this.path,
    required this.blocks,
  });
}

/// Data Transfer Object for a parsed content block.
class ParsedContentBlockDTO {
  final BlockType blockType;
  final String htmlContent;
  final String textContent;
  final Uint8List? imageBytes;
  
  ParsedContentBlockDTO({
    required this.blockType,
    required this.htmlContent,
    required this.textContent,
    this.imageBytes,
  });
}