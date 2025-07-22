import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/data/highlight.dart';
import 'package:visualit/features/reader/presentation/highlights_provider.dart';
import 'package:visualit/features/reader/presentation/reading_controller.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';

// The widget is now a simple ConsumerWidget as it no longer manages selection state.
class HtmlContentWidget extends ConsumerWidget {
  final ContentBlock block;
  final int blockIndex;
  final Size viewSize;

  const HtmlContentWidget({
    super.key,
    required this.block,
    required this.blockIndex,
    required this.viewSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(readingPreferencesProvider);
    final highlightsAsync = block.bookId != null 
        ? ref.watch(highlightsProvider(block.bookId!))
        : AsyncValue.data(<Highlight>[]);

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

    final blockHighlights = highlightsAsync.asData?.value.where((h) =>
    h.blockIndexInChapter == block.blockIndexInChapter &&
        h.chapterIndex == block.chapterIndex
    ).toList() ?? [];

    blockHighlights.sort((a, b) => a.startOffset.compareTo(b.startOffset));

    return SelectionArea(
      contextMenuBuilder: (context, selectableRegionState) {
        return AdaptiveTextSelectionToolbar.editableText(
          editableTextState: selectableRegionState as EditableTextState,
          // Add custom menu items for reader-specific actions
          children: <Widget>[
            // Copy action
            TextSelectionToolbarTextButton(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              onPressed: () {
                selectableRegionState.copySelection();
                selectableRegionState.hideToolbar();
              },
              child: const Text('Copy'),
            ),
            // Highlight action
            TextSelectionToolbarTextButton(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              onPressed: () {
                final selectedText = selectableRegionState.getSelectedText();
                if (selectedText != null && selectedText.text.isNotEmpty && block.bookId != null) {
                  // Create a highlight with the selected text
                  ref.read(highlightsProvider(block.bookId!).notifier).addHighlight(
                    blockIndex: blockIndex,
                    chapterIndex: block.chapterIndex ?? 0,
                    startOffset: selectableRegionState.getSelectedText()?.start ?? 0,
                    endOffset: selectableRegionState.getSelectedText()?.end ?? 0,
                    color: Colors.yellow.value,
                  );
                }
                selectableRegionState.hideToolbar();
              },
              child: const Text('Highlight'),
            ),
            // Look up action
            TextSelectionToolbarTextButton(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              onPressed: () {
                final selectedText = selectableRegionState.getSelectedText();
                if (selectedText != null && selectedText.text.isNotEmpty) {
                  // Show a dictionary lookup or search dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Look Up'),
                      content: Text('Looking up: "${selectedText.text}"'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                }
                selectableRegionState.hideToolbar();
              },
              child: const Text('Look Up'),
            ),
          ],
        );
      },
      child: HtmlWidget(
        // The logic to render existing highlights remains.
        _injectHighlightTags(block.htmlContent!, blockHighlights),
        textStyle: preferences.getStyleForBlock(block.blockType),
        customStylesBuilder: (element) {
          if (element.localName == 'highlight') {
            final colorValue = element.attributes['color'];
            if (colorValue != null) {
              return {'background-color': colorValue};
            }
          }
          return null;
        },
        onTapUrl: (url) {
          if (block.src != null && block.bookId != null) {
            ref.read(readingControllerProvider(block.bookId!).notifier).jumpToHref(url, block.src!);
            return true;
          }
          return false;
        },
      ),
    );
  }

  String _injectHighlightTags(String html, List<Highlight> highlights) {
    if (highlights.isEmpty) return html;

    String result = html;
    int offset = 0;

    for (final h in highlights) {
      final color = Color(h.color);
      final colorString = 'rgba(${color.red},${color.green},${color.blue},${(color.alpha / 255).toStringAsFixed(2)})';
      final startTag = '<highlight color="$colorString">';
      final endTag = '</highlight>';

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
