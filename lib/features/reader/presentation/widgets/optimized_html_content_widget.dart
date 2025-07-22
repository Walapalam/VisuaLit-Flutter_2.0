import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:flutter_widget_from_html_core/src/core_data.dart';
import 'package:flutter_widget_from_html_core/src/core_widget_factory.dart';
import 'package:fwfh_text_style/fwfh_text_style.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/data/highlight.dart';
import 'package:visualit/features/reader/presentation/highlights_provider.dart';
import 'package:visualit/features/reader/presentation/reading_controller.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';

/// A more performant widget for rendering HTML content blocks
/// Uses flutter_widget_from_html_core instead of the full package
/// Directly converts HTML to Flutter's native RichText widget
class OptimizedHtmlContentWidget extends ConsumerWidget {
  final ContentBlock block;
  final int blockIndex;
  final Size viewSize;

  const OptimizedHtmlContentWidget({
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

    // Handle image blocks specially
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

    // Skip empty blocks
    if (block.htmlContent == null || block.htmlContent!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    // Process highlights
    final blockHighlights = highlightsAsync.asData?.value.where((h) =>
      h.blockIndexInChapter == block.blockIndexInChapter &&
      h.chapterIndex == block.chapterIndex
    ).toList() ?? [];

    blockHighlights.sort((a, b) => a.startOffset.compareTo(b.startOffset));

    // Use the core package with text style plugin for better performance
    return SelectionArea(
      child: HtmlWidget(
        _injectHighlightTags(block.htmlContent!, blockHighlights),
        textStyle: preferences.getStyleForBlock(block.blockType),
        // Use only essential factories for better performance
        factoryBuilder: () => _CoreHtmlWidgetFactory(),
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

/// A custom factory that supports common e-book HTML features while maintaining performance
class _CoreHtmlWidgetFactory extends WidgetFactory with TextStyleFactory {
  // Enable essential features for e-books
  @override
  bool get enableCssTextDecorationThickness => true;

  @override
  bool get enableCssTextDecorationWidth => true;

  // Add support for common e-book elements
  @override
  Widget? buildImage(BuildTree tree, ImageMetadata meta) {
    // Enhanced image handling with proper sizing and loading indicators
    if (meta.sources.isEmpty) return null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;

        return Image.network(
          meta.sources.first.url,
          fit: BoxFit.contain,
          width: meta.dimensions?.width?.toDouble() ?? maxWidth,
          height: meta.dimensions?.height?.toDouble(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / 
                      loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: meta.dimensions?.width?.toDouble() ?? 100,
              height: meta.dimensions?.height?.toDouble() ?? 100,
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            );
          },
        );
      }
    );
  }

  // Add support for tables
  @override
  Widget? buildTable(BuildTree tree) {
    // Basic table support
    final rows = <TableRow>[];
    final context = tree.context;

    // Create a simple table with the child widgets
    final children = tree.children;
    if (children.isEmpty) return null;

    for (final child in children) {
      final cells = <Widget>[];

      for (final cellChild in child.children) {
        final isHeader = cellChild.element?.localName == 'th';

        final padding = isHeader 
            ? const EdgeInsets.all(8.0) 
            : const EdgeInsets.all(4.0);

        final decoration = BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          color: isHeader ? Colors.grey[200] : null,
        );

        cells.add(
          Container(
            padding: padding,
            decoration: decoration,
            child: DefaultTextStyle.merge(
              style: isHeader 
                  ? const TextStyle(fontWeight: FontWeight.bold) 
                  : null,
              child: buildChild(cellChild),
            ),
          ),
        );
      }

      if (cells.isNotEmpty) {
        rows.add(TableRow(children: cells));
      }
    }

    return Table(
      border: TableBorder.all(color: Colors.grey[400]!),
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: rows,
    );
  }

  // Add support for lists
  @override
  Widget? buildListItem(BuildTree tree) {
    final context = tree.context;
    final isOrderedList = tree.element?.parent?.localName == 'ol';
    final index = int.tryParse(tree.element?.attributes['value'] ?? '') ?? 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          child: isOrderedList 
              ? Text('$index. ', style: const TextStyle(fontWeight: FontWeight.bold))
              : const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(child: buildChild(tree)),
      ],
    );
  }

  // Add support for block quotes
  @override
  Widget? buildBlockquote(BuildTree tree) {
    final context = tree.context;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 8.0),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 4.0,
          ),
        ),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontStyle: FontStyle.italic),
        child: buildChild(tree),
      ),
    );
  }
}
