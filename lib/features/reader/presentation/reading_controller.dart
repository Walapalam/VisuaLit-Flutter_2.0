import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/data/highlight.dart';
import 'package:visualit/features/reader/data/toc_entry.dart';
import 'package:visualit/features/reader/providers/layout_cache_provider.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';

import '../data/bookmark.dart';
import '../services/layout_cache_service.dart';

@immutable
class ReadingState {
  final int bookId;
  final Book? book; // The full book object for metadata
  final List<ContentBlock> blocks;
  final int currentPage;
  final bool isBookLoaded;
  final Map<int, int> pageToBlockIndexMap;
  final int totalPages;

  // New fields for layout caching and JIT loading
  final bool isFormatting; // Whether the book is currently being formatted
  final String? layoutKey; // The unique key for the current layout
  final Set<int> loadedChapters; // Set of chapter indices that have been loaded
  final bool isLayoutCached; // Whether the layout was loaded from cache

  const ReadingState({
    required this.bookId,
    this.book,
    this.blocks = const [],
    this.currentPage = 0,
    this.isBookLoaded = false,
    this.pageToBlockIndexMap = const {0: 0},
    this.totalPages = 1,
    this.isFormatting = false,
    this.layoutKey,
    this.loadedChapters = const {},
    this.isLayoutCached = false,
  });

  // --- HELPER GETTER for chapter progress ---
  String get chapterProgress {
    if (blocks.isEmpty || pageToBlockIndexMap[currentPage] == null) {
      return "Loading chapter...";
    }
    final currentBlockIndex = pageToBlockIndexMap[currentPage]!;
    final currentChapterIndex = blocks[currentBlockIndex].chapterIndex;

    int chapterStartBlock = blocks.indexWhere((b) => b.chapterIndex == currentChapterIndex);
    int chapterEndBlock = blocks.lastIndexWhere((b) => b.chapterIndex == currentChapterIndex);

    int? chapterStartPage;
    for (final entry in pageToBlockIndexMap.entries) {
      if(entry.value >= chapterStartBlock) {
        chapterStartPage = entry.key;
        break;
      }
    }
    chapterStartPage ??= 0;

    int? chapterEndPage;
    for (final entry in pageToBlockIndexMap.entries) {
      if(entry.value > chapterEndBlock) {
        chapterEndPage = entry.key -1;
        break;
      }
    }
    chapterEndPage ??= totalPages -1;

    final pagesInChapter = (chapterEndPage - chapterStartPage) + 1;
    final pagesLeft = chapterEndPage - currentPage;

    if (pagesLeft <= 0) return "Last page in chapter";
    return "$pagesLeft pages left in chapter";
  }

  ReadingState copyWith({
    Book? book,
    List<ContentBlock>? blocks,
    int? currentPage,
    bool? isBookLoaded,
    Map<int, int>? pageToBlockIndexMap,
    int? totalPages,
    bool? isFormatting,
    String? layoutKey,
    Set<int>? loadedChapters,
    bool? isLayoutCached,
  }) {
    return ReadingState(
      bookId: bookId,
      book: book ?? this.book,
      blocks: blocks ?? this.blocks,
      currentPage: currentPage ?? this.currentPage,
      isBookLoaded: isBookLoaded ?? this.isBookLoaded,
      pageToBlockIndexMap: pageToBlockIndexMap ?? this.pageToBlockIndexMap,
      totalPages: totalPages ?? this.totalPages,
      isFormatting: isFormatting ?? this.isFormatting,
      layoutKey: layoutKey ?? this.layoutKey,
      loadedChapters: loadedChapters ?? this.loadedChapters,
      isLayoutCached: isLayoutCached ?? this.isLayoutCached,
    );
  }
}

class ReadingController extends StateNotifier<ReadingState> {
  final Isar _isar;
  final _Debouncer _debouncer = _Debouncer(milliseconds: 1000);
  final Completer<void> _layoutCompleter = Completer<void>();
  final LayoutCacheService _layoutCacheService;
  final ReadingPreferences _prefs;
  final Size _deviceSize;

  ReadingController(
    this._isar, 
    int bookId, 
    this._layoutCacheService, 
    this._prefs,
    this._deviceSize
  ) : super(ReadingState(bookId: bookId)) {
    _initialize();
  }

