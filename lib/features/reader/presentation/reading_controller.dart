import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/data/toc_entry.dart';
import 'package:path/path.dart' as p;

@immutable
class ReadingState {
  final int bookId;
  final Book? book;
  final bool isBookLoaded;
  final bool isLoadingChapter; // New: To show loading indicator during chapter transitions

  // CHNAGED: No longer holds all blocks. Only the current chapter's blocks.
  final List<ContentBlock> currentChapterBlocks;
  final int currentChapterIndex;
  final int currentPageInChapter;

  // New: Pagination map for the *current* chapter only.
  final Map<int, int> pageToBlockIndexMap;
  final int pagesInCurrentChapter;

  const ReadingState({
    required this.bookId,
    this.book,
    this.isBookLoaded = false,
    this.isLoadingChapter = true,
    this.currentChapterBlocks = const [],
    this.currentChapterIndex = 0,
    this.currentPageInChapter = 0,
    this.pageToBlockIndexMap = const {0: 0},
    this.pagesInCurrentChapter = 1,
  });

  String get chapterProgress {
    if (isLoadingChapter) return "Loading chapter...";
    final pagesLeft = pagesInCurrentChapter - currentPageInChapter - 1;
    if (pagesLeft <= 0) return "Last page in chapter";
    return "$pagesLeft pages left in this chapter";
  }

  ReadingState copyWith({
    Book? book,
    bool? isBookLoaded,
    bool? isLoadingChapter,
    List<ContentBlock>? currentChapterBlocks,
    int? currentChapterIndex,
    int? currentPageInChapter,
    Map<int, int>? pageToBlockIndexMap,
    int? pagesInCurrentChapter,
  }) {
    return ReadingState(
      bookId: bookId,
      book: book ?? this.book,
      isBookLoaded: isBookLoaded ?? this.isBookLoaded,
      isLoadingChapter: isLoadingChapter ?? this.isLoadingChapter,
      currentChapterBlocks: currentChapterBlocks ?? this.currentChapterBlocks,
      currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
      currentPageInChapter: currentPageInChapter ?? this.currentPageInChapter,
      pageToBlockIndexMap: pageToBlockIndexMap ?? this.pageToBlockIndexMap,
      pagesInCurrentChapter: pagesInCurrentChapter ?? this.pagesInCurrentChapter,
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
    if (book == null) {
      if (mounted) state = state.copyWith(isBookLoaded: true, isLoadingChapter: false);
      return;
    }

    if (mounted) state = state.copyWith(book: book, isBookLoaded: true);
    // Load only the initial chapter instead of the whole book
    await loadChapter(book.lastReadChapterIndex, initialPage: book.lastReadPageInChapter);
  }

  // NEW: The core on-demand loading method
  Future<void> loadChapter(int chapterIndex, {int initialPage = 0}) async {
    if (!mounted) return;
    state = state.copyWith(isLoadingChapter: true);

    print("DEBUG: Loading chapter $chapterIndex with initialPage $initialPage");

    final chapterBlocks = await _isar.contentBlocks
        .filter()
        .bookIdEqualTo(state.bookId)
        .and()
        .chapterIndexEqualTo(chapterIndex)
        .sortByBlockIndexInChapter()
        .findAll();

    print("DEBUG: Loaded ${chapterBlocks.length} blocks for chapter $chapterIndex.");
    for (var i = 0; i < chapterBlocks.length; i++) {
      print("DEBUG: Block $i -> ${chapterBlocks[i]}");
    }

    if (mounted) {
      state = state.copyWith(
        currentChapterIndex: chapterIndex,
        currentChapterBlocks: chapterBlocks,
        currentPageInChapter: initialPage,
        pageToBlockIndexMap: {0: 0}, // Reset pagination map for the new chapter
        pagesInCurrentChapter: 1, // Reset page count
        isLoadingChapter: false,
      );
    }
  }

  // In class ReadingController...

  void updatePageLayout(int pageIndex, int startBlockIndex, int endBlockIndex) {
    if (!mounted) return;

    final newMap = Map<int, int>.from(state.pageToBlockIndexMap);
    // This part is correct: record the start of the page we just laid out.
    newMap[pageIndex] = startBlockIndex;

    final isLastBlock = endBlockIndex >= state.currentChapterBlocks.length - 1;

    // --- THIS IS THE FIX ---
    // If this isn't the last block, we now know where the *next* page must start.
    // We must record this in our map.
    if (!isLastBlock) {
      newMap[pageIndex + 1] = endBlockIndex + 1;
    }
    // --- END OF FIX ---

    final knownPages = pageIndex + 1;
    if (state.pagesInCurrentChapter <= knownPages && !isLastBlock) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          state = state.copyWith(
            pageToBlockIndexMap: newMap,
            pagesInCurrentChapter: knownPages + 1,
          );
        }
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          state = state.copyWith(pageToBlockIndexMap: newMap);
        }
      });
    }
  }


  void onPageChangedBySwipe(int newPage) {
    if (mounted && newPage != state.currentPageInChapter) {
      state = state.copyWith(currentPageInChapter: newPage);
      _debouncer.run(() => _saveProgress());
    }
  }

  Future<void> goToNextChapter() async {
    print('goToNextChapter called: current=${state.currentChapterIndex}, total=${state.book?.chapterCount}');
    if (state.book == null) return;
    // NOTE: A better implementation would be to store chapter count in the Book object
    // during import to avoid having to guess the last chapter.
    final totalChapters = state.book?.chapterCount;
    if (state.currentChapterIndex > totalChapters! - 1) {
      await loadChapter(state.currentChapterIndex + 1);
    }
  }

  Future<void> goToPreviousChapter() async {
    if (state.currentChapterIndex > 0) {
      await loadChapter(state.currentChapterIndex - 1);
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

  Future<void> jumpToLocation(TOCEntry entry) async {
    if (entry.src == null) return;

    final targetBlock = await _isar.contentBlocks
        .filter()
        .bookIdEqualTo(state.bookId)
        .and()
        .srcEqualTo(entry.src!)
        .findFirst();

    if (targetBlock?.chapterIndex != null) {
      await loadChapter(targetBlock!.chapterIndex!);
    }
  }

  // FIXED: Re-implemented jumpToHref for internal links
  Future<void> jumpToHref(String href, String currentBlockSrc) async {
    final resolvedPath = p.normalize(p.join(p.dirname(currentBlockSrc), href));
    final src = resolvedPath.split('#').first;
    await jumpToLocation(TOCEntry(src: src));
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