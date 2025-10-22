// dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'highlight_poc_controller.dart';
import 'package:visualit/features/custom_reader/data/highlight.dart';

class HighlightPOC extends ConsumerWidget {
  final String text;
  final int bookId;
  final int chapterIndex;

  const HighlightPOC({
    Key? key,
    required this.text,
    required this.bookId,
    required this.chapterIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highlights = ref.watch(highlightProvider);

    return SelectableText.rich(
      _buildTextSpan(text, highlights),
      onSelectionChanged: (selection, cause) {
        if (selection.baseOffset != selection.extentOffset) {
          final highlight = Highlight(
            bookId: bookId,
            chapterIndex: chapterIndex,
            startOffset: selection.baseOffset,
            endOffset: selection.extentOffset,
            colorValue: Colors.yellow.value,
          );
          ref.read(highlightProvider.notifier).addHighlight(highlight);
        }
      },
    );
  }

  TextSpan _buildTextSpan(String text, List<Highlight> highlights) {
    if (highlights.isEmpty) return TextSpan(text: text);

    final spans = <TextSpan>[];
    int current = 0;

    for (final h in highlights..sort((a, b) => a.startOffset.compareTo(b.startOffset))) {
      if (current < h.startOffset) {
        spans.add(TextSpan(text: text.substring(current, h.startOffset)));
      }
      spans.add(TextSpan(
        text: text.substring(h.startOffset, h.endOffset),
        style: TextStyle(backgroundColor: Color(h.colorValue)),
      ));
      current = h.endOffset;
    }
    if (current < text.length) {
      spans.add(TextSpan(text: text.substring(current)));
    }
    return TextSpan(children: spans);
  }
}