  Future<void> _initialize() async {
    // One-time cache clearing to handle the change from lineHeight to lineSpacing in layout keys
    await _layoutCacheService.clearAllLayouts();

    // Fetch the book metadata
    final book = await _isar.books.get(state.bookId);
    if (book == null || !mounted) return;

    // Generate a unique layout key based on book ID, device dimensions, and font settings
    final layoutKey = _layoutCacheService.generateLayoutKey(state.bookId, _deviceSize, _prefs);

    // Check if we have a cached layout
    final hasCachedLayout = await _layoutCacheService.hasLayout(layoutKey);

    if (hasCachedLayout) {
      // Cache hit: Load the cached layout
      await _loadCachedLayout(layoutKey, book);
    } else {
      // Cache miss: Start JIT loading and formatting
      await _startJitLoading(book, layoutKey);
    }
  }

  Future<void> _loadCachedLayout(String layoutKey, Book book) async {
    if (!mounted) return;

    // Set state to indicate we're loading from cache
    state = state.copyWith(
      book: book,
      layoutKey: layoutKey,
      isLayoutCached: true,
      isBookLoaded: true,
      currentPage: book.lastReadPage,
    );

    // Load the cached layout
    final cachedLayout = await _layoutCacheService.getLayout(layoutKey);
    if (cachedLayout == null || !mounted) return;

    // Determine which chapter we need to load based on the current page
    final currentPageBlockIndex = cachedLayout[book.lastReadPage] ?? 0;

    // Load the blocks for the current chapter
    final currentChapterIndex = await _findChapterForBlockIndex(currentPageBlockIndex);
    if (currentChapterIndex == null || !mounted) return;

    final chapterBlocks = await _loadChapterBlocks(currentChapterIndex);

    // Update state with the loaded blocks and cached layout
    state = state.copyWith(
      blocks: chapterBlocks,
      pageToBlockIndexMap: cachedLayout,
      loadedChapters: {currentChapterIndex},
      totalPages: cachedLayout.keys.isNotEmpty ? cachedLayout.keys.reduce((a, b) => a > b ? a : b) + 1 : 1,
    );

    // Pre-fetch the next chapter if we're near the end of the current chapter
    _checkAndPreFetchNextChapter();
  }

  Future<void> _startJitLoading(Book book, String layoutKey) async {
    if (!mounted) return;

    // Set state to indicate we're starting JIT loading and formatting
    state = state.copyWith(
      book: book,
      layoutKey: layoutKey,
      isFormatting: true,
      isBookLoaded: true,
      currentPage: 0, // Start at page 0 when formatting
    );

    // Load the blocks for the first chapter
    final firstChapterIndex = book.toc.isNotEmpty ? 0 : null;
    final chapterBlocks = await _loadChapterBlocks(firstChapterIndex);

    // Update state with the loaded blocks
    state = state.copyWith(
      blocks: chapterBlocks,
      loadedChapters: firstChapterIndex != null ? {firstChapterIndex} : {},
      isFormatting: false, // Formatting will happen in BookPageWidget
    );
  }

  Future<List<ContentBlock>> _loadChapterBlocks(int? chapterIndex) async {
    if (chapterIndex == null) {
      // If no chapter index is provided, load all blocks (for books without TOC)
      return await _isar.contentBlocks.filter().bookIdEqualTo(state.bookId).findAll();
    } else {
      // Load blocks for the specified chapter
      return await _isar.contentBlocks
          .filter()
          .bookIdEqualTo(state.bookId)
          .chapterIndexEqualTo(chapterIndex)
          .findAll();
    }
  }

  Future<int?> _findChapterForBlockIndex(int blockIndex) async {
    // Find the chapter that contains the block at the given index
    final block = await _isar.contentBlocks
        .filter()
        .bookIdEqualTo(state.bookId)
        .idEqualTo(blockIndex)
        .findFirst();

    return block?.chapterIndex;
  }

