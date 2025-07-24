import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/data/highlight.dart';
import 'package:visualit/features/reader/data/toc_entry.dart';

// The State class for TRUE PAGINATION.
// It tracks the current page of the whole book, not within a chapter.
@immutable
class ReadingState {
  final int bookId;
  final Book? book;
  final List<ContentBlock> allBlocks;
  final bool isBookLoaded;

  // --- PAGINATION STATE ---
  final int currentPage;
  final int totalPages;
  // This map is the "brain" of the pagination. It stores the starting block for each known page.
  final Map<int, int> pageToBlockIndexMap; // <pageIndex, startingBlockIndex>

  const ReadingState({
    required this.bookId,
    this.book,
    this.allBlocks = const [],
    this.isBookLoaded = false,
    this.currentPage = 0,
    this.totalPages = 1,
    this.pageToBlockIndexMap = const {0: 0}, // Page 0 always starts at block 0
  });

  String get chapterProgress {
    if (allBlocks.isEmpty || pageToBlockIndexMap[currentPage] == null) return "Loading...";

    // Determine the current chapter based on the current page's starting block
    final currentBlock = allBlocks[pageToBlockIndexMap[currentPage]!];
    final currentChapterTitle = book?.toc.firstWhere(
            (entry) => entry.src == currentBlock.src, // This is a simplified lookup
        orElse: () => TOCEntry()..title = "Unknown Chapter"
    ).title;

    return "${currentChapterTitle ?? "Chapter"} - Page ${currentPage + 1}";
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

// The Controller for TRUE PAGINATION.
class ReadingController extends StateNotifier<ReadingState> {
  final Isar _isar;
  final _Debouncer _debouncer = _Debouncer(milliseconds: 1500);

  ReadingController(this._isar, int bookId) : super(ReadingState(bookId: bookId)) {
    _initialize();
  }

  Future<void> _initialize() async {
    final book = await _isar.books.get(state.bookId);
    if (book == null) {
      if (mounted) state = state.copyWith(isBookLoaded: true); // Let UI show error
      return;
    }

    final blocks = await _isar.contentBlocks.filter().bookIdEqualTo(state.bookId).sortByChapterIndex().thenByBlockIndexInChapter().findAll();

    if (mounted) {
      state = state.copyWith(
        book: book,
        allBlocks: blocks,
        isBookLoaded: true,
        // The old `lastReadPageInChapter` is now used as the book-wide `currentPage`
        currentPage: book.lastReadPageInChapter,
      );
    }
  }

  // Called by the PageView when the user swipes to a new page.
  void onPageChanged(int page) {
    if (mounted && page != state.currentPage) {
      state = state.copyWith(currentPage: page);
      _debouncer.run(() => _saveProgress(page));
    }
  }

  // Called by BookPageWidget after it has measured itself and knows where it ends.
  void updatePageLayout(int pageIndex, int startingBlock, int endingBlock) {
    if (!mounted) return;

    final nextPageIndex = pageIndex + 1;
    final nextBlockIndex = endingBlock + 1;

    // Check if we've rendered all the blocks.
    if (nextBlockIndex >= state.allBlocks.length) {
      // We have reached the end of the book.
      final newTotalPages = nextPageIndex;
      if (state.totalPages != newTotalPages) {
        // Use a post-frame callback to avoid errors during a build phase.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if(mounted) state = state.copyWith(totalPages: newTotalPages);
        });
      }
      return;
    }

    // If we haven't discovered the start of the next page yet, add it to our map.
    // This dynamically builds the page map as the user reads.
    if (state.pageToBlockIndexMap[nextPageIndex] == null) {
      final newMap = Map<int, int>.from(state.pageToBlockIndexMap);
      newMap[nextPageIndex] = nextBlockIndex;

      // Assume there's at least one more page until the condition above proves otherwise.
      final newTotalPages = state.totalPages > nextPageIndex ? state.totalPages : nextPageIndex + 1;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          state = state.copyWith(
            pageToBlockIndexMap: newMap,
            totalPages: newTotalPages,
          );
        }
      });
    }
  }

  // This is complex logic for jumping to a TOC item. It requires us to
  // "force" the app to lay out pages until we find the one containing our target block.
  Future<void> jumpToLocation(TOCEntry entry) async {
    if (entry.src == null) return;

    // Find the index of the first block of the chapter we want to jump to.
    final targetBlockIndex = state.allBlocks.indexWhere((b) => b.src == entry.src);
    if (targetBlockIndex == -1) return;

    // Check if we have already calculated the page for this block.
    for (final pageEntry in state.pageToBlockIndexMap.entries) {
      final page = pageEntry.key;
      final startBlock = pageEntry.value;
      final endBlock = (state.pageToBlockIndexMap[page + 1] ?? state.allBlocks.length) -1;

      if (targetBlockIndex >= startBlock && targetBlockIndex <= endBlock) {
        print("-> [TOC Jump] Found target in already-laid-out page. Jumping to page $page.");
        state = state.copyWith(currentPage: page);
        return;
      }
    }

    // If not found, we need to manually drive the pagination forward.
    // This is an advanced technique that tells the UI to quickly build and measure
    // pages until the target is found.
    print("-> [TOC Jump] Target not found. Forcing layout calculation...");
    int lastKnownPage = state.pageToBlockIndexMap.keys.last;
    state = state.copyWith(currentPage: lastKnownPage);

    while (mounted) {
      // Give the UI a moment to build the current page.
      await Future.delayed(const Duration(milliseconds: 20));

      final lastBlockOnPage = (state.pageToBlockIndexMap[lastKnownPage + 1] ?? 0) -1;

      if (targetBlockIndex <= lastBlockOnPage) {
        print("  - Found target on page $lastKnownPage after forcing layout.");
        state = state.copyWith(currentPage: lastKnownPage);
        return;
      }

      // If we've reached the end of the known pages and haven't found it, move to the next.
      if (lastKnownPage >= state.totalPages - 1) break; // Avoid infinite loop

      lastKnownPage++;
      state = state.copyWith(currentPage: lastKnownPage);
    }

    print("  - Could not find page for TOC jump after forcing layout.");
  }

  // Saves the book-wide current page number.
  Future<void> _saveProgress(int page) async {
    await _isar.writeTxn(() async {
      final book = await _isar.books.get(state.bookId);
      if (book != null) {
        // We use lastReadPageInChapter to store the book-wide page for simplicity,
        // as lastReadChapterIndex is not used in this model.
        book.lastReadPageInChapter = page;
        book.lastReadTimestamp = DateTime.now();
        await _isar.books.put(book);
      }
    });
  }
}

// The Debouncer and Provider definitions remain the same.
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
  // IMPORTANT: The .value! here is what can cause crashes if Isar isn't ready.
  // The ReadingScreen's build logic MUST ensure Isar is loaded before using this provider.
  final isar = ref.watch(isarDBProvider).value!;
  return ReadingController(isar, bookId);
});