import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/domain/book_page.dart';

class BookPaginator {
  final List<ContentBlock> allBlocks;
  final Size viewSize;
  final TextStyle textStyle;
  final EdgeInsets margins;

  final Map<int, BookPage> _pageCache = {};

  BookPaginator({
    required this.allBlocks,
    required this.viewSize,
    required this.textStyle,
    required this.margins,
  });

  BookPage getPage(int pageIndex) {
    print('BookPaginator: getPage called for page $pageIndex');
    print('BookPaginator: Total blocks available: ${allBlocks.length}');

    if (allBlocks.isEmpty) {
      print('BookPaginator: ERROR - No blocks available');
      return BookPage(
        pageIndex: pageIndex,
        blocks: [],
        startingBlockIndex: 0,
        endingBlockIndex: 0,
      );
    }

    // Simple pagination - show 10 blocks per page for debugging
    const blocksPerPage = 10;
    final startIndex = pageIndex * blocksPerPage;
    final endIndex = math.min(startIndex + blocksPerPage, allBlocks.length);

    print('BookPaginator: Page $pageIndex - Start index: $startIndex, End index: $endIndex');

    if (startIndex >= allBlocks.length) {
      print('BookPaginator: ERROR - Start index $startIndex exceeds available blocks ${allBlocks.length}');
      return BookPage(
        pageIndex: pageIndex,
        blocks: [],
        startingBlockIndex: startIndex,
        endingBlockIndex: startIndex,
      );
    }

    final pageBlocks = allBlocks.sublist(startIndex, endIndex);
    print('BookPaginator: Page $pageIndex created with ${pageBlocks.length} blocks');

    if (pageBlocks.isNotEmpty) {
      print('BookPaginator: First block in page: ${pageBlocks.first.textContent?.substring(0, math.min(50, pageBlocks.first.textContent?.length ?? 0))}...');
    }

    return BookPage(
      pageIndex: pageIndex,
      blocks: pageBlocks,
      startingBlockIndex: startIndex,
      endingBlockIndex: endIndex - 1,
    );
  }
}