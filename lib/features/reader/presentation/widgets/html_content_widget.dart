import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:visualit/features/reader/data/book_data.dart' as isar_models;
import 'package:visualit/features/reader/data/new_models.dart' as new_models;
import 'package:visualit/features/reader/data/highlight.dart';
import 'package:visualit/features/reader/presentation/highlights_provider.dart';
import 'package:visualit/features/reader/presentation/reading_controller.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';

// The widget is now a simple ConsumerWidget as it no longer manages selection state.
class HtmlContentWidget extends ConsumerWidget {
  final dynamic _block;
  final int blockIndex;
  final Size viewSize;

  // Internal properties to normalize access regardless of ContentBlock type
  late final int? _bookId;
  late final int? _chapterIndex;
  late final int? _blockIndexInChapter;
  late final String? _src;
  late final dynamic _blockType;
  late final String? _htmlContent;
  late final String? _textContent;
  late final dynamic _imageBytes;

  // Constructor for isar_models.ContentBlock
  HtmlContentWidget.fromIsarModel({
    super.key,
    required isar_models.ContentBlock block,
    required this.blockIndex,
    required this.viewSize,
  }) : _block = block {
    _bookId = block.bookId;
    _chapterIndex = block.chapterIndex;
    _blockIndexInChapter = block.blockIndexInChapter;
    _src = block.src;
    _blockType = block.blockType;
    _htmlContent = block.htmlContent;
    _textContent = block.textContent;
    _imageBytes = block.imageBytes;
  }

  // Constructor for new_models.ContentBlock
  HtmlContentWidget.fromNewModel({
    super.key,
    required new_models.ContentBlock block,
    required this.blockIndex,
    required this.viewSize,
  }) : _block = block {
    _bookId = block.bookId;
    _chapterIndex = block.chapterIndex;
    _blockIndexInChapter = block.blockIndexInChapter;
    _src = block.src;
    _blockType = block.blockType;
    _htmlContent = block.htmlContent;
    _textContent = block.textContent;
    _imageBytes = block.imageBytes;
  }

  // Factory constructor to handle either type
  factory HtmlContentWidget({
    Key? key,
    required dynamic block,
    required int blockIndex,
    required Size viewSize,
  }) {
    if (block is isar_models.ContentBlock) {
      return HtmlContentWidget.fromIsarModel(
        key: key,
        block: block,
        blockIndex: blockIndex,
        viewSize: viewSize,
      );
    } else if (block is new_models.ContentBlock) {
      return HtmlContentWidget.fromNewModel(
        key: key,
        block: block,
        blockIndex: blockIndex,
        viewSize: viewSize,
      );
    } else {
      throw ArgumentError('Block must be either isar_models.ContentBlock or new_models.ContentBlock');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(readingPreferencesProvider);
    final highlightsAsync = ref.watch(highlightsProvider(_bookId!));

    // Handle image blocks
    if ((_blockType is isar_models.BlockType && _blockType == isar_models.BlockType.img) || 
        (_blockType is new_models.BlockType && _blockType == new_models.BlockType.img)) {
      if (_imageBytes != null) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Image.memory(
            _imageBytes is Uint8List 
                ? _imageBytes 
                : Uint8List.fromList(_imageBytes),
            fit: BoxFit.contain,
            height: viewSize.height * 0.6,
          ),
        );
      }
    }

    if (_htmlContent == null || _htmlContent!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final blockHighlights = highlightsAsync.asData?.value.where((h) =>
        h.blockIndexInChapter == _blockIndexInChapter &&
        h.chapterIndex == _chapterIndex
    ).toList() ?? [];

    blockHighlights.sort((a, b) => a.startOffset.compareTo(b.startOffset));

    return SelectionArea(
      // The contextMenuBuilder has been removed entirely to eliminate the source of the error.
      // This will cause the default OS text selection menu to appear (Copy, Select All, etc.).
      child: HtmlWidget(
        // The logic to render existing highlights remains.
        _injectHighlightTags(_htmlContent!, blockHighlights),
        textStyle: preferences.getStyleForBlock(_getBlockTypeForPreferences()),
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
          if (_src != null && _bookId != null) {
            ref.read(readingControllerProvider(_bookId!).notifier).jumpToHref(url, _src!);
            return true;
          }
          return false;
        },
      ),
    );
  }

  // Helper method to convert block type to the format expected by preferences
  isar_models.BlockType _getBlockTypeForPreferences() {
    if (_blockType is isar_models.BlockType) {
      return _blockType as isar_models.BlockType;
    } else if (_blockType is new_models.BlockType) {
      // Convert new_models.BlockType to isar_models.BlockType
      switch (_blockType) {
        case new_models.BlockType.p: return isar_models.BlockType.p;
        case new_models.BlockType.h1: return isar_models.BlockType.h1;
        case new_models.BlockType.h2: return isar_models.BlockType.h2;
        case new_models.BlockType.h3: return isar_models.BlockType.h3;
        case new_models.BlockType.h4: return isar_models.BlockType.h4;
        case new_models.BlockType.h5: return isar_models.BlockType.h5;
        case new_models.BlockType.h6: return isar_models.BlockType.h6;
        case new_models.BlockType.img: return isar_models.BlockType.img;
        default: return isar_models.BlockType.unsupported;
      }
    }
    return isar_models.BlockType.unsupported;
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
