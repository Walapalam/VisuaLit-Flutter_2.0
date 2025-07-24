import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/data/highlight.dart';
import 'package:visualit/features/reader/presentation/highlights_provider.dart';
import 'package:visualit/features/reader/presentation/reading_controller.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';

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

  String _generateOverrideCss(ReadingPreferences prefs) {
    final resetCss = """
      body, div, h1, h2, h3, h4, h5, h6, li, blockquote, td, th, a {
        font-family: '${prefs.fontFamily}' !important;
        font-size: ${prefs.fontSize}px !important;
        line-height: ${prefs.lineSpacing} !important;
        color: ${Color(prefs.textColor.value).toCss()} !important;
        background-color: transparent !important;
        text-align: left !important;
        margin: 0 !important;
        padding: 0 !important;
        text-indent: 0 !important;
      }
    """;

    final indentCss = """
      p {
        text-indent: ${prefs.textIndent}em !important;
        margin-bottom: 0.5em !important;
      }
    """;

    final lineGuideCss = prefs.isLineGuideEnabled
        ? """
      p::before {
        content: '';
        display: block;
        height: 1px;
        background-color: ${Color(prefs.textColor.value).withOpacity(0.3).toCss()};
        margin-bottom: 2px;
      }
    """
        : "";

    return resetCss + indentCss + lineGuideCss;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(readingPreferencesProvider);
    final highlightsAsync = ref.watch(highlightsProvider(block.bookId!));

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

    final blockHighlights = highlightsAsync.asData?.value
        .where((h) =>
    h.blockIndexInChapter == block.blockIndexInChapter &&
        h.chapterIndex == block.chapterIndex)
        .toList() ??
        [];

    blockHighlights.sort((a, b) => a.startOffset.compareTo(b.startOffset));

    final injectedCss = _generateOverrideCss(preferences);
    final contentWithHighlights = _injectHighlightTags(block.htmlContent!, blockHighlights);
    final finalHtml = '<style>$injectedCss</style>$contentWithHighlights';

    return SelectionArea(
      child: HtmlWidget(
        finalHtml,
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

extension ToCss on Color {
  String toCss() => 'rgba($red, $green, $blue, ${alpha / 255})';
}