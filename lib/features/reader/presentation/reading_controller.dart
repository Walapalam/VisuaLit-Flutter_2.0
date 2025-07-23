import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/data/highlight.dart';
import 'package:visualit/features/reader/data/toc_entry.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';
import 'package:path/path.dart' as p;

@immutable
class ReadingState {
  final int bookId;
  final Book? book;
  final List<ContentBlock> blocks;
  final int currentPage;
  final bool isBookLoaded;
  final Map<int, int> pageToBlockIndexMap;
  final int totalPages;
  final Size? viewSize;

  const ReadingState({
    required this.bookId,
    this.book,
    this.blocks = const [],
    this.currentPage = 0,
    this.isBookLoaded = false,
    this.pageToBlockIndexMap = const {0: 0},
    this.totalPages = 1,
    this.viewSize,
  });

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
        chapterEndPage = entry.key - 1;
        break;
      }
    }
    chapterEndPage ??= totalPages - 1;

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
    Size? viewSize,
  }) {
    return ReadingState(
      bookId: bookId,
      book: book ?? this.book,
      blocks: blocks ?? this.blocks,
      currentPage: currentPage ?? this.currentPage,
      isBookLoaded: isBookLoaded ?? this.isBookLoaded,
      pageToBlockIndexMap: pageToBlockIndexMap ?? this.pageToBlockIndexMap,
      totalPages: totalPages ?? this.totalPages,
      viewSize: viewSize ?? this.viewSize,
    );
  }
}

class ReadingController extends StateNotifier<ReadingState> {
  final Isar _isar;
  final _Debouncer _debouncer = _Debouncer(milliseconds: 1000);

  ReadingController(this._isar, int bookId) : super(ReadingState(bookId: bookId)) {
    _initialize();
  }

  Future<void> _initialize() async {
    final book = await _isar.books.get(state.bookId);
    final blocks = await _isar.contentBlocks.filter().bookIdEqualTo(state.bookId).findAll();

    if (mounted) {
      state = state.copyWith(
        book: book,
        blocks: blocks,
        currentPage: book?.lastReadPage ?? 0,
        isBookLoaded: true,
      );
      if (state.viewSize != null) {
        _recalculateLayout();
      }
    }
  }

  void setLayoutParameters(ReadingPreferences prefs, Size viewSize) {
    if (state.viewSize != viewSize) {
      if (mounted) {
        state = state.copyWith(viewSize: viewSize);
      }
      _recalculateLayout();
    }
  }

  void _recalculateLayout() {
    if (!mounted || state.blocks.isEmpty || state.viewSize == null) return;

    final newPageToBlockIndexMap = <int, int>{0: 0};
    state = state.copyWith(
      pageToBlockIndexMap: newPageToBlockIndexMap,
      totalPages: 1,
    );
  }

  void updatePageLayout(int pageIndex, int startingBlock, int endingBlock) {
    if (!mounted) return;
    final nextPageIndex = pageIndex + 1;
    final nextBlockIndex = endingBlock + 1;

    if ((state.pageToBlockIndexMap[nextPageIndex] == null || state.pageToBlockIndexMap[nextPageIndex]! < nextBlockIndex) && nextBlockIndex <= state.blocks.length) {
      final newMap = Map<int, int>.from(state.pageToBlockIndexMap);
      newMap[nextPageIndex] = nextBlockIndex;

      int newTotalPages = state.totalPages;
      if (nextBlockIndex >= state.blocks.length) {
        newTotalPages = nextPageIndex + 1;
      } else {
        newTotalPages = math.max(state.totalPages, nextPageIndex + 1);
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
      _debouncer.run(() => _saveProgressToDb(page));
    }
  }

  Future<void> _saveProgressToDb(int page) async {
    await _isar.writeTxn(() async {
      final book = await _isar.books.get(state.bookId);
      if (book != null) {
        book.lastReadPage = page;
        book.lastReadTimestamp = DateTime.now();
        await _isar.books.put(book);
      }
    });
  }

  Future<void> jumpToLocation(TOCEntry entry) async {
    if (entry.src == null || state.blocks.isEmpty) return;

    int targetBlockIndex = state.blocks.indexWhere((b) => b.src == entry.src);

    if (entry.fragment != null && entry.fragment!.isNotEmpty && targetBlockIndex != -1) {
      final fragmentBlockIndex = state.blocks.indexWhere((block) =>
      block.chapterIndex == state.blocks[targetBlockIndex].chapterIndex &&
          block.htmlContent?.contains('id="${entry.fragment}"') == true);
      if (fragmentBlockIndex != -1) {
        targetBlockIndex = fragmentBlockIndex;
      }
    }

    if (targetBlockIndex != -1) {
      final targetPage = await _findPageForBlock(targetBlockIndex);
      if (targetPage != null && mounted) {
        state = state.copyWith(currentPage: targetPage);
      } else {
        if (mounted) {
          state = state.copyWith(currentPage: 0);
        }
      }
    }
  }

  Future<int?> _findPageForBlock(int targetBlockIndex) async {
    if (!mounted) return null;

    for (final entry in state.pageToBlockIndexMap.entries) {
      final startBlockOfPage = entry.value;
      final endBlockOfPage = (state.pageToBlockIndexMap[entry.key + 1] ?? state.blocks.length) - 1;

      if (targetBlockIndex >= startBlockOfPage && targetBlockIndex <= endBlockOfPage) {
        return entry.key;
      }
    }

    int lastKnownPage = state.pageToBlockIndexMap.keys.isNotEmpty ? state.pageToBlockIndexMap.keys.last : 0;
    if (lastKnownPage == 0 && state.pageToBlockIndexMap[0] == null) lastKnownPage = 0;

    while (mounted && lastKnownPage < state.totalPages) {
      if (mounted) {
        state = state.copyWith(currentPage: lastKnownPage);
      }
      await Future.delayed(const Duration(milliseconds: 50));

      final currentLastBlockOnPage = (state.pageToBlockIndexMap[lastKnownPage + 1] ?? state.blocks.length) - 1;

      if (targetBlockIndex <= currentLastBlockOnPage) {
        return lastKnownPage;
      }
      if (currentLastBlockOnPage >= state.blocks.length - 1) {
        return lastKnownPage;
      }
      lastKnownPage++;
    }
    return state.currentPage;
  }

  Future<void> jumpToHref(String href, String currentBlockSrc) async {
    final resolvedPath = p.normalize(p.join(p.dirname(currentBlockSrc), href));
    final parts = resolvedPath.split('#');
    final src = parts.isNotEmpty && parts[0].isNotEmpty ? parts[0] : null;
    final fragment = parts.length > 1 ? parts[1] : null;

    if (src != null) {
      await jumpToLocation(TOCEntry()..src = src..fragment = fragment..title = 'Internal Link');
    }
  }

  Future<void> addHighlight(Highlight newHighlight) async {
    await _isar.writeTxn(() async {
      await _isar.highlights.put(newHighlight);
    });
  }
}

final readingControllerProvider =
StateNotifierProvider.family.autoDispose<ReadingController, ReadingState, int>((ref, bookId) {
  final isar = ref.watch(isarDBProvider).value!;
  return ReadingController(isar, bookId);
});

class _Debouncer {
  final int milliseconds;
  Timer? _timer;

  _Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
