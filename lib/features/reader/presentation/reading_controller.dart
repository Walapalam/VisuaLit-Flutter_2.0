import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/data/highlight.dart';
import 'package:visualit/features/reader/data/toc_entry.dart';

@immutable
class ReadingState {
  final int bookId;
  final Book? book; // <-- ADDED: The full book object for metadata
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

class ReadingController extends StateNotifier<ReadingState> {
  final Isar _isar;
  final _Debouncer _debouncer = _Debouncer(milliseconds: 1000);
  final Completer<void> _layoutCompleter = Completer<void>();

  ReadingController(this._isar, int bookId) : super(ReadingState(bookId: bookId)) {
    debugPrint("[DEBUG] ReadingController: Initializing controller for book ID: $bookId");
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      debugPrint("[DEBUG] ReadingController: Loading book and content blocks for book ID: ${state.bookId}");
      // --- UPDATED: Fetch both book and blocks ---
      final book = await _isar.books.get(state.bookId);

      if (book == null) {
        debugPrint("[ERROR] ReadingController: Book with ID ${state.bookId} not found in database");
        return;
      }

      debugPrint("[DEBUG] ReadingController: Book found: ${book.title ?? 'Untitled'}, fetching content blocks");
      final blocks = await _isar.contentBlocks.filter().bookIdEqualTo(state.bookId).findAll();
      debugPrint("[DEBUG] ReadingController: Loaded ${blocks.length} content blocks");

      if (mounted) {
        state = state.copyWith(
          book: book, // Save the book object to state
          blocks: blocks,
          currentPage: book.lastReadPage,
          isBookLoaded: true,
        );
        debugPrint("[DEBUG] ReadingController: State updated, current page: ${state.currentPage}, total blocks: ${blocks.length}");
      } else {
        debugPrint("[WARN] ReadingController: Controller no longer mounted during initialization");
      }
    } catch (e, stack) {
      debugPrint("[ERROR] ReadingController: Failed to initialize: $e");
      debugPrintStack(stackTrace: stack);
    }
  }

  void updatePageLayout(int pageIndex, int startingBlock, int endingBlock) {
    try {
      debugPrint("[DEBUG] ReadingController: Updating page layout - pageIndex: $pageIndex, startingBlock: $startingBlock, endingBlock: $endingBlock");

      if (!mounted) {
        debugPrint("[WARN] ReadingController: Controller not mounted, skipping updatePageLayout");
        return;
      }

      final nextPageIndex = pageIndex + 1;
      final nextBlockIndex = endingBlock + 1;

      debugPrint("[DEBUG] ReadingController: Next page index: $nextPageIndex, next block index: $nextBlockIndex");

      if (state.pageToBlockIndexMap[nextPageIndex] != nextBlockIndex) {
        debugPrint("[DEBUG] ReadingController: Updating page-to-block mapping for page $nextPageIndex to block $nextBlockIndex");

        final newMap = Map<int, int>.from(state.pageToBlockIndexMap);
        newMap[nextPageIndex] = nextBlockIndex;
        int newTotalPages = state.totalPages;

        if (nextBlockIndex >= state.blocks.length) {
          newTotalPages = nextPageIndex;
          debugPrint("[DEBUG] ReadingController: Reached end of book, setting total pages to $newTotalPages");

          if (!_layoutCompleter.isCompleted) {
            debugPrint("[DEBUG] ReadingController: Completing layout completer");
            _layoutCompleter.complete();
          }
        } else {
          newTotalPages = state.totalPages > nextPageIndex ? state.totalPages : nextPageIndex + 1;
          debugPrint("[DEBUG] ReadingController: Updated total pages to $newTotalPages");
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            if (mounted) {
              debugPrint("[DEBUG] ReadingController: Updating state with new page mapping and total pages: $newTotalPages");
              state = state.copyWith(pageToBlockIndexMap: newMap, totalPages: newTotalPages);
            } else {
              debugPrint("[WARN] ReadingController: Controller no longer mounted in post-frame callback");
            }
          } catch (e) {
            debugPrint("[ERROR] ReadingController: Error in post-frame callback: $e");
          }
        });
      } else {
        debugPrint("[DEBUG] ReadingController: No change in page-to-block mapping, skipping update");
      }
    } catch (e, stack) {
      debugPrint("[ERROR] ReadingController: Error updating page layout: $e");
      debugPrintStack(stackTrace: stack);
    }
  }

  void onPageChanged(int page) {
    try {
      debugPrint("[DEBUG] ReadingController: Page changed to $page (current: ${state.currentPage})");

      if (page != state.currentPage) {
        if (mounted) {
          debugPrint("[DEBUG] ReadingController: Updating state with new current page: $page");
          state = state.copyWith(currentPage: page);
        } else {
          debugPrint("[WARN] ReadingController: Controller not mounted, skipping state update");
        }

        debugPrint("[DEBUG] ReadingController: Scheduling save progress with debouncer");
        _debouncer.run(() => _saveProgress(page));
      } else {
        debugPrint("[DEBUG] ReadingController: Page unchanged, skipping update");
      }
    } catch (e, stack) {
      debugPrint("[ERROR] ReadingController: Error in onPageChanged: $e");
      debugPrintStack(stackTrace: stack);
    }
  }

  Future<void> _saveProgress(int page) async {
    try {
      debugPrint("[DEBUG] ReadingController: Saving reading progress for page $page");

      await _isar.writeTxn(() async {
        try {
          final book = await _isar.books.get(state.bookId);

          if (book != null) {
            debugPrint("[DEBUG] ReadingController: Updating book (${book.title ?? 'Untitled'}) with last read page: $page");
            book.lastReadPage = page;
            book.lastReadTimestamp = DateTime.now();
            await _isar.books.put(book);
            debugPrint("[DEBUG] ReadingController: Progress saved successfully");
          } else {
            debugPrint("[WARN] ReadingController: Book not found in database, progress not saved");
          }
        } catch (e) {
          debugPrint("[ERROR] ReadingController: Error in database transaction: $e");
          rethrow;
        }
      });
    } catch (e, stack) {
      debugPrint("[ERROR] ReadingController: Failed to save reading progress: $e");
      debugPrintStack(stackTrace: stack);
    }
  }

  Future<int?> findPageForBlock(int targetBlockIndex) async {
    try {
      debugPrint("[DEBUG] ReadingController: Finding page for block index: $targetBlockIndex");

      if (!mounted) {
        debugPrint("[WARN] ReadingController: Controller not mounted, cannot find page for block");
        return null;
      }

      if (targetBlockIndex < 0 || targetBlockIndex >= state.blocks.length) {
        debugPrint("[ERROR] ReadingController: Invalid target block index: $targetBlockIndex (total blocks: ${state.blocks.length})");
        return null;
      }

      // First, check if the block is in the known page mapping
      for (final entry in state.pageToBlockIndexMap.entries) {
        final start = entry.value;
        final end = (state.pageToBlockIndexMap[entry.key + 1] ?? state.blocks.length) - 1;

        if (targetBlockIndex >= start && targetBlockIndex <= end) {
          debugPrint("[DEBUG] ReadingController: Block $targetBlockIndex found on page ${entry.key} (block range: $start-$end)");
          return entry.key;
        }
      }

      // If not found in the mapping, we need to navigate to find it
      debugPrint("[DEBUG] ReadingController: Block not found in current page mapping, navigating to find it");
      int lastKnownPage = state.pageToBlockIndexMap.keys.last;
      debugPrint("[DEBUG] ReadingController: Starting search from last known page: $lastKnownPage");

      state = state.copyWith(currentPage: lastKnownPage);

      int searchAttempts = 0;
      final maxSearchAttempts = 100; // Prevent infinite loops

      while (mounted && searchAttempts < maxSearchAttempts) {
        searchAttempts++;
        await Future.delayed(const Duration(milliseconds: 50));

        final lastBlockOnLastPage = (state.pageToBlockIndexMap[lastKnownPage + 1] ?? 0) - 1;
        debugPrint("[DEBUG] ReadingController: Search attempt $searchAttempts - Last block on page $lastKnownPage is $lastBlockOnLastPage");

        if (targetBlockIndex <= lastBlockOnLastPage) {
          debugPrint("[DEBUG] ReadingController: Found block $targetBlockIndex on or before page $lastKnownPage");
          return lastKnownPage;
        }

        if (lastBlockOnLastPage >= state.blocks.length - 1) {
          debugPrint("[DEBUG] ReadingController: Reached end of book, returning last page: $lastKnownPage");
          return lastKnownPage;
        }

        lastKnownPage++;
        debugPrint("[DEBUG] ReadingController: Moving to next page: $lastKnownPage");
        state = state.copyWith(currentPage: lastKnownPage);
      }

      if (searchAttempts >= maxSearchAttempts) {
        debugPrint("[WARN] ReadingController: Exceeded maximum search attempts ($maxSearchAttempts), giving up");
      }

      debugPrint("[WARN] ReadingController: Could not find page for block $targetBlockIndex");
      return null;
    } catch (e, stack) {
      debugPrint("[ERROR] ReadingController: Error finding page for block: $e");
      debugPrintStack(stackTrace: stack);
      return null;
    }
  }

  Future<void> jumpToLocation(TOCEntry entry) async {
    try {
      debugPrint("[DEBUG] ReadingController: Jumping to location - entry: ${entry.title}, src: ${entry.src}");

      if (entry.src == null) {
        debugPrint("[WARN] ReadingController: Cannot jump to location - entry has no source path");
        return;
      }

      debugPrint("[DEBUG] ReadingController: Searching for block with source: ${entry.src}");
      final targetBlockIndex = state.blocks.indexWhere((b) => b.src == entry.src);

      if (targetBlockIndex != -1) {
        debugPrint("[DEBUG] ReadingController: Found matching block at index: $targetBlockIndex");
        final targetPage = await findPageForBlock(targetBlockIndex);

        if (targetPage != null && mounted) {
          debugPrint("[DEBUG] ReadingController: Navigating to page: $targetPage");
          state = state.copyWith(currentPage: targetPage);
        } else if (targetPage == null) {
          debugPrint("[WARN] ReadingController: Could not find page for block index: $targetBlockIndex");
        } else {
          debugPrint("[WARN] ReadingController: Controller no longer mounted, cannot navigate");
        }
      } else {
        debugPrint("[WARN] ReadingController: No block found with source: ${entry.src}");
      }
    } catch (e, stack) {
      debugPrint("[ERROR] ReadingController: Error jumping to location: $e");
      debugPrintStack(stackTrace: stack);
    }
  }

  Future<void> jumpToHref(String href, String currentBlockSrc) async {
    try {
      debugPrint("[DEBUG] ReadingController: Jumping to href: $href from source: $currentBlockSrc");

      final resolvedPath = p.normalize(p.join(p.dirname(currentBlockSrc), href));
      debugPrint("[DEBUG] ReadingController: Resolved path: $resolvedPath");

      final parts = resolvedPath.split('#');
      final src = parts.isNotEmpty ? parts[0] : null;
      final fragment = parts.length > 1 ? parts[1] : null;

      if (src != null) {
        debugPrint("[DEBUG] ReadingController: Jumping to source: $src" + (fragment != null ? " with fragment: $fragment" : ""));
        final entry = TOCEntry()..src = src..title = 'Internal Link'..fragment = fragment;
        await jumpToLocation(entry);
      } else {
        debugPrint("[WARN] ReadingController: Could not extract source path from href: $href");
      }
    } catch (e, stack) {
      debugPrint("[ERROR] ReadingController: Error jumping to href: $e");
      debugPrintStack(stackTrace: stack);
    }
  }

  Future<void> addHighlight(TextSelection selection, int blockIndex, Color color) async {
    try {
      debugPrint("[DEBUG] ReadingController: Adding highlight - blockIndex: $blockIndex, selection: ${selection.start}-${selection.end}, color: ${color.value}");

      // Validate inputs
      if (!selection.isValid) {
        debugPrint("[WARN] ReadingController: Cannot add highlight - invalid text selection");
        return;
      }

      if (blockIndex < 0 || blockIndex >= state.blocks.length) {
        debugPrint("[WARN] ReadingController: Cannot add highlight - block index out of range: $blockIndex (total blocks: ${state.blocks.length})");
        return;
      }

      final block = state.blocks[blockIndex];

      if (block.textContent == null) {
        debugPrint("[WARN] ReadingController: Cannot add highlight - block has no text content");
        return;
      }

      final selectedText = selection.textInside(block.textContent!);

      if (selectedText.isEmpty) {
        debugPrint("[WARN] ReadingController: Cannot add highlight - selected text is empty");
        return;
      }

      debugPrint("[DEBUG] ReadingController: Creating highlight for text: '${selectedText.length > 50 ? selectedText.substring(0, 47) + '...' : selectedText}'");

      final newHighlight = Highlight()
        ..bookId = state.bookId
        ..chapterIndex = block.chapterIndex ?? 0
        ..blockIndexInChapter = block.blockIndexInChapter ?? 0
        ..text = selectedText
        ..startOffset = selection.start
        ..endOffset = selection.end
        ..color = color.value;

      await _isar.writeTxn(() async {
        try {
          final id = await _isar.highlights.put(newHighlight);
          debugPrint("[DEBUG] ReadingController: Highlight added successfully with ID: $id");
        } catch (e) {
          debugPrint("[ERROR] ReadingController: Error saving highlight to database: $e");
          rethrow;
        }
      });
    } catch (e, stack) {
      debugPrint("[ERROR] ReadingController: Failed to add highlight: $e");
      debugPrintStack(stackTrace: stack);
    }
  }
}

