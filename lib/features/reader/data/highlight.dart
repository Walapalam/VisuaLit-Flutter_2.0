import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'highlight.g.dart';

@collection
class Highlight {
  Id id = Isar.autoIncrement;

  @Index()
  late int bookId;

  // A composite index to quickly find all highlights for a specific chapter.
  @Index(composite: [
    CompositeIndex('blockIndexInChapter', type: IndexType.value)
  ])
  int? chapterIndex;

  int? blockIndexInChapter;

  /// The selected text content.
  late String text;

  /// The start offset of the selection within the block's plain text.
  late int startOffset;

  /// The end offset of the selection within the block's plain text.
  late int endOffset;

  /// The ARGB color value of the highlight.
  late int color;

  DateTime timestamp = DateTime.now();

  String? note; // For future annotation features
}

// Extension methods for debugging
extension HighlightDebug on Highlight {
  // Log the highlight details
  void debugLog() {
    debugPrint("[DEBUG] Highlight: id: $id, bookId: $bookId, chapter: $chapterIndex, block: $blockIndexInChapter");
    debugPrint("[DEBUG] Highlight: text: '${text.length > 50 ? '${text.substring(0, 47)}...' : text}'");
    debugPrint("[DEBUG] Highlight: offsets: $startOffset-$endOffset, color: ${_colorToString(color)}");
    if (note != null && note!.isNotEmpty) {
      debugPrint("[DEBUG] Highlight: note: '${note!.length > 50 ? '${note!.substring(0, 47)}...' : note}'");
    }
  }

  // Get a string representation of the highlight
  String toDebugString() {
    return "Highlight(id: $id, bookId: $bookId, chapter: $chapterIndex, block: $blockIndexInChapter, " +
           "text: '${text.length > 20 ? '${text.substring(0, 17)}...' : text}', " +
           "offsets: $startOffset-$endOffset, color: ${_colorToString(color)})";
  }

  // Convert color int to a readable string
  String _colorToString(int colorValue) {
    final color = Color(colorValue);
    return "rgba(${color.red}, ${color.green}, ${color.blue}, ${color.alpha / 255})";
  }
}

// Static helper methods for debugging
class HighlightUtils {
  // Log a list of highlights
  static void debugLogHighlights(List<Highlight> highlights, [String message = ""]) {
    debugPrint("[DEBUG] HighlightUtils: $message - ${highlights.length} highlights");
    for (int i = 0; i < highlights.length; i++) {
      debugPrint("[DEBUG] HighlightUtils: [$i] ${highlights[i].toDebugString()}");
    }
  }

  // Create a debug highlight for testing
  static Highlight createDebugHighlight({
    int id = 0,
    required int bookId,
    int chapterIndex = 0,
    int blockIndex = 0,
    String text = "Debug highlight text",
    int startOffset = 0,
    int endOffset = 20,
    int color = 0xFFFFFF00, // Yellow
  }) {
    debugPrint("[DEBUG] HighlightUtils: Creating debug highlight for bookId: $bookId");
    final highlight = Highlight()
      ..id = id
      ..bookId = bookId
      ..chapterIndex = chapterIndex
      ..blockIndexInChapter = blockIndex
      ..text = text
      ..startOffset = startOffset
      ..endOffset = endOffset
      ..color = color
      ..timestamp = DateTime.now();

    return highlight;
  }
}
