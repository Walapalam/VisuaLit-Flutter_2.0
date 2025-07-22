import 'dart:typed_data';
import 'package:visualit/features/reader/data/toc_entry.dart';

/// Data Transfer Object for passing parsed book data between isolates
class ParsedBookDTO {
  final String title;
  final String author;
  final Uint8List? coverImageBytes;
  final String? publisher;
  final String? language;
  final DateTime? publicationDate;
  final List<TOCEntry> toc;
  final List<ParsedContentBlockDTO> contentBlocks;

  ParsedBookDTO({
    required this.title,
    required this.author,
    this.coverImageBytes,
    this.publisher,
    this.language,
    this.publicationDate,
    required this.toc,
    required this.contentBlocks,
  });
}

/// Data Transfer Object for content blocks parsed from EPUB
class ParsedContentBlockDTO {
  final int chapterIndex;
  final int blockIndexInChapter;
  final String? src;
  final String blockType;
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