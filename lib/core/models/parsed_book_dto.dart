import 'dart:typed_data';
import 'package:visualit/core/models/content_block_schema.dart';

/// Data Transfer Object for a parsed book
class ParsedBookDTO {
  final String title;
  final String author;
  final String? publisher;
  final String? language;
  final DateTime? publicationDate;
  final Uint8List? coverImageBytes;
  final List<ParsedTOCEntryDTO> tocEntries;
  final List<ParsedChapterDTO> chapters;

  ParsedBookDTO({
    required this.title,
    required this.author,
    this.publisher,
    this.language,
    this.publicationDate,
    this.coverImageBytes,
    required this.tocEntries,
    required this.chapters,
  });
}

/// Data Transfer Object for a parsed chapter
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

/// Data Transfer Object for a parsed content block
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

/// Data Transfer Object for a parsed table of contents entry
class ParsedTOCEntryDTO {
  final String title;
  final String? src;
  final String? fragment;
  final List<ParsedTOCEntryDTO> children;

  ParsedTOCEntryDTO({
    required this.title,
    this.src,
    this.fragment,
    this.children = const [],
  });
}