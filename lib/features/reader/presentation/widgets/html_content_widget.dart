import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/presentation/reading_controller.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';
// Import TextHighlight if defined elsewhere, or define it here
// import 'package:visualit/features/reader/presentation/reading_screen.dart'; // For TextHighlight model

// Minimal definition for compilation if not imported
class TextHighlight {
  final int blockIndex;
  final int startOffset;
  final int endOffset;
  final Color color;
  TextHighlight({
    required this.blockIndex,
    required this.startOffset,
    required this.endOffset,
    required this.color,
  });
}

class HtmlContentWidget extends ConsumerWidget {
  final ContentBlock block;
  final int blockIndex;
  final Size viewSize;
  final List<TextHighlight> highlights;
  final void Function(TextSelection?, RenderObject?, String?)? onSelectionChanged;

  const HtmlContentWidget({
    super.key,
    required this.block,
    required this.blockIndex,
    required this.viewSize,
    this.highlights = const [],
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(readingPreferencesProvider);

    if (block.blockType == BlockType.img && block.imageBytes != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Image.memory(
          Uint8List.fromList(block.imageBytes!),
          fit: BoxFit.contain,
          height: viewSize.height * 0.6,
        ),
      );
    }

    if (block.htmlContent == null || block.htmlContent!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final htmlWithHighlights = _injectHighlightTags(block.htmlContent!, highlights);

    return HtmlWidget(
      htmlWithHighlights,
      textStyle: preferences.getStyleForBlock(block.blockType),
      buildAsync: true,
      customStylesBuilder: (element) {
        if (element.localName == 'mark' && element.classes.contains('visualit-highlight')) {
          final colorValue = element.attributes['data-color'];
          if (colorValue != null) {
            return {'background-color': colorValue};
          }
        }
        return null;
      },
      // If your flutter_widget_from_html version supports onSelectionChanged, uncomment below:
      // onSelectionChanged: (selection, renderObject) {
      //   onSelectionChanged?.call(selection, renderObject, block.textContent);
      // },
      onTapUrl: (url) {
        if (block.src != null && block.bookId != null) {
          ref.read(readingControllerProvider(block.bookId!).notifier).jumpToHref(url, block.src!);
          return true;
        }
        return false;
      },
    );
  }

  String _injectHighlightTags(String html, List<TextHighlight> highlights) {
    if (highlights.isEmpty) return html;

    var result = html;
    int offset = 0;

    final sortedHighlights = List<TextHighlight>.from(highlights)
      ..sort((a, b) => a.startOffset.compareTo(b.startOffset));

    for (final h in sortedHighlights) {
      final color = h.color;
      final colorString = 'rgba(${color.red},${color.green},${color.blue},${(color.alpha / 255).toStringAsFixed(2)})';
      final startTag = '<mark class="visualit-highlight" data-color="$colorString">';
      final endTag = '</mark>';

      final start = h.startOffset + offset;
      final end = h.endOffset + offset;

      if (start >= 0 && end <= result.length && start < end) {
        result = result.substring(0, start) +
            startTag +
            result.substring(start, end) +
            endTag +
            result.substring(end);
        offset += startTag.length + endTag.length;
      }
    }
    return result;
  }
}