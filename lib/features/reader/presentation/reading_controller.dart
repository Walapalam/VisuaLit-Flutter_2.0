import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/data/highlight.dart';
import 'package:visualit/features/reader/data/layout_cache_service.dart';
import 'package:visualit/features/reader/data/toc_entry.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';

enum ReadingViewStatus {
  formatting,
  ready,
}

@immutable
class ReadingState {
  final int bookId;
  final Book? book;
  final List<ContentBlock> blocks;
  final int currentPage;
  final bool isBookLoaded;
  final Map<int, int> pageToBlockIndexMap;
  final int totalPages;
  final ReadingViewStatus viewStatus;

  const ReadingState({
    required this.bookId,
    this.book,
    this.blocks = const [],
    this.currentPage = 0,
    this.isBookLoaded = false,
    this.pageToBlockIndexMap = const {0: 0},
    this.totalPages = 1,
    this.viewStatus = ReadingViewStatus.formatting,
  });

  String get chapterProgress {
    if (blocks.isEmpty || pageToBlockIndexMap[currentPage] == null) {
      return "Loading chapter...";
    }
    final currentBlockIndex = pageToBlockIndexMap[currentPage]!;
    if (currentBlockIndex >= blocks.length) return "Calculating...";
    final currentChapterIndex = blocks[currentBlockIndex].chapterIndex;
    int chapterStartBlock = blocks.indexWhere((b) => b.chapterIndex == currentChapterIndex);
    int chapterEndBlock = blocks.lastIndexWhere((b) => b.chapterIndex == currentChapterIndex);
    int? chapterStartPage;
    for (final entry in pageToBlockIndexMap.entries) {
      if (entry.value >= chapterStartBlock) {
        chapterStartPage = entry.key;
        break;
      }
    }
    chapterStartPage ??= 0;
    int? chapterEndPage;
    for (final entry in pageToBlockIndexMap.entries) {
      if (entry.value > chapterEndBlock) {
        chapterEndPage = entry.key - 1;
        break;
      }
    }
    chapterEndPage ??= totalPages - 1;
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
    ReadingViewStatus? viewStatus,
  }) {
    return ReadingState(
      bookId: bookId,
      book: book ?? this.book,
      blocks: blocks ?? this.blocks,
      currentPage: currentPage ?? this.currentPage,
      isBookLoaded: isBookLoaded ?? this.isBookLoaded,
      pageToBlockIndexMap: pageToBlockIndexMap ?? this.pageToBlockIndexMap,
      totalPages: totalPages ?? this.totalPages,
      viewStatus: viewStatus ?? this.viewStatus,
    );
  }
}

class ReadingController extends StateNotifier<ReadingState> {
  final Isar _isar;
  final LayoutCacheService _layoutCache;
  final _Debouncer _debouncer = _Debouncer(milliseconds: 1000);
  String _layoutKey = '';

  ReadingController(this._isar, this._layoutCache, int bookId)
      : super(ReadingState(bookId: bookId));

  Future<void> initialize({
    required Size viewSize,
    required ReadingPreferences preferences,
  }) async {
    print("CTRL: Initializing ReadingController for bookId: ${state.bookId}");
    _layoutKey = _generateLayoutKey(viewSize, preferences);
    final cachedLayout = _layoutCache.getLayout(_layoutKey);
    final bookMeta = await _isar.books.get(state.bookId);

    if (bookMeta == null) {
      print("CTRL: ERROR - Book with ID ${state.bookId} not found in Isar.");
      return;
    }
    final lastReadChapter = bookMeta.lastReadChapter ?? 0;

    if (cachedLayout != null) {
      print("CTRL: Cache HIT. Loading all blocks and applying cached layout.");
      final allBlocks = await _isar.contentBlocks.filter().bookIdEqualTo(state.bookId).findAll();
      state = state.copyWith(
        book: bookMeta,
        blocks: allBlocks,
        pageToBlockIndexMap: cachedLayout,
        totalPages: cachedLayout.keys.length,
        isBookLoaded: true,
        viewStatus: ReadingViewStatus.ready,
        currentPage: bookMeta.lastReadPage,
      );
    } else {
      print("CTRL: Cache MISS. Starting JIT pagination.");
      state = state.copyWith(
        book: bookMeta,
        isBookLoaded: true,
        viewStatus: ReadingViewStatus.formatting,
        currentPage: bookMeta.lastReadPage,
      );
      await _loadChapterBlocks(lastReadChapter);

      // FIX: Only set status to ready if blocks were actually loaded.
      if (mounted && state.blocks.isNotEmpty) {
        state = state.copyWith(viewStatus: ReadingViewStatus.ready);
      } else if (mounted) {
        print("CTRL: ERROR - No blocks loaded for the initial chapter. The book may be empty.");
        // The UI will now use its defensive check to show an error message.
      }
    }
  }

  Future<void> _loadChapterBlocks(int chapterIndex) async {
    print("CTRL: JIT loading blocks for chapter $chapterIndex");
    final chapterBlocks = await _isar.contentBlocks.filter().bookIdEqualTo(state.bookId).and().chapterIndexEqualTo(chapterIndex).sortByBlockIndexInChapter().findAll();
    if (mounted) {
      final existingBlockIds = state.blocks.map((b) => b.id).toSet();
      final newBlocks = chapterBlocks.where((b) => !existingBlockIds.contains(b.id)).toList();
      state = state.copyWith(blocks: [...state.blocks, ...newBlocks]);
      print("CTRL: Loaded ${newBlocks.length} new blocks for chapter $chapterIndex.");
    }
  }

  String _generateLayoutKey(Size viewSize, ReadingPreferences prefs) {
    return '${state.bookId}_${viewSize.width.round()}x${viewSize.height.round()}_${prefs.fontFamily}_${prefs.fontSize.toStringAsFixed(1)}_${prefs.lineSpacing.toStringAsFixed(1)}';
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
        final allBookBlocksCount = state.book?.blocksCount ?? -1;
        if (allBookBlocksCount > 0 && state.blocks.length >= allBookBlocksCount) {
          print("CTRL: Pagination complete for the ENTIRE book. Saving to cache with key: $_layoutKey");
          _layoutCache.saveLayout(_layoutKey, newMap);
        }
      } else {
        newTotalPages = state.totalPages > nextPageIndex ? state.totalPages : nextPageIndex + 1;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          state = state.copyWith(pageToBlockIndexMap: newMap, totalPages: newTotalPages);
        }
      });
    }
  }

  void onPageChanged(int page) {
    if (page != state.currentPage) {
      if (mounted) state = state.copyWith(currentPage: page);
      _debouncer.run(() => _saveProgress(page));
      final currentBlockIndex = state.pageToBlockIndexMap[page] ?? 0;
      if (currentBlockIndex >= state.blocks.length) return;
      final currentBlock = state.blocks[currentBlockIndex];
      final currentChapterIndex = currentBlock.chapterIndex!;
      final blocksInChapter = state.blocks.where((b) => b.chapterIndex == currentChapterIndex).toList();
      final totalBlocksInChapter = blocksInChapter.length;
      if (totalBlocksInChapter == 0) return;
      final currentPositionInChapter = blocksInChapter.indexWhere((b) => b.id == currentBlock.id);
      if ((currentPositionInChapter / totalBlocksInChapter) > 0.8) {
        final nextChapterIndex = currentChapterIndex + 1;
        final isNextChapterLoaded = state.blocks.any((b) => b.chapterIndex == nextChapterIndex);
        if (!isNextChapterLoaded && state.book!.chaptersCount > nextChapterIndex) {
          print("CTRL: Reached 80% of chapter $currentChapterIndex. Pre-fetching chapter $nextChapterIndex.");
          _loadChapterBlocks(nextChapterIndex);
        }
      }
    }
  }

  Future<void> _saveProgress(int page) async {
    if (!mounted) return;
    final currentBlockIndex = state.pageToBlockIndexMap[page] ?? 0;
    if (currentBlockIndex >= state.blocks.length) return;
    final lastReadChapter = state.blocks[currentBlockIndex].chapterIndex ?? 0;
    await _isar.writeTxn(() async {
      final book = await _isar.books.get(state.bookId);
      if (book != null) {
        book.lastReadPage = page;
        book.lastReadChapter = lastReadChapter;
        book.lastReadTimestamp = DateTime.now();
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
    if (entry.src == null || !mounted) return;
    print("CTRL: jumpToLocation called for src: ${entry.src}");
    final blockSample = await _isar.contentBlocks.filter().bookIdEqualTo(state.bookId).and().srcEqualTo(entry.src!).findFirst();
    if (blockSample == null || blockSample.chapterIndex == null) {
      print("CTRL: ERROR - Could not find a chapter index for src: ${entry.src}");
      return;
    }
    final targetChapterIndex = blockSample.chapterIndex!;
    final isChapterLoaded = state.blocks.any((b) => b.chapterIndex == targetChapterIndex);
    if (!isChapterLoaded) {
      print("CTRL: Target chapter $targetChapterIndex not loaded. Fetching JIT...");
      await _loadChapterBlocks(targetChapterIndex);
    }
    final currentBlocks = state.blocks;
    final targetBlockIndex = currentBlocks.indexWhere((b) => b.src == entry.src);
    if (targetBlockIndex != -1) {
      final targetPage = await _findPageForBlock(targetBlockIndex);
      if (targetPage != null && mounted) {
        state = state.copyWith(currentPage: targetPage);
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
    if (!selection.isValid || blockIndex < 0 || blockIndex >= state.blocks.length) return;
    final block = state.blocks[blockIndex];
    final selectedText = selection.textInside(block.textContent ?? '');
    if (selectedText.isEmpty) return;
    final newHighlight = Highlight()
      ..bookId = state.bookId
      ..chapterIndex = block.chapterIndex
      ..blockIndexInChapter = block.blockIndexInChapter
      ..text = selectedText
      ..startOffset = selection.start
      ..endOffset = selection.end
      ..color = color.value;
    await _isar.writeTxn(() async {
      await _isar.highlights.put(newHighlight);
    });
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

final readingControllerProvider = StateNotifierProvider.family.autoDispose<ReadingController, ReadingState, int>((ref, bookId) {
  final isar = ref.watch(isarDBProvider).value!;
  final cache = ref.watch(layoutCacheProvider);
  return ReadingController(isar, cache, bookId);
});