import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/application/book_paginator.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/presentation/reading_providers.dart'; // Add this
import '../domain/book_page.dart';

@immutable
class ReadingState {
  final int bookId;
  final AsyncValue<BookPaginator> paginator;
  final Map<int, BookPage> pageCache;
  final int currentPage;

  const ReadingState({
    required this.bookId,
    required this.paginator,
    this.pageCache = const {},
    this.currentPage = 0,
  });

  ReadingState copyWith({
    int? bookId,
    AsyncValue<BookPaginator>? paginator,
    Map<int, BookPage>? pageCache,
    int? currentPage,
  }) {
    return ReadingState(
      bookId: bookId ?? this.bookId,
      paginator: paginator ?? this.paginator,
      pageCache: pageCache ?? this.pageCache,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class ReadingController extends StateNotifier<ReadingState> {
  final Isar _isar;
  final Size _viewSize;
  final int _blocksPerPage;

  ReadingController(this._isar, int bookId, this._viewSize, this._blocksPerPage)
      : super(ReadingState(bookId: bookId, paginator: const AsyncValue.loading())) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      print('ReadingController: Starting initialization for book ${state.bookId}');

      final textStyle = const TextStyle(fontSize: 18, height: 1.6, fontFamily: 'Georgia');
      final margins = const EdgeInsets.symmetric(horizontal: 20, vertical: 30);

      print('ReadingController: Querying content blocks from database...');
      final blocks = await _isar.contentBlocks
          .filter()
          .bookIdEqualTo(state.bookId)
          .findAll();

      print('ReadingController: Found ${blocks.length} content blocks for book ${state.bookId}');

      if (blocks.isEmpty) {
        print('ReadingController: ERROR - No content blocks found for book ${state.bookId}');
        state = state.copyWith(
          paginator: AsyncValue.error(
            'This book has no content to display.',
            StackTrace.current,
          ),
        );
        return;
      }

      // Debug first few blocks
      print('ReadingController: First block - Chapter: ${blocks.first.chapterIndex}, Block: ${blocks.first.blockIndexInChapter}');
      print('ReadingController: First block text: ${blocks.first.textContent?.substring(0, blocks.first.textContent!.length > 100 ? 100 : blocks.first.textContent!.length)}...');

      if (blocks.length > 1) {
        print('ReadingController: Second block - Chapter: ${blocks[1].chapterIndex}, Block: ${blocks[1].blockIndexInChapter}');
        print('ReadingController: Second block text: ${blocks[1].textContent?.substring(0, blocks[1].textContent!.length > 100 ? 100 : blocks[1].textContent!.length)}...');
      }

      print('ReadingController: Creating BookPaginator with ${blocks.length} blocks...');
      final paginator = BookPaginator(
        allBlocks: blocks,
        textStyle: textStyle,
        viewSize: _viewSize,
        margins: margins,
        blocksPerPage: _blocksPerPage, // For debugging, can be adjusted later
      );

      print('ReadingController: BookPaginator created successfully');
      state = state.copyWith(paginator: AsyncValue.data(paginator));

      print('ReadingController: Getting first page...');
      getPage(0);
      print('ReadingController: Initialization completed successfully');

    } catch (error, stackTrace) {
      print('ReadingController: ERROR during initialization: $error');
      print('ReadingController: Stack trace: $stackTrace');
      state = state.copyWith(
        paginator: AsyncValue.error(error, stackTrace),
      );
    }
  }

  void getPage(int pageIndex) {
    print('ReadingController: Getting page $pageIndex');

    state.paginator.whenData((paginator) {
      if (state.pageCache.containsKey(pageIndex)) {
        print('ReadingController: Page $pageIndex already cached');
        return;
      }

      print('ReadingController: Generating page $pageIndex...');
      try {
        final page = paginator.getPage(pageIndex);
        print('ReadingController: Page $pageIndex generated with ${page.blocks.length} blocks');

        final newCache = Map<int, BookPage>.from(state.pageCache);
        newCache[pageIndex] = page;
        state = state.copyWith(pageCache: newCache);

        print('ReadingController: Page $pageIndex cached successfully');
      } catch (error) {
        print('ReadingController: ERROR generating page $pageIndex: $error');
      }
    });
  }

  void onPageChanged(int index) {
    print('ReadingController: Page changed to $index');
    state = state.copyWith(currentPage: index);
    state.paginator.whenData((p) {
      getPage(index);
      if (index + 1 < (p.allBlocks.length / _blocksPerPage)) getPage(index + 1);
    });
  }
}

final readingControllerProvider = StateNotifierProvider.family.autoDispose<ReadingController, ReadingState, (int, Size)>((ref, params) {
  final isar = ref.watch(isarDBProvider).value!;
  final (bookId, viewSize) = params;
  final blocksPerPage = ref.watch(readerSettingsProvider).blocksPerPage;
  return ReadingController(isar, bookId, viewSize, blocksPerPage);
});