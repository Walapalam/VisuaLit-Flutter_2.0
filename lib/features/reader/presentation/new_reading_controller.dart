import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:visualit/core/providers/storage_provider.dart';
import 'package:visualit/core/services/storage_service.dart';
import 'package:visualit/features/reader/data/new_models.dart';

@immutable
class ReadingState {
  final int bookId;
  final Book? book;
  final List<ContentBlock> blocks;
  final int currentPage;
  final bool isBookLoaded;
  final Map<int, int> pageToBlockIndexMap;
  final int totalPages;

  const ReadingState({
    required this.bookId,
    this.book,
    this.blocks = const [],
    this.currentPage = 0,
    this.isBookLoaded = false,
    this.pageToBlockIndexMap = const {0: 0},
    this.totalPages = 1,
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
  }) {
    return ReadingState(
      bookId: bookId,
      book: book ?? this.book,
      blocks: blocks ?? this.blocks,
      currentPage: currentPage ?? this.currentPage,
      isBookLoaded: isBookLoaded ?? this.isBookLoaded,
      pageToBlockIndexMap: pageToBlockIndexMap ?? this.pageToBlockIndexMap,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

class NewReadingController extends StateNotifier<ReadingState> {
  final StorageService _storage;
  final _Debouncer _debouncer = _Debouncer(milliseconds: 1000);
  final Completer<void> _layoutCompleter = Completer<void>();

  NewReadingController(this._storage, int bookId) : super(ReadingState(bookId: bookId)) {
    _initialize();
  }

  Future<void> _initialize() async {
    // Fetch both book and blocks
    final book = await _storage.getBook(state.bookId);
    final blocks = await _storage.getContentBlocksForBook(state.bookId);

    if (mounted) {
      state = state.copyWith(
        book: book,
        blocks: blocks,
        currentPage: book?.lastReadPage ?? 0,
        isBookLoaded: true,
      );
    }
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
          state = state.copyWith(pageToBlockIndexMap: newMap, totalPages: newTotalPages);
        }
      });
    }
  }

  void onPageChanged(int page) {
    if (page != state.currentPage) {
      if (mounted) state = state.copyWith(currentPage: page);
      _debouncer.run(() => _saveProgress(page));
    }
  }

  Future<void> _saveProgress(int page) async {
    final book = await _storage.getBook(state.bookId);
    if (book != null) {
      book.lastReadPage = page;
      book.lastReadTimestamp = DateTime.now();
      await _storage.saveBook(book);
    }
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
    final targetBlockIndex = state.blocks.indexWhere((b) => b.src == entry.src);
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
      await jumpToLocation(TOCEntry(src: src, title: 'Internal Link'));
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
    
    final newHighlight = Highlight(
      id: 0, // The storage service will assign an ID
      bookId: state.bookId,
      chapterIndex: block.chapterIndex,
      blockIndexInChapter: block.blockIndexInChapter,
      text: selectedText,
      startOffset: selection.start,
      endOffset: selection.end,
      color: color.value,
    );
    
    await _storage.saveHighlight(newHighlight);
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

final newReadingControllerProvider =
StateNotifierProvider.family.autoDispose<NewReadingController, ReadingState, int>((ref, bookId) {
  final storage = ref.watch(storageProvider);
  return NewReadingController(storage, bookId);
});