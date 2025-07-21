// lib/features/reader/data/toc_entry.dart
import 'package:isar/isar.dart';

part 'toc_entry.g.dart';

@embedded
class TOCEntry {
  String? title;
  String? src; // Path to the chapter file, e.g., "chapter1.xhtml"
  String? fragment; // ID within the file, e.g., "section2"
  int? blockIndexStart; // Index of the first content block for this TOC entry

  // For nesting chapters
  List<TOCEntry> children = [];
}
