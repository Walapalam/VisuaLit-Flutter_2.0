// lib/features/reader/data/toc_entry.dart
import 'package:isar/isar.dart';

part 'toc_entry.g.dart';

@embedded // Marks this class as an embedded object in Isar
class TOCEntry {
  String? title;          // Title of the TOC entry (e.g., "Chapter 1")
  String? src;            // Path to the chapter file (e.g., "chapter1.xhtml")
  String? fragment;       // ID within the file (e.g., "section2")
  int? blockIndexStart;   // Index of the first content block for this TOC entry

  List<TOCEntry> children = []; // Nested sub-sections or child entries
}