  void updatePageLayout(int pageIndex, int startingBlock, int endingBlock) {
    if (!mounted) return;
    final nextPageIndex = pageIndex + 1;
    final nextBlockIndex = endingBlock + 1;
    if (state.pageToBlockIndexMap[nextPageIndex] != nextBlockIndex) {
      final newMap = Map<int, int>.from(state.pageToBlockIndexMap);
      newMap[nextPageIndex] = nextBlockIndex;
      int newTotalPages = state.totalPages;

      if (nextBlockIndex >= state.blocks.length) {
        newTotalPages = nextPageIndex;
        if (!_layoutCompleter.isCompleted) _layoutCompleter.complete();
      } else {
        newTotalPages = state.totalPages > nextPageIndex ? state.totalPages : nextPageIndex + 1;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          state = state.copyWith(
            pageToBlockIndexMap: newMap, 
            totalPages: newTotalPages,
            isFormatting: false, // Formatting is complete for this page
          );

          // Save the layout to cache if we're not using a cached layout
          if (!state.isLayoutCached && state.layoutKey != null) {
            _saveLayoutToCache();
          }

          // Check if we need to pre-fetch the next chapter
          _checkAndPreFetchNextChapter();
        }
      });
    }
  }

  Future<void> _saveLayoutToCache() async {
    if (state.layoutKey == null) return;

    await _layoutCacheService.saveLayout(
      state.layoutKey!, 
      state.bookId, 
      state.pageToBlockIndexMap
    );
  }

  Future<void> _checkAndPreFetchNextChapter() async {
    if (!mounted || state.blocks.isEmpty) return;

    // Get the current chapter index
    final currentBlockIndex = state.pageToBlockIndexMap[state.currentPage] ?? 0;
    if (currentBlockIndex >= state.blocks.length) return;

    final currentBlock = state.blocks[currentBlockIndex];
    final currentChapterIndex = currentBlock.chapterIndex;
    if (currentChapterIndex == null) return;

    // Calculate progress in the current chapter
    final chapterBlocks = state.blocks.where((b) => b.chapterIndex == currentChapterIndex).toList();
    if (chapterBlocks.isEmpty) return;

    final currentBlockInChapter = chapterBlocks.indexWhere((b) => b.id == currentBlock.id);
    final progressInChapter = currentBlockInChapter / chapterBlocks.length;

    // If we're at 80% of the current chapter, pre-fetch the next chapter
    if (progressInChapter >= 0.8) {
      final nextChapterIndex = currentChapterIndex + 1;

      // Check if we've already loaded this chapter
      if (state.loadedChapters.contains(nextChapterIndex)) return;

      // Check if the next chapter exists by finding a block with the next chapter index
      final hasNextChapter = state.blocks.any((block) => block.chapterIndex == nextChapterIndex) ||
          (state.book?.toc.any((entry) {
            final block = state.blocks.firstWhere(
              (b) => b.src == entry.src,
              orElse: () => ContentBlock(),
            );
            return block.chapterIndex == nextChapterIndex;
          }) ?? false);
      if (!hasNextChapter) return;

      // Load the next chapter's blocks
      final nextChapterBlocks = await _loadChapterBlocks(nextChapterIndex);
      if (nextChapterBlocks.isEmpty || !mounted) return;

      // Append the next chapter's blocks to the current blocks
      final updatedBlocks = List<ContentBlock>.from(state.blocks)..addAll(nextChapterBlocks);
      final updatedLoadedChapters = Set<int>.from(state.loadedChapters)..add(nextChapterIndex);

      state = state.copyWith(
        blocks: updatedBlocks,
        loadedChapters: updatedLoadedChapters,
      );
    }
  }

  void onPageChanged(int page) {
    if (page != state.currentPage) {
      if (mounted) {
        state = state.copyWith(currentPage: page);
        _debouncer.run(() => _saveProgress(page));

        // Check if we need to pre-fetch the next chapter
        _checkAndPreFetchNextChapter();
      }
    }
  }

  Future<void> _saveProgress(int page) async {
    await _isar.writeTxn(() async {
      final book = await _isar.books.get(state.bookId);
      if (book != null) {
        book.lastReadPage = page;
        book.lastReadTimestamp = DateTime.now();
        book.updatedAt = DateTime.now(); // Update the updatedAt field for synchronization
        await _isar.books.put(book);
      }
    });
  }

  Future<int?> _findPageForBlock(int targetBlockIndex) async {
    if (!mounted) return null;
    for (final entry in state.pageToBlockIndexMap.entries) {
      final start = entry.value;
      final end = (state.pageToBlockIndexMap[entry.key + 1] ?? state.blocks.length) - 1;
      if (targetBlockIndex >= start && targetBlockIndex <= end) {
        return entry.key;
      }
    }
    int lastKnownPage = state.pageToBlockIndexMap.keys.last;
    state = state.copyWith(currentPage: lastKnownPage);
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 50));
      final lastBlockOnLastPage = (state.pageToBlockIndexMap[lastKnownPage + 1] ?? 0) - 1;
      if (targetBlockIndex <= lastBlockOnLastPage) {
        return lastKnownPage;
      }
      if (lastBlockOnLastPage >= state.blocks.length - 1) {
        return lastKnownPage;
      }
      lastKnownPage++;
      state = state.copyWith(currentPage: lastKnownPage);
    }
    return null;
  }

  Future<void> jumpToLocation(TOCEntry entry) async {
    if (entry.src == null) return;

    // Find the block matching the TOC entry's src
    final targetBlockIndex = state.blocks.indexWhere((b) => b.src == entry.src);
    if (targetBlockIndex != -1) {
      // Get the chapter index from the block
      final targetChapterIndex = state.blocks[targetBlockIndex].chapterIndex;
      if (targetChapterIndex != null) {
        // Ensure the chapter is loaded
        if (!state.loadedChapters.contains(targetChapterIndex)) {
          final chapterBlocks = await _loadChapterBlocks(targetChapterIndex);
          if (chapterBlocks.isEmpty || !mounted) return;
          state = state.copyWith(
            blocks: List<ContentBlock>.from(state.blocks)..addAll(chapterBlocks),
            loadedChapters: Set<int>.from(state.loadedChapters)..add(targetChapterIndex),
          );
        }
        // Find the page for the target block
        final targetPage = await _findPageForBlock(targetBlockIndex);
        if (targetPage != null && mounted) {
          state = state.copyWith(currentPage: targetPage);
        }
      }
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

  Future<void> addHighlight(TextSelection selection, int blockIndex, Color color) async {
    if (!selection.isValid || blockIndex < 0 || blockIndex >= state.blocks.length) {
      return;
    }
    final block = state.blocks[blockIndex];
    final selectedText = selection.textInside(block.textContent ?? '');
    if (selectedText.isEmpty) {
      return;
    }
    final newHighlight = Highlight()
      ..bookId = state.bookId
      ..chapterIndex = block.chapterIndex
      ..blockIndexInChapter = block.blockIndexInChapter
      ..text = selectedText
      ..startOffset = selection.start
      ..endOffset = selection.end
      ..color = color.value
      ..timestamp = DateTime.now()
      ..updatedAt = DateTime.now(); // Set updatedAt for synchronization
    await _isar.writeTxn(() async {
      await _isar.highlights.put(newHighlight);
    });
  }

  /// Add a bookmark at the current page
  Future<void> addBookmark({String? title, String? note}) async {
    if (!mounted) return;

    final currentPage = state.currentPage;
    final currentBlockIndex = state.pageToBlockIndexMap[currentPage] ?? 0;

    if (currentBlockIndex >= state.blocks.length) return;

    final currentBlock = state.blocks[currentBlockIndex];

    final newBookmark = Bookmark()
      ..bookId = state.bookId
      ..chapterIndex = currentBlock.chapterIndex
      ..blockIndexInChapter = currentBlock.blockIndexInChapter
      ..pageNumber = currentPage
      ..title = title
      ..note = note
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now(); // Set updatedAt for synchronization

    await _isar.writeTxn(() async {
      await _isar.bookmarks.put(newBookmark);
    });
  }

  /// Get all bookmarks for the current book
  Future<List<Bookmark>> getBookmarks() async {
    return await _isar.bookmarks.filter().bookIdEqualTo(state.bookId).findAll();
  }

  /// Delete a bookmark
  Future<void> deleteBookmark(int bookmarkId) async {
    await _isar.writeTxn(() async {
      await _isar.bookmarks.delete(bookmarkId);
    });
  }

  /// Jump to a bookmarked page
  Future<void> jumpToBookmark(Bookmark bookmark) async {
    if (bookmark.pageNumber != null) {
      if (mounted) {
        state = state.copyWith(currentPage: bookmark.pageNumber!);
      }
    } else if (bookmark.chapterIndex != null && bookmark.blockIndexInChapter != null) {
      // Find the block matching the bookmark's chapter and block index
      final targetBlockIndex = state.blocks.indexWhere(
        (b) => b.chapterIndex == bookmark.chapterIndex && b.blockIndexInChapter == bookmark.blockIndexInChapter
      );

      if (targetBlockIndex != -1) {
        // Find the page for the target block
        final targetPage = await _findPageForBlock(targetBlockIndex);
        if (targetPage != null && mounted) {
          state = state.copyWith(currentPage: targetPage);
        }
      }
    }
  }
}

class _Debouncer {
  final int milliseconds;
  Timer? _timer;
  _Debouncer({required this.milliseconds});
  run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

final readingControllerProvider =
StateNotifierProvider.family.autoDispose<ReadingController, ReadingState, int>((ref, bookId) {
  final isar = ref.watch(isarDBProvider).value!;
  final layoutCacheService = ref.watch(layoutCacheServiceProvider);
  final prefs = ref.watch(readingPreferencesProvider);

  // Get the device size from MediaQuery
  final mediaQuery = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize;
  final deviceSize = Size(mediaQuery.width, mediaQuery.height);

  return ReadingController(isar, bookId, layoutCacheService, prefs, deviceSize);
});
