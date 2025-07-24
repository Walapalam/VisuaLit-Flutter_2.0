import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/data/toc_entry.dart';

@immutable
class ReadingState {
  final int bookId;
  final Book? book;
  final List<ContentBlock> allBlocks;
  final bool isBookLoaded;

  final int currentPage;
  final int totalPages;
  final Map<int, int> pageToBlockIndexMap;

  const ReadingState({
    required this.bookId,
    this.book,
    this.allBlocks = const [],
    this.isBookLoaded = false,
    this.currentPage = 0,
    this.totalPages = 1,
    this.pageToBlockIndexMap = const {0: 0},
  });

  String get chapterProgress {
    if (totalPages == 1 && isBookLoaded) return "Page ${currentPage + 1}";
    return "Page ${currentPage + 1} of $totalPages";
  }

  ReadingState copyWith({
    Book? book,
    List<ContentBlock>? allBlocks,
    bool? isBookLoaded,
    int? currentPage,
    int? totalPages,
    Map<int, int>? pageToBlockIndexMap,
  }) {
    return ReadingState(
      bookId: bookId,
      book: book ?? this.book,
      allBlocks: allBlocks ?? this.allBlocks,
      isBookLoaded: isBookLoaded ?? this.isBookLoaded,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      pageToBlockIndexMap: pageToBlockIndexMap ?? this.pageToBlockIndexMap,
    );
  }
}

class ReadingController extends StateNotifier<ReadingState> {
  final Isar _isar;
  final _Debouncer _debouncer = _Debouncer(milliseconds: 1500);

  ReadingController(this._isar, int bookId) : super(ReadingState(bookId: bookId)) {
    _initialize();
  }

  Future<void> _initialize() async {
    final book = await _isar.books.get(state.bookId);
    if (book == null) return;

    final blocks = await _isar.contentBlocks.filter().bookIdEqualTo(state.bookId).sortByChapterIndex().thenByBlockIndexInChapter().findAll();

    if (mounted) {
      state = state.copyWith(
        book: book,
        allBlocks: blocks,
        isBookLoaded: true,
        currentPage: book.lastReadPageInChapter,
      );
    }
  }

  void onPageChanged(int page) {
    if (mounted && page != state.currentPage) {
      state = state.copyWith(currentPage: page);
      _debouncer.run(() => _saveProgress(page));
    }
  }

  void updatePageLayout(int pageIndex, int startingBlock, int endingBlock) {
    if (!mounted) return;

    final nextPageIndex = pageIndex + 1;
    final nextBlockIndex = endingBlock + 1;

    if (nextBlockIndex >= state.allBlocks.length) {
      final newTotalPages = nextPageIndex;
      if (state.totalPages != newTotalPages) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if(mounted) state = state.copyWith(totalPages: newTotalPages);
        });
      }
      return;
    }

    if (state.pageToBlockIndexMap[nextPageIndex] == null) {
      final newMap = Map<int, int>.from(state.pageToBlockIndexMap);
      newMap[nextPageIndex] = nextBlockIndex;
      final newTotalPages = state.totalPages > nextPageIndex ? state.totalPages : nextPageIndex + 1;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          state = state.copyWith(pageToBlockIndexMap: newMap, totalPages: newTotalPages);
        }
      });
    }
  }

  Future<void> jumpToLocation(TOCEntry entry) async {
    if (entry.src == null) return;
    final targetBlockIndex = state.allBlocks.indexWhere((b) => b.src == entry.src);
    if (targetBlockIndex == -1) return;

    for (final pageEntry in state.pageToBlockIndexMap.entries) {
      final page = pageEntry.key;
      final startBlock = pageEntry.value;
      if (targetBlockIndex >= startBlock && targetBlockIndex < (state.pageToBlockIndexMap[page + 1] ?? state.allBlocks.length)) {
        state = state.copyWith(currentPage: page);
        return;
      }
    }

    int lastKnownPage = state.pageToBlockIndexMap.keys.last;
    state = state.copyWith(currentPage: lastKnownPage);

    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 20));
      if (!mounted) return;
      final lastBlockOnPage = (state.pageToBlockIndexMap[lastKnownPage + 1] ?? state.allBlocks.length) -1;
      if (targetBlockIndex <= lastBlockOnPage) {
        state = state.copyWith(currentPage: lastKnownPage);
        return;
      }
      if (lastKnownPage >= state.totalPages - 1) break;
      lastKnownPage++;
      state = state.copyWith(currentPage: lastKnownPage);
    }
  }

  Future<void> _saveProgress(int page) async {
    await _isar.writeTxn(() async {
      final book = await _isar.books.get(state.bookId);
      if (book != null) {
        book.lastReadPageInChapter = page;
        book.lastReadTimestamp = DateTime.now();
        await _isar.books.put(book);
      }
    });
  }
}

class _Debouncer {
  final int milliseconds;
  Timer? _timer;
  _Debouncer({required this.milliseconds});
  run(VoidCallback action) {
    if (_timer?.isActive ?? false) _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

final readingControllerProvider =
StateNotifierProvider.family.autoDispose<ReadingController, ReadingState, int>((ref, bookId) {
  final isar = ref.watch(isarDBProvider).value!;
  return ReadingController(isar, bookId);
});