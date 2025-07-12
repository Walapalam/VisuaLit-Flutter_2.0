import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:html/parser.dart' as html_parser;
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/domain/book_page.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';

class BookPaginator {
  final List<ContentBlock> allBlocks;
  final Size viewSize;
  final ReadingPreferences preferences;

  final Map<int, BookPage> _pageCache = {};
  final Map<int, int> _blockToPageMap = {};
  final Map<String, int> _locationToBlockIndexMap = {};

  int _totalPages = 1;
  bool _isPaginationComplete = false;

  BookPaginator._({
    required this.allBlocks,
    required this.viewSize,
    required this.preferences,
  });

  static Future<BookPaginator> create({
    required List<ContentBlock> allBlocks,
    required Size viewSize,
    required ReadingPreferences preferences,
  }) async {
    print("⏳ [BookPaginator] Create method called. Starting pagination...");
    final paginator = BookPaginator._(
      allBlocks: allBlocks,
      viewSize: viewSize,
      preferences: preferences,
    );
    paginator._buildLocationMap();
    await paginator._calculateAllPages();
    print("✅ [BookPaginator] Pagination complete. Returning instance.");
    return paginator;
  }


  void _buildLocationMap() {
    for (int i = 0; i < allBlocks.length; i++) {
      final block = allBlocks[i];
      if (block.src != null) {
        if (!_locationToBlockIndexMap.containsKey(block.src!)) {
          _locationToBlockIndexMap[block.src!] = i;
        }
        if (block.htmlContent != null) {
          final document = html_parser.parseFragment(block.htmlContent!);
          final elementWithId = document.querySelector('[id]');
          if (elementWithId != null) {
            final id = elementWithId.attributes['id'];
            if (id != null && id.isNotEmpty) {
              final locationKey = '${block.src}#$id';
              _locationToBlockIndexMap[locationKey] = i;
            }
          }
        }
      }
    }
    print("ℹ️ [BookPaginator] Built location map with ${_locationToBlockIndexMap.length} entries.");
  }

  int findBlockIndexByLocation(String src, String? fragment) {
    if (fragment != null && fragment.isNotEmpty) {
      final key = '$src#$fragment';
      if (_locationToBlockIndexMap.containsKey(key)) {
        return _locationToBlockIndexMap[key]!;
      }
    }
    return _locationToBlockIndexMap[src] ?? -1;
  }

  int get totalPages => _isPaginationComplete ? _totalPages : 0;
  bool get isPaginationComplete => _isPaginationComplete;

  int? getPageForBlock(int blockIndex) {
    if (!_isPaginationComplete) return null;
    return _blockToPageMap[blockIndex];
  }

  BookPage? getPage(int pageIndex) {
    if (_pageCache.containsKey(pageIndex)) {
      return _pageCache[pageIndex];
    }
    return null;
  }

  Future<void> _calculateAllPages() async {
    print("  [BookPaginator] Starting _calculateAllPages...");
    if (allBlocks.isEmpty) {
      _isPaginationComplete = true;
      print("  [BookPaginator] No blocks to process. Finished.");
      return;
    }

    int currentPageIndex = 0;
    int currentBlockIndex = 0;

    // We leave a 20 pixel margin on all sides for the content.
    final double availableHeight = viewSize.height - 40;
    final double availableWidth = viewSize.width - 40;

    print("  [BookPaginator] Viewport size for pagination: ${availableWidth.toStringAsFixed(1)}w x ${availableHeight.toStringAsFixed(1)}h");


    while (currentBlockIndex < allBlocks.length) {
      final List<ContentBlock> pageBlocks = [];
      double currentY = 0;
      int startingBlockIndex = currentBlockIndex;

      // Map the starting block of this page to the current page index
      _blockToPageMap[startingBlockIndex] = currentPageIndex;

      while (currentBlockIndex < allBlocks.length) {
        final block = allBlocks[currentBlockIndex];

        // Use the shared styling logic from the preferences class
        final textStyle = preferences.getStyleForBlock(block.blockType);

        final textPainter = TextPainter(
          text: TextSpan(text: block.textContent, style: textStyle),
          textDirection: ui.TextDirection.ltr,
          textAlign: TextAlign.justify,
        )..layout(maxWidth: availableWidth);

        // Add a bit of padding between blocks
        final blockHeight = textPainter.height + 12;

        // If this block won't fit, break the loop and finish the current page.
        // The check for pageBlocks.isNotEmpty ensures we don't create empty pages
        // if a single block is too large for the screen.
        if (currentY + blockHeight > availableHeight && pageBlocks.isNotEmpty) {
          break;
        }

        pageBlocks.add(block);
        currentY += blockHeight;
        currentBlockIndex++;
      }

      // Cache the completed page
      _pageCache[currentPageIndex] = BookPage(
        pageIndex: currentPageIndex,
        blocks: pageBlocks,
        startingBlockIndex: startingBlockIndex,
        endingBlockIndex: currentBlockIndex - 1,
      );

      if (currentPageIndex % 50 == 0) { // Log progress
        print("    [BookPaginator] Calculated page $currentPageIndex...");
      }

      currentPageIndex++;
    }

    _totalPages = currentPageIndex;
    _isPaginationComplete = true;
    print("✅ [BookPaginator] Finished calculation! Total pages: $_totalPages");
  }
}