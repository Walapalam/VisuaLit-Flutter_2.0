import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/data/toc_entry.dart';
import 'package:visualit/features/reader/data/highlight.dart';

@immutable
class ReadingState {
  final int bookId;
  final Book? book;
  final List<ContentBlock> allBlocks;
  final bool isBookLoaded;
  final int currentChapterIndex;
  final int currentPageInChapter;
  final Map<int, int> chapterPageCounts;
  final Map<int, Map<int, int>> chapterPageToBlockIndexMap;

  const ReadingState({
    required this.bookId,
    this.book,
    this.allBlocks = const [],
    this.isBookLoaded = false,
    this.currentChapterIndex = 0,
    this.currentPageInChapter = 0,
    this.chapterPageCounts = const {0: 1},
    this.chapterPageToBlockIndexMap = const {},
  });

  int get totalChapters {
    if (allBlocks.isEmpty) return 0;
    return (allBlocks.last.chapterIndex ?? 0) + 1;
  }

  int get pagesInCurrentChapter => chapterPageCounts[currentChapterIndex] ?? 1;

  List<ContentBlock> get blocksForCurrentChapter =>
      allBlocks.where((b) => b.chapterIndex == currentChapterIndex).toList();

  String get chapterProgress {
    final pagesLeft = pagesInCurrentChapter - currentPageInChapter - 1;
    if (pagesLeft < 0) return "Chapter loading...";
    if (pagesLeft == 0) return "Last page in chapter";
    return "$pagesLeft pages left in this chapter";
  }

  ReadingState copyWith({
    Book? book,
    List<ContentBlock>? allBlocks,
    bool? isBookLoaded,
    int? currentChapterIndex,
    int? currentPageInChapter,
    Map<int, int>? chapterPageCounts,
    Map<int, Map<int, int>>? chapterPageToBlockIndexMap,
  }) {
    return ReadingState(
      bookId: bookId,
      book: book ?? this.book,
      allBlocks: allBlocks ?? this.allBlocks,
      isBookLoaded: isBookLoaded ?? this.isBookLoaded,
      currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
      currentPageInChapter: currentPageInChapter ?? this.currentPageInChapter,
      chapterPageCounts: chapterPageCounts ?? this.chapterPageCounts,
      chapterPageToBlockIndexMap: chapterPageToBlockIndexMap ?? this.chapterPageToBlockIndexMap,
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
    print("-> [ReadingController] _initialize called.");
    final book = await _isar.books.get(state.bookId);
    if (book == null) {
      if (mounted) state = state.copyWith(isBookLoaded: true);
      return;
    }

    final blocks = await _isar.contentBlocks
        .filter()
        .bookIdEqualTo(state.bookId)
        .sortByChapterIndex()
        .thenByBlockIndexInChapter()
        .findAll();
    print("  - Fetched '${book.title}' with ${blocks.length} blocks.");
    print(
        "  - Loading last read position: Chapter ${book.lastReadChapterIndex}, Page ${book.lastReadPageInChapter}");

    if (mounted) {
      state = state.copyWith(
        book: book,
        allBlocks: blocks,
        isBookLoaded: true,
        currentChapterIndex: book.lastReadChapterIndex,
        currentPageInChapter: book.lastReadPageInChapter,
      );
      print(
          "  - State updated: isBookLoaded=true, start at Chapter ${state.currentChapterIndex}, Page ${state.currentPageInChapter}");
    }
  }

  void updateChapterPageLayout(int chapterIndex, int pageIndex, int startBlockIndex, int endBlockIndex) {
    final newChapterMap = Map<int, int>.from(state.chapterPageToBlockIndexMap[chapterIndex] ?? {});
    newChapterMap[pageIndex] = startBlockIndex;
    final newMap = Map<int, Map<int, int>>.from(state.chapterPageToBlockIndexMap);
    newMap[chapterIndex] = newChapterMap;

    final newPageCount = pageIndex + (endBlockIndex < state.blocksForCurrentChapter.length - 1 ? 1 : 0);
    final newPageCounts = Map<int, int>.from(state.chapterPageCounts);
    if (newPageCounts[chapterIndex] == null || newPageCounts[chapterIndex]! < newPageCount) {
      newPageCounts[chapterIndex] = newPageCount;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        state = state.copyWith(
          chapterPageToBlockIndexMap: newMap,
          chapterPageCounts: newPageCounts,
        );
      }
    });
  }

  void onPageChangedBySwipe(int newPage) {
    if (mounted && newPage != state.currentPageInChapter) {
      state = state.copyWith(currentPageInChapter: newPage);
      _debouncer.run(() => _saveProgress());
    }
  }

  void goToNextChapter() {
    if (state.currentChapterIndex < state.totalChapters - 1) {
      final nextChapter = state.currentChapterIndex + 1;
      state = state.copyWith(currentChapterIndex: nextChapter, currentPageInChapter: 0);
      _debouncer.run(() => _saveProgress());
    }
  }

  void goToPreviousChapter() {
    if (state.currentChapterIndex > 0) {
      final prevChapter = state.currentChapterIndex - 1;
      final lastPage = (state.chapterPageCounts[prevChapter] ?? 1) - 1;
      state = state.copyWith(currentChapterIndex: prevChapter, currentPageInChapter: lastPage);
      _debouncer.run(() => _saveProgress());
    }
  }

  Future<void> jumpToLocation(TOCEntry entry) async {
    if (entry.src == null) return;
    final targetBlock = state.allBlocks.firstWhere(
          (b) => b.src == entry.src,
      orElse: () => ContentBlock(),
    );

    if (targetBlock.chapterIndex != null) {
      final chapterIndex = targetBlock.chapterIndex!;
      final pageMap = state.chapterPageToBlockIndexMap[chapterIndex] ?? {0: 0};
      int targetPage = 0;
      final targetBlockIndex = state.allBlocks.indexOf(targetBlock);
      for (var entry in pageMap.entries) {
        final startBlockIndex = entry.value;
        final endBlockIndex = pageMap[entry.key + 1] != null
            ? pageMap[entry.key + 1]! - 1
            : state.blocksForCurrentChapter.length - 1;
        if (targetBlockIndex >= startBlockIndex && targetBlockIndex <= endBlockIndex) {
          targetPage = entry.key;
          break;
        }
      }
      state = state.copyWith(
        currentChapterIndex: chapterIndex,
        currentPageInChapter: targetPage,
      );
      _debouncer.run(() => _saveProgress());
    }
  }

  Future<void> jumpToHref(String href, String currentBlockSrc) async {
    final resolvedPath = p.normalize(p.join(p.dirname(currentBlockSrc), href));
    final parts = resolvedPath.split('#');
    final src = parts.isNotEmpty ? parts[0] : null;
    if (src != null) {
      await jumpToLocation(TOCEntry()..src = src..title = 'Internal Link');
    }
  }

  Future<void> _saveProgress() async {
    final chapterIndex = state.currentChapterIndex;
    final pageInChapter = state.currentPageInChapter;
    print("-> [Debounced Save] Saving progress: Chapter $chapterIndex, Page $pageInChapter");
    await _isar.writeTxn(() async {
      final book = await _isar.books.get(state.bookId);
      if (book != null) {
        book.lastReadChapterIndex = chapterIndex;
        book.lastReadPageInChapter = pageInChapter;
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