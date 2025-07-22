import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/application/layout_cache_service.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/data/highlight.dart';
import 'package:visualit/features/reader/data/toc_entry.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';
import 'package:device_info_plus/device_info_plus.dart';

@immutable
class ReadingState {
  final int bookId;
  final Book? book; // <-- ADDED: The full book object for metadata
  final List<ContentBlock> blocks;
  final int currentPage;
  final bool isBookLoaded;
  final Map<int, int> pageToBlockIndexMap;
  final int totalPages;
  final String? currentLayoutKey; // Current layout fingerprint key
  final bool isUsingCachedLayout; // Whether the current layout is from cache

  const ReadingState({
    required this.bookId,
    this.book,
    this.blocks = const [],
    this.currentPage = 0,
    this.isBookLoaded = false,
    this.pageToBlockIndexMap = const {0: 0},
    this.totalPages = 1,
    this.currentLayoutKey,
    this.isUsingCachedLayout = false,
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
    String? currentLayoutKey,
    bool? isUsingCachedLayout,
  }) {
    return ReadingState(
      bookId: bookId,
      book: book ?? this.book,
      blocks: blocks ?? this.blocks,
      currentPage: currentPage ?? this.currentPage,
      isBookLoaded: isBookLoaded ?? this.isBookLoaded,
      pageToBlockIndexMap: pageToBlockIndexMap ?? this.pageToBlockIndexMap,
      totalPages: totalPages ?? this.totalPages,
      currentLayoutKey: currentLayoutKey ?? this.currentLayoutKey,
      isUsingCachedLayout: isUsingCachedLayout ?? this.isUsingCachedLayout,
    );
  }
}

class ReadingController extends StateNotifier<ReadingState> {
  final Isar _isar;
  final _Debouncer _debouncer = _Debouncer(milliseconds: 1000);
  final Completer<void> _layoutCompleter = Completer<void>();
  late final LayoutCacheService _layoutCacheService;
  String? _deviceId;
  ReadingPreferences? _currentPreferences;
  Size? _currentScreenSize;

  ReadingController(this._isar, int bookId) : super(ReadingState(bookId: bookId)) {
    _layoutCacheService = LayoutCacheService(_isar);
    _initialize();
    _initDeviceId();
  }

  Future<void> _initDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      // Try to get platform-specific device ID
      try {
        final androidInfo = await deviceInfo.androidInfo;
        _deviceId = androidInfo.id;
        return;
      } catch (_) {}

      try {
        final iosInfo = await deviceInfo.iosInfo;
        _deviceId = iosInfo.identifierForVendor;
        return;
      } catch (_) {}

      // For web or desktop, generate a persistent ID
      _deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      print('Error getting device ID: $e');
      _deviceId = 'unknown_device';
    }
  }

  Future<void> _initialize() async {
    // --- UPDATED: Fetch both book and blocks ---
    final book = await _isar.books.get(state.bookId);

    if (book == null) {
      if (mounted) {
        state = state.copyWith(
          isBookLoaded: true,
          blocks: [],
        );
      }
      return;
    }

    // Update lastAccessedAt timestamp for cache management
    await _isar.writeTxn(() async {
      book.lastAccessedAt = DateTime.now();
      await _isar.books.put(book);
    });

    // Load only blocks from processed chapters
    List<ContentBlock> blocks = [];
    if (book.status == ProcessingStatus.ready) {
      // If book is fully ready, load all blocks
      blocks = await _isar.contentBlocks.filter().bookIdEqualTo(state.bookId).findAll();
    } else if (book.status == ProcessingStatus.partiallyReady) {
      // If book is partially ready, load only blocks from processed chapters
      if (book.processedChapters.isNotEmpty) {
        blocks = await _isar.contentBlocks
            .filter()
            .bookIdEqualTo(state.bookId)
            .anyOf(book.processedChapters, (q, chapterIndex) => q.chapterIndexEqualTo(chapterIndex))
            .findAll();
      }

      // Start a timer to check for newly processed chapters
      _startProcessingCheckTimer();
    }

    if (mounted) {
      state = state.copyWith(
        book: book, // Save the book object to state
        blocks: blocks,
        currentPage: book.lastReadPage ?? 0,
        isBookLoaded: true,
      );
    }
  }

  Timer? _processingCheckTimer;

  void _startProcessingCheckTimer() {
    // Check every 5 seconds for newly processed chapters
    _processingCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) => _checkForNewChapters());
  }

  @override
  void dispose() {
    _processingCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkForNewChapters() async {
    if (!mounted) return;

    final book = await _isar.books.get(state.bookId);
    if (book == null) return;

    // If book is now fully ready, load all blocks
    if (book.status == ProcessingStatus.ready) {
      final allBlocks = await _isar.contentBlocks.filter().bookIdEqualTo(state.bookId).findAll();
      if (mounted) {
        state = state.copyWith(
          book: book,
          blocks: allBlocks,
        );
      }
      _processingCheckTimer?.cancel();
      return;
    }

    // If book is still partially ready, check for new processed chapters
    if (book.status == ProcessingStatus.partiallyReady) {
      // Find chapters that are processed but not loaded yet
      final currentChapters = state.blocks
          .map((block) => block.chapterIndex)
          .toSet();

      final newChapters = book.processedChapters
          .where((chapterIndex) => !currentChapters.contains(chapterIndex))
          .toList();

      if (newChapters.isNotEmpty) {
        // Load blocks from newly processed chapters
        final newBlocks = await _isar.contentBlocks
            .filter()
            .bookIdEqualTo(state.bookId)
            .anyOf(newChapters, (q, chapterIndex) => q.chapterIndexEqualTo(chapterIndex))
            .findAll();

        if (mounted && newBlocks.isNotEmpty) {
          // Combine existing blocks with new blocks and sort by chapter and block index
          final allBlocks = [...state.blocks, ...newBlocks];
          allBlocks.sort((a, b) {
            final chapterComparison = (a.chapterIndex ?? 0).compareTo(b.chapterIndex ?? 0);
            if (chapterComparison != 0) return chapterComparison;
            return (a.blockIndexInChapter ?? 0).compareTo(b.blockIndexInChapter ?? 0);
          });

          state = state.copyWith(
            book: book,
            blocks: allBlocks,
          );
        }
      }
    }
  }

  /// Set the current reading preferences and screen size
  /// This should be called whenever these values change
  void setLayoutParameters(ReadingPreferences preferences, Size screenSize) {
    _currentPreferences = preferences;
    _currentScreenSize = screenSize;

    // If we have all the necessary information, generate a new layout key
    if (_currentPreferences != null && _currentScreenSize != null) {
      final newLayoutKey = _layoutCacheService.generateLayoutKey(_currentPreferences!, _currentScreenSize!);

      // If the layout key has changed, try to load a cached layout
      if (newLayoutKey != state.currentLayoutKey) {
        _tryLoadCachedLayout(newLayoutKey);
      }
    }
  }

  /// Try to load a cached layout for the given layout key
  Future<void> _tryLoadCachedLayout(String layoutKey) async {
    if (_deviceId == null || state.blocks.isEmpty) return;

    try {
      final cachedLayout = await _layoutCacheService.getCachedPageLayout(
        bookId: state.bookId,
        deviceId: _deviceId!,
        layoutKey: layoutKey,
      );

      if (cachedLayout != null && cachedLayout.isNotEmpty) {
        print('📚 [ReadingController] Found cached layout for key: $layoutKey');

        // Calculate the current block index
        int? currentBlockIndex;
        if (state.pageToBlockIndexMap.containsKey(state.currentPage)) {
          currentBlockIndex = state.pageToBlockIndexMap[state.currentPage];
        }

        // Update the state with the cached layout
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            state = state.copyWith(
              pageToBlockIndexMap: cachedLayout,
              currentLayoutKey: layoutKey,
              isUsingCachedLayout: true,
            );

            // If we have a current block index, find the corresponding page in the new layout
            if (currentBlockIndex != null) {
              _findPageForBlockAndUpdate(currentBlockIndex);
            }
          }
        });
      } else {
        // No cached layout found, update the layout key
        if (mounted) {
          state = state.copyWith(
            currentLayoutKey: layoutKey,
            isUsingCachedLayout: false,
          );
        }
      }
    } catch (e) {
      print('Error loading cached layout: $e');
    }
  }

  /// Find the page for a given block index and update the current page
  Future<void> _findPageForBlockAndUpdate(int blockIndex) async {
    final page = await _findPageForBlock(blockIndex);
    if (page != null && mounted) {
      state = state.copyWith(currentPage: page);
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

        // Cache the layout if we have all the necessary information
        _cacheCurrentLayout(newMap, newTotalPages);
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

  /// Cache the current layout
  Future<void> _cacheCurrentLayout(Map<int, int> pageMap, int totalPages) async {
    if (_deviceId == null || _currentPreferences == null || _currentScreenSize == null) return;

    final layoutKey = state.currentLayoutKey ?? 
        _layoutCacheService.generateLayoutKey(_currentPreferences!, _currentScreenSize!);

    try {
      await _layoutCacheService.cachePageLayout(
        bookId: state.bookId,
        deviceId: _deviceId!,
        layoutKey: layoutKey,
        pageToBlockMap: pageMap,
        totalPages: totalPages,
      );

      print('📚 [ReadingController] Cached layout with key: $layoutKey');

      // Update the state to reflect that we're using a cached layout
      if (mounted) {
        state = state.copyWith(
          currentLayoutKey: layoutKey,
          isUsingCachedLayout: true,
        );
      }
    } catch (e) {
      print('Error caching layout: $e');
    }
  }

  void onPageChanged(int page) {
    if (page != state.currentPage) {
      if (mounted) state = state.copyWith(currentPage: page);
      _debouncer.run(() => _saveProgress(page));
    }
  }

  Future<void> _saveProgress(int page) async {
    await _isar.writeTxn(() async {
      final book = await _isar.books.get(state.bookId);
      if (book != null) {
        book.lastReadPage = page;
        book.lastReadTimestamp = DateTime.now();
        await _isar.books.put(book);
      }
    });
  }

  /// Finds the closest TOC entry for a given slider position (0.0 to 1.0)
  TOCEntry? findClosestTOCEntry(double sliderPosition) {
    if (state.book == null || state.book!.toc.isEmpty) return null;

    // Convert slider position to page index
    final targetPage = (sliderPosition * (state.totalPages - 1)).round();

    // Get the block index for this page
    final blockIndex = state.pageToBlockIndexMap[targetPage];
    if (blockIndex == null) return null;

    // Find the TOC entry with the closest blockIndexStart
    TOCEntry? closestEntry;
    int? closestDistance;

    // Helper function to process TOC entries recursively
    void processTOCEntry(TOCEntry entry) {
      if (entry.blockIndexStart != null) {
        final distance = (entry.blockIndexStart! - blockIndex).abs();
        if (closestDistance == null || distance < closestDistance!) {
          closestDistance = distance;
          closestEntry = entry;
        }
      }

      // Process children
      for (final child in entry.children) {
        processTOCEntry(child);
      }
    }

    // Process all TOC entries
    for (final entry in state.book!.toc) {
      processTOCEntry(entry);
    }

    return closestEntry;
  }

  /// Gets the chapter name for a given slider position
  String? getChapterNameForPosition(double sliderPosition) {
    final entry = findClosestTOCEntry(sliderPosition);
    return entry?.title;
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
    // If blockIndexStart is available, use it for precise navigation
    if (entry.blockIndexStart != null) {
      final targetBlockIndex = entry.blockIndexStart!;
      if (targetBlockIndex >= 0 && targetBlockIndex < state.blocks.length) {
        final targetPage = await _findPageForBlock(targetBlockIndex);
        if (targetPage != null && mounted) {
          state = state.copyWith(currentPage: targetPage);
        }
        return;
      }
    }

    // Fall back to src-based navigation if blockIndexStart is not available
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

final readingControllerProvider =
StateNotifierProvider.family.autoDispose<ReadingController, ReadingState, int>((ref, bookId) {
  final isar = ref.watch(isarDBProvider).value!;
  return ReadingController(isar, bookId);
});
