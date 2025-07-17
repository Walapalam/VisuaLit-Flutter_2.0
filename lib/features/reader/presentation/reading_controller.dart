import 'dart:async';
import 'dart:collection';
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

      // Convert the precomputed pagination data from the book
      Map<int, int> pageToBlockMap = {};
      if (book.pageToBlockMap.isNotEmpty) {
        debugPrint("[DEBUG] ReadingController: Using precomputed pagination data from book (${book.pageToBlockMap.length ~/ 2} entries)");

        // The pageToBlockMap is stored as a list of alternating page indices and block indices
        // [pageIndex1, blockIndex1, pageIndex2, blockIndex2, ...]
        for (int i = 0; i < book.pageToBlockMap.length - 1; i += 2) {
          final pageIndex = book.pageToBlockMap[i];
          final blockIndex = book.pageToBlockMap[i + 1];
          pageToBlockMap[pageIndex] = blockIndex;
        }

        debugPrint("[DEBUG] ReadingController: Converted pagination data to map with ${pageToBlockMap.length} entries");
      } else {
        debugPrint("[WARN] ReadingController: No precomputed pagination data found in book, using default");
        pageToBlockMap = {0: 0}; // Default mapping: first page starts at first block
      }

      if (mounted) {
        state = state.copyWith(
          book: book, // Save the book object to state
          blocks: blocks,
          currentPage: book.lastReadPage,
          isBookLoaded: true,
          pageToBlockIndexMap: pageToBlockMap,
          totalPages: book.totalPages > 0 ? book.totalPages : 1,
        );
        debugPrint("[DEBUG] ReadingController: State updated, current page: ${state.currentPage}, total blocks: ${blocks.length}, total pages: ${book.totalPages}");
      } else {
        debugPrint("[WARN] ReadingController: Controller no longer mounted during initialization");
      }
    } catch (e, stack) {
      debugPrint("[ERROR] ReadingController: Failed to initialize: $e");
      debugPrintStack(stackTrace: stack);
    }
  }

  // Flag to prevent concurrent updates to the page mapping
  bool _isUpdatingPageMap = false;

  /// Update the page layout mapping based on the rendered page
  Future<void> updatePageLayout(int pageIndex, int startingBlock, int endingBlock) async {
    if (!mounted) {
      debugPrint("[WARN] ReadingController: Controller not mounted, skipping updatePageLayout");
      return;
    }

    // Validate inputs
    if (pageIndex < 0) {
      debugPrint("[ERROR] ReadingController: Invalid page index: $pageIndex");
      return;
    }

    if (startingBlock < 0 || endingBlock < 0 || startingBlock > endingBlock) {
      debugPrint("[ERROR] ReadingController: Invalid block range: $startingBlock-$endingBlock");
      return;
    }

    if (state.blocks.isEmpty) {
      debugPrint("[WARN] ReadingController: No blocks available, skipping updatePageLayout");
      return;
    }

    if (endingBlock >= state.blocks.length) {
      debugPrint("[WARN] ReadingController: Ending block index out of range: $endingBlock (max: ${state.blocks.length - 1})");
      endingBlock = state.blocks.length - 1;
    }

    // Check if another update is in progress
    if (_isUpdatingPageMap) {
      debugPrint("[WARN] ReadingController: Another page map update is in progress, skipping");
      return;
    }

    // Set flag to prevent concurrent updates
    _isUpdatingPageMap = true;

    try {
      debugPrint("[DEBUG] ReadingController: Updating page layout - pageIndex: $pageIndex, startingBlock: $startingBlock, endingBlock: $endingBlock");

      final nextPageIndex = pageIndex + 1;
      final nextBlockIndex = endingBlock + 1;

      debugPrint("[DEBUG] ReadingController: Next page index: $nextPageIndex, next block index: $nextBlockIndex");

      // Check if this update would change the mapping
      if (state.pageToBlockIndexMap[nextPageIndex] != nextBlockIndex) {
        debugPrint("[DEBUG] ReadingController: Updating page-to-block mapping for page $nextPageIndex to block $nextBlockIndex");

        // Create a new map with the updated mapping
        final newMap = Map<int, int>.from(state.pageToBlockIndexMap);
        newMap[nextPageIndex] = nextBlockIndex;

        // Ensure the map is sorted by page index
        final sortedMap = Map<int, int>.fromEntries(
          newMap.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
        );

        // Calculate the new total pages
        int newTotalPages = state.totalPages;

        if (nextBlockIndex >= state.blocks.length) {
          // We've reached the end of the book
          newTotalPages = nextPageIndex;
          debugPrint("[DEBUG] ReadingController: Reached end of book, setting total pages to $newTotalPages");

          if (!_layoutCompleter.isCompleted) {
            debugPrint("[DEBUG] ReadingController: Completing layout completer");
            _layoutCompleter.complete();
          }
        } else {
          // Update total pages if needed
          newTotalPages = state.totalPages > nextPageIndex ? state.totalPages : nextPageIndex + 1;
          debugPrint("[DEBUG] ReadingController: Updated total pages to $newTotalPages");
        }

        // Update the state on the next frame to avoid UI glitches
        if (mounted) {
          await Future.microtask(() {
            if (mounted) {
              debugPrint("[DEBUG] ReadingController: Updating state with new page mapping and total pages: $newTotalPages");
              state = state.copyWith(
                pageToBlockIndexMap: sortedMap, 
                totalPages: newTotalPages
              );
            }
          });
        }
      } else {
        debugPrint("[DEBUG] ReadingController: No change in page-to-block mapping, skipping update");
      }
    } catch (e, stack) {
      debugPrint("[ERROR] ReadingController: Error updating page layout: $e");
      debugPrintStack(stackTrace: stack);
    } finally {
      // Reset flag to allow future updates
      _isUpdatingPageMap = false;
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

      // If not found in the mapping, we need to estimate the page
      debugPrint("[DEBUG] ReadingController: Block not found in current page mapping, estimating page");

      // Get the last known page and its block index
      final sortedEntries = state.pageToBlockIndexMap.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));

      if (sortedEntries.isEmpty) {
        debugPrint("[WARN] ReadingController: No page mapping available");
        return 0;
      }

      final lastEntry = sortedEntries.last;
      final lastKnownPage = lastEntry.key;
      final lastKnownBlockIndex = lastEntry.value;

      debugPrint("[DEBUG] ReadingController: Last known page: $lastKnownPage, block index: $lastKnownBlockIndex");

      // If the target block is after the last known block, estimate the page
      if (targetBlockIndex >= lastKnownBlockIndex) {
        // Calculate average blocks per page based on existing mapping
        double avgBlocksPerPage = 1.0; // Default to 1 if we can't calculate

        if (sortedEntries.length > 1) {
          int totalBlocks = 0;
          for (int i = 1; i < sortedEntries.length; i++) {
            totalBlocks += sortedEntries[i].value - sortedEntries[i-1].value;
          }
          avgBlocksPerPage = totalBlocks / (sortedEntries.length - 1);
        }

        // Estimate the page number
        final blockDifference = targetBlockIndex - lastKnownBlockIndex;
        final estimatedAdditionalPages = (blockDifference / avgBlocksPerPage).ceil();
        final estimatedPage = lastKnownPage + estimatedAdditionalPages;

        debugPrint("[DEBUG] ReadingController: Estimated page for block $targetBlockIndex: $estimatedPage (avg blocks per page: $avgBlocksPerPage)");
        return estimatedPage;
      } else {
        // If the target block is before the first known block, return the first page
        final firstEntry = sortedEntries.first;
        if (targetBlockIndex < firstEntry.value) {
          debugPrint("[DEBUG] ReadingController: Block is before first known block, returning first page");
          return 0;
        }

        // Otherwise, find the closest page
        for (int i = 0; i < sortedEntries.length - 1; i++) {
          final currentEntry = sortedEntries[i];
          final nextEntry = sortedEntries[i + 1];

          if (targetBlockIndex >= currentEntry.value && targetBlockIndex < nextEntry.value) {
            debugPrint("[DEBUG] ReadingController: Block is between pages ${currentEntry.key} and ${nextEntry.key}, returning ${currentEntry.key}");
            return currentEntry.key;
          }
        }
      }

      debugPrint("[WARN] ReadingController: Could not estimate page for block $targetBlockIndex, returning first page");
      return 0;
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
  int _lastActionId = 0;
  bool _isExecuting = false;
  final List<_DebouncedAction> _pendingActions = [];

  _Debouncer({required this.milliseconds}) {
    debugPrint("[DEBUG] _Debouncer: Created with delay of $milliseconds ms");
  }

  /// Run an action after the debounce period, cancelling any pending actions
  void run(VoidCallback action) {
    _runWithId(action, ++_lastActionId);
  }

  /// Run an action with a specific ID to track it
  void _runWithId(VoidCallback action, int actionId) {
    try {
      debugPrint("[DEBUG] _Debouncer: Scheduling action #$actionId");
      _timer?.cancel();

      // Create a new action
      final debouncedAction = _DebouncedAction(
        id: actionId,
        action: action,
        timestamp: DateTime.now(),
      );

      // Add to pending actions list
      _pendingActions.add(debouncedAction);

      // Schedule execution
      _timer = Timer(Duration(milliseconds: milliseconds), () {
        _executeNextAction();
      });
    } catch (e) {
      debugPrint("[ERROR] _Debouncer: Error setting up debounced action: $e");
    }
  }

  /// Execute the next action in the queue
  Future<void> _executeNextAction() async {
    if (_isExecuting || _pendingActions.isEmpty) return;

    try {
      _isExecuting = true;

      // Get the most recent action (last in list)
      final action = _pendingActions.isNotEmpty ? _pendingActions.removeLast() : null;

      // Clear any older actions
      _pendingActions.clear();

      if (action != null) {
        final delay = DateTime.now().difference(action.timestamp).inMilliseconds;
        debugPrint("[DEBUG] _Debouncer: Executing action #${action.id} after ${delay}ms");

        // Execute the action
        action.action();
      }
    } catch (e) {
      debugPrint("[ERROR] _Debouncer: Error executing debounced action: $e");
    } finally {
      _isExecuting = false;

      // If there are more actions in the list, execute the next one
      if (_pendingActions.isNotEmpty) {
        // Small delay to prevent tight loop
        Timer(const Duration(milliseconds: 10), _executeNextAction);
      }
    }
  }

  /// Execute any pending actions immediately
  void flush() {
    if (_timer != null) {
      debugPrint("[DEBUG] _Debouncer: Flushing pending actions");
      _timer!.cancel();
      _timer = null;
      _executeNextAction();
    }
  }

  void dispose() {
    try {
      debugPrint("[DEBUG] _Debouncer: Disposing");
      if (_timer != null) {
        _timer!.cancel();
        _timer = null;
      }
      _pendingActions.clear();
    } catch (e) {
      debugPrint("[ERROR] _Debouncer: Error disposing: $e");
    }
  }
}

/// Helper class to track debounced actions
class _DebouncedAction {
  final int id;
  final VoidCallback action;
  final DateTime timestamp;

  _DebouncedAction({
    required this.id,
    required this.action,
    required this.timestamp,
  });
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
