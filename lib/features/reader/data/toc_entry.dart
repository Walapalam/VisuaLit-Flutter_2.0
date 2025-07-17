// lib/features/reader/data/toc_entry.dart
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

part 'toc_entry.g.dart';

@embedded
class TOCEntry {
  String? title;
  String? src; // Path to the chapter file, e.g., "chapter1.xhtml"
  String? fragment; // ID within the file, e.g., "section2"

  // For nesting chapters
  List<TOCEntry> children = [];
}

// Extension methods for debugging
extension TOCEntryDebug on TOCEntry {
  // Log the TOC entry details
  void debugLog([String prefix = ""]) {
    debugPrint("[DEBUG] $prefix TOCEntry: title: $title, src: $src, fragment: $fragment, children: ${children.length}");

    // Recursively log children with increased indentation
    if (children.isNotEmpty) {
      for (int i = 0; i < children.length; i++) {
        children[i].debugLog("$prefix  [$i]");
      }
    }
  }

  // Get a string representation of the TOC entry
  String toDebugString() {
    return "TOCEntry(title: $title, src: $src, fragment: $fragment, children: ${children.length})";
  }
}

// Static helper methods for debugging
class TOCEntryUtils {
  // Log a list of TOC entries
  static void debugLogEntries(List<TOCEntry> entries, [String message = ""]) {
    debugPrint("[DEBUG] TOCEntryUtils: $message - ${entries.length} entries");
    for (int i = 0; i < entries.length; i++) {
      entries[i].debugLog("[$i]");
    }
  }
}