class _Debouncer {
  final int milliseconds;
  Timer? _timer;

  _Debouncer({required this.milliseconds}) {
    debugPrint("[DEBUG] _Debouncer: Created with delay of $milliseconds ms");
  }

  void run(VoidCallback action) {
    try {
      debugPrint("[DEBUG] _Debouncer: Running debounced action");
      _timer?.cancel();
      _timer = Timer(Duration(milliseconds: milliseconds), () {
        try {
          debugPrint("[DEBUG] _Debouncer: Executing debounced action after $milliseconds ms");
          action();
        } catch (e) {
          debugPrint("[ERROR] _Debouncer: Error executing debounced action: $e");
        }
      });
    } catch (e) {
      debugPrint("[ERROR] _Debouncer: Error setting up debounced action: $e");
    }
  }

  void dispose() {
    try {
      if (_timer != null) {
        debugPrint("[DEBUG] _Debouncer: Cancelling timer on dispose");
        _timer!.cancel();
        _timer = null;
      }
    } catch (e) {
      debugPrint("[ERROR] _Debouncer: Error disposing timer: $e");
    }
  }
}

final readingControllerProvider =
StateNotifierProvider.family.autoDispose<ReadingController, ReadingState, int>((ref, bookId) {
  debugPrint("[DEBUG] readingControllerProvider: Creating controller for book ID: $bookId");

  try {
    final isarAsync = ref.watch(isarDBProvider);

    if (isarAsync.hasError) {
      debugPrint("[ERROR] readingControllerProvider: Isar database error: ${isarAsync.error}");
      throw isarAsync.error!;
    }

    if (!isarAsync.hasValue) {
      debugPrint("[WARN] readingControllerProvider: Isar database not yet initialized");
      throw Exception("Isar database not yet initialized");
    }

    final isar = isarAsync.value!;
    debugPrint("[DEBUG] readingControllerProvider: Isar database ready, creating controller");

    final controller = ReadingController(isar, bookId);

    ref.onDispose(() {
      debugPrint("[DEBUG] readingControllerProvider: Disposing controller for book ID: $bookId");
    });

    return controller;
  } catch (e, stack) {
    debugPrint("[ERROR] readingControllerProvider: Failed to create controller: $e");
    debugPrintStack(stackTrace: stack);
    rethrow;
  }
});
