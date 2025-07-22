import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/application/background_layout_calculator.dart';
import 'package:visualit/features/reader/application/layout_cache_service.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/data/highlight.dart';
import 'package:visualit/features/reader/data/toc_entry.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';
import 'package:device_info_plus/device_info_plus.dart';

@immutable
class ReadingState {
  final int bookId;
  final Book? book; // <-- The full book object for metadata
  final List<ContentBlock> blocks;
  final int currentPage;
  final bool isBookLoaded;
  final Map<int, int> pageToBlockIndexMap;
  final int totalPages;
  final String? currentLayoutKey; // Current layout fingerprint key
  final bool isUsingCachedLayout; // Whether the current layout is from cache
  final int? currentChapterIndex; // Current chapter being displayed
  final bool isLoadingChapter; // Whether a chapter is currently being loaded
  final bool isCalculatingLayout; // Whether layout is being calculated in background
  final double layoutCalculationProgress; // Progress of layout calculation (0.0 to 1.0)
  final Set<int> loadedChapterIndices; // Set of chapter indices that have been loaded

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
    this.currentChapterIndex,
    this.isLoadingChapter = false,
    this.isCalculatingLayout = false,
    this.layoutCalculationProgress = 0.0,
    this.loadedChapterIndices = const {},
  });

  // --- HELPER GETTER for chapter progress ---
  String get chapterProgress {
    if (blocks.isEmpty || pageToBlockIndexMap[currentPage] == null) {
      return "Loading chapter...";
    }
    final currentBlockIndex = pageToBlockIndexMap[currentPage]!;
    final currentChapterIndex = blocks[currentBlockIndex].chapterIndex;

    // If chapterIndex is null, return a default message
    if (currentChapterIndex == null) {
      return "Chapter information unavailable";
    }

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
    int? currentChapterIndex,
    bool? isLoadingChapter,
    bool? isCalculatingLayout,
    double? layoutCalculationProgress,
    Set<int>? loadedChapterIndices,
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
      currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
      isLoadingChapter: isLoadingChapter ?? this.isLoadingChapter,
      isCalculatingLayout: isCalculatingLayout ?? this.isCalculatingLayout,
      layoutCalculationProgress: layoutCalculationProgress ?? this.layoutCalculationProgress,
      loadedChapterIndices: loadedChapterIndices ?? this.loadedChapterIndices,
    );
  }
}

class ReadingController extends StateNotifier<ReadingState> {
  final Isar _isar;
  final _Debouncer _debouncer = _Debouncer(milliseconds: 1000);
  final Completer<void> _layoutCompleter = Completer<void>();
  late final LayoutCacheService _layoutCacheService;
  late final BackgroundLayoutCalculator _backgroundLayoutCalculator;
  String? _deviceId;
  ReadingPreferences? _currentPreferences;
  Size? _currentScreenSize;

  ReadingController(this._isar, int bookId) : super(ReadingState(bookId: bookId)) {
    _layoutCacheService = LayoutCacheService(_isar);
    _backgroundLayoutCalculator = BackgroundLayoutCalculator(_layoutCacheService);
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
    // Fetch only book metadata initially, not blocks
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

    // Initialize with empty blocks - we'll load them by chapter as needed
    if (mounted) {
      state = state.copyWith(
        book: book, // Save the book object to state
        blocks: [],
        currentPage: book.lastReadPage ?? 0,
        isBookLoaded: true,
        loadedChapterIndices: {}, // Initialize with empty set
      );
    }

    // Start a timer to check for newly processed chapters if book is still processing
    if (book.status == ProcessingStatus.partiallyReady) {
      _startProcessingCheckTimer();
    }

    // Determine which chapter to load initially based on last read page
    // We'll need to load the first chapter or the chapter containing the last read page
    await _loadInitialChapter(book);
  }

  /// Loads the initial chapter based on the last read page or the first chapter
  Future<void> _loadInitialChapter(Book book) async {
    // If we have a last read page, try to determine which chapter it belongs to
    int initialChapterIndex = 0;

    if (book.toc.isNotEmpty) {
      // Default to the first chapter
      initialChapterIndex = book.toc.first.chapterIndex ?? 0;

      // If the book has a last read page, try to find which chapter it belongs to
      if (book.lastReadPage > 0) {
        try {
          // Query the database to find the block at the last read position
          final chapterIndex = await _findChapterForPage(book.id, book.lastReadPage);
          if (chapterIndex != null) {
            initialChapterIndex = chapterIndex;
          }
        } catch (e) {
          print('Error finding chapter for last read page: $e');
          // Fall back to the first chapter if there's an error
        }
      }
    }

    // Load the initial chapter
    await loadChapter(initialChapterIndex);
  }

  /// Loads blocks for a specific chapter
  Future<void> loadChapter(int chapterIndex) async {
    if (!mounted) return;

    // Check if this chapter is already loaded
    if (state.loadedChapterIndices.contains(chapterIndex)) {
      // Chapter already loaded, just update current chapter index
      if (mounted) {
        state = state.copyWith(
          currentChapterIndex: chapterIndex,
        );
      }
      return;
    }

    // Set loading state
    if (mounted) {
      state = state.copyWith(
        isLoadingChapter: true,
        currentChapterIndex: chapterIndex,
      );
    }

    try {
      // Load blocks for this chapter
      final chapterBlocks = await _isar.contentBlocks
          .filter()
          .bookIdEqualTo(state.bookId)
          .chapterIndexEqualTo(chapterIndex)
          .sortByBlockIndexInChapter()
          .findAll();

      if (!mounted) return;

      // Combine with existing blocks and sort
      final allBlocks = [...state.blocks, ...chapterBlocks];
      allBlocks.sort((a, b) {
        final chapterComparison = (a.chapterIndex ?? 0).compareTo(b.chapterIndex ?? 0);
        if (chapterComparison != 0) return chapterComparison;
        return (a.blockIndexInChapter ?? 0).compareTo(b.blockIndexInChapter ?? 0);
      });

      // Update loaded chapters set
      final updatedLoadedChapters = Set<int>.from(state.loadedChapterIndices);
      updatedLoadedChapters.add(chapterIndex);

      // Update state with new blocks and chapter info
      if (mounted) {
        state = state.copyWith(
          blocks: allBlocks,
          isLoadingChapter: false,
          loadedChapterIndices: updatedLoadedChapters,
        );
      }

      // Calculate layouts in the background
      _calculateLayoutsInBackground(chapterIndex);

      // Start pre-fetching the next chapter
      _prefetchNextChapter(chapterIndex);
    } catch (e) {
      print('Error loading chapter $chapterIndex: $e');
      if (mounted) {
        state = state.copyWith(
          isLoadingChapter: false,
        );
      }
    }
  }

  /// Finds the chapter index for a given page number
  /// This is used to determine which chapter to load when resuming reading
  Future<int?> _findChapterForPage(int bookId, int pageNumber) async {
    try {
      // First, try to find the layout cache for this book
      final layoutKey = await _layoutCacheService.getLatestLayoutKey(bookId);
      if (layoutKey != null) {
        // If we have a cached layout, load it
        final cachedLayout = await _layoutCacheService.getLayout(layoutKey);
        if (cachedLayout != null && cachedLayout.isNotEmpty) {
          // Find the closest page in the cached layout
          int? closestPage;
          int minDistance = 1000000; // Large number

          for (final page in cachedLayout.keys) {
            final distance = (page - pageNumber).abs();
            if (distance < minDistance) {
              minDistance = distance;
              closestPage = page;
            }
          }

          if (closestPage != null) {
            // Get the block index for this page
            final blockIndex = cachedLayout[closestPage];
            if (blockIndex != null) {
              // Query the database to find the chapter for this block
              final block = await _isar.contentBlocks
                  .filter()
                  .bookIdEqualTo(bookId)
                  .idEqualTo(blockIndex)
                  .findFirst();

              if (block != null && block.chapterIndex != null) {
                return block.chapterIndex;
              }
            }
          }
        }
      }

      // If we couldn't find the chapter using the layout cache,
      // query the database directly to find blocks for this book
      // and estimate which chapter contains the given page

      // Get all chapters for this book
      final chapters = await _isar.contentBlocks
          .filter()
          .bookIdEqualTo(bookId)
          .findAll();

      // Group blocks by chapter
      final chapterBlocks = <int, List<ContentBlock>>{};
      for (final block in chapters) {
        if (block.chapterIndex != null) {
          chapterBlocks.putIfAbsent(block.chapterIndex!, () => []).add(block);
        }
      }

      // Estimate which chapter contains the given page based on block count
      // This is a rough estimate assuming pages are distributed proportionally to blocks
      if (chapterBlocks.isNotEmpty) {
        final totalBlocks = chapters.length;
        final estimatedBlockIndex = (pageNumber / totalBlocks * pageNumber).round();

        // Find which chapter contains this estimated block
        for (final entry in chapterBlocks.entries) {
          final chapterIndex = entry.key;
          final blocks = entry.value;

          if (blocks.any((block) => block.blockIndexInChapter != null && 
              block.blockIndexInChapter! >= estimatedBlockIndex)) {
            return chapterIndex;
          }
        }

        // If we couldn't find a matching chapter, return the last one
        return chapterBlocks.keys.reduce((a, b) => a > b ? a : b);
      }

      // If all else fails, return null and let the caller use the default
      return null;
    } catch (e) {
      print('Error in _findChapterForPage: $e');
      return null;
    }
  }

  /// Pre-fetches the next chapter in the background
  Future<void> _prefetchNextChapter(int currentChapterIndex) async {
    if (!mounted || state.book == null) return;

    // Find the next chapter index
    int? nextChapterIndex;

    // If we have TOC entries, use them to find the next chapter
    if (state.book!.toc.isNotEmpty) {
      // Find the current chapter in TOC
      int currentTocIndex = -1;
      for (int i = 0; i < state.book!.toc.length; i++) {
        if (state.book!.toc[i].chapterIndex == currentChapterIndex) {
          currentTocIndex = i;
          break;
        }
      }

      // If found and there's a next chapter, get its index
      if (currentTocIndex >= 0 && currentTocIndex < state.book!.toc.length - 1) {
        nextChapterIndex = state.book!.toc[currentTocIndex + 1].chapterIndex;
      }
    } else {
      // If no TOC, just increment the chapter index
      nextChapterIndex = currentChapterIndex + 1;
    }

    // If we found a next chapter and it's not already loaded, pre-fetch it
    if (nextChapterIndex != null && 
        !state.loadedChapterIndices.contains(nextChapterIndex) &&
        !state.isLoadingChapter) {

      // Check if the next chapter exists by querying for any blocks with that chapter index
      final hasNextChapter = await _isar.contentBlocks
          .filter()
          .bookIdEqualTo(state.bookId)
          .chapterIndexEqualTo(nextChapterIndex)
          .limit(1)
          .count() > 0;

      if (hasNextChapter) {
        print('Pre-fetching next chapter: $nextChapterIndex');

        // Load the blocks for the next chapter in the background
        final nextChapterBlocks = await _isar.contentBlocks
            .filter()
            .bookIdEqualTo(state.bookId)
            .chapterIndexEqualTo(nextChapterIndex)
            .sortByBlockIndexInChapter()
            .findAll();

        if (!mounted) return;

        // Only update state if we're still on the same chapter
        // This prevents overwriting if the user has already navigated elsewhere
        if (state.currentChapterIndex == currentChapterIndex) {
          // Combine with existing blocks and sort
          final allBlocks = [...state.blocks, ...nextChapterBlocks];
          allBlocks.sort((a, b) {
            final chapterComparison = (a.chapterIndex ?? 0).compareTo(b.chapterIndex ?? 0);
            if (chapterComparison != 0) return chapterComparison;
            return (a.blockIndexInChapter ?? 0).compareTo(b.blockIndexInChapter ?? 0);
          });

          // Update loaded chapters set
          final updatedLoadedChapters = Set<int>.from(state.loadedChapterIndices);
          updatedLoadedChapters.add(nextChapterIndex);

          // Update state with new blocks and chapter info
          if (mounted) {
            state = state.copyWith(
              blocks: allBlocks,
              loadedChapterIndices: updatedLoadedChapters,
            );
          }

          print('Pre-fetched next chapter: $nextChapterIndex');
        }
      }
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

    // Update book metadata regardless of status
    if (mounted) {
      state = state.copyWith(
        book: book,
      );
    }

    // If book is now fully ready, we can stop checking
    if (book.status == ProcessingStatus.ready) {
      _processingCheckTimer?.cancel();

      // If we're currently viewing a chapter, make sure it's fully loaded
      if (state.currentChapterIndex != null) {
        // Check if there are any new blocks for the current chapter
        await _refreshCurrentChapter();
      }
      return;
    }

    // If book is still partially ready, check for new processed chapters
    if (book.status == ProcessingStatus.partiallyReady) {
      // If we're currently viewing a chapter, check if it has new blocks
      if (state.currentChapterIndex != null) {
        await _refreshCurrentChapter();
      }

      // Pre-fetch any newly processed chapters that are adjacent to current chapter
      if (state.currentChapterIndex != null) {
        final currentIndex = state.currentChapterIndex!;

        // Check if next chapter is newly processed
        if (book.processedChapters.contains(currentIndex + 1) && 
            !state.loadedChapterIndices.contains(currentIndex + 1)) {
          _prefetchNextChapter(currentIndex);
        }

        // Check if previous chapter is newly processed
        if (currentIndex > 0 && 
            book.processedChapters.contains(currentIndex - 1) && 
            !state.loadedChapterIndices.contains(currentIndex - 1)) {
          // Load previous chapter
          final prevChapterBlocks = await _isar.contentBlocks
              .filter()
              .bookIdEqualTo(state.bookId)
              .chapterIndexEqualTo(currentIndex - 1)
              .sortByBlockIndexInChapter()
              .findAll();

          if (mounted && prevChapterBlocks.isNotEmpty) {
            // Combine with existing blocks and sort
            final allBlocks = [...state.blocks, ...prevChapterBlocks];
            allBlocks.sort((a, b) {
              final chapterComparison = (a.chapterIndex ?? 0).compareTo(b.chapterIndex ?? 0);
              if (chapterComparison != 0) return chapterComparison;
              return (a.blockIndexInChapter ?? 0).compareTo(b.blockIndexInChapter ?? 0);
            });

            // Update loaded chapters set
            final updatedLoadedChapters = Set<int>.from(state.loadedChapterIndices);
            updatedLoadedChapters.add(currentIndex - 1);

            if (mounted) {
              state = state.copyWith(
                blocks: allBlocks,
                loadedChapterIndices: updatedLoadedChapters,
              );
            }
          }
        }
      }
    }
  }

  /// Refreshes the current chapter by loading any new blocks
  Future<void> _refreshCurrentChapter() async {
    if (!mounted || state.currentChapterIndex == null) return;

    final currentChapterIndex = state.currentChapterIndex!;

    // Get all blocks for the current chapter
    final currentChapterBlocks = await _isar.contentBlocks
        .filter()
        .bookIdEqualTo(state.bookId)
        .chapterIndexEqualTo(currentChapterIndex)
        .sortByBlockIndexInChapter()
        .findAll();

    if (!mounted) return;

    // Find blocks that are already loaded
    final existingBlockIds = state.blocks
        .where((block) => block.chapterIndex == currentChapterIndex)
        .map((block) => block.id)
        .toSet();

    // Filter out new blocks
    final newBlocks = currentChapterBlocks
        .where((block) => !existingBlockIds.contains(block.id))
        .toList();

    if (newBlocks.isNotEmpty) {
      // Combine with existing blocks and sort
      final allBlocks = [...state.blocks, ...newBlocks];
      allBlocks.sort((a, b) {
        final chapterComparison = (a.chapterIndex ?? 0).compareTo(b.chapterIndex ?? 0);
        if (chapterComparison != 0) return chapterComparison;
        return (a.blockIndexInChapter ?? 0).compareTo(b.blockIndexInChapter ?? 0);
      });

      if (mounted) {
        state = state.copyWith(
          blocks: allBlocks,
        );
      }
    }
  }

  /// Calculates page layouts in the background for the current chapter
  Future<void> _calculateLayoutsInBackground(int chapterIndex) async {
    if (!mounted || _deviceId == null || _currentPreferences == null || _currentScreenSize == null) return;

    // Only calculate layouts for blocks in the current chapter
    final chapterBlocks = state.blocks.where((b) => b.chapterIndex == chapterIndex).toList();
    if (chapterBlocks.isEmpty) return;

    // Update state to indicate layout calculation is in progress
    if (mounted) {
      state = state.copyWith(
        isCalculatingLayout: true,
        layoutCalculationProgress: 0.0,
      );
    }

    try {
      // Calculate layouts in the background
      final pageToBlockMap = await _backgroundLayoutCalculator.calculateLayoutsInBackground(
        bookId: state.bookId,
        deviceId: _deviceId!,
        blocks: state.blocks, // Pass all blocks to ensure correct indexing
        preferences: _currentPreferences!,
        screenSize: _currentScreenSize!,
        onProgress: (progress) {
          if (mounted) {
            state = state.copyWith(
              layoutCalculationProgress: progress,
            );
          }
        },
      );

      // Update state with calculated layouts
      if (mounted) {
        final totalPages = pageToBlockMap.keys.isNotEmpty ? pageToBlockMap.keys.reduce((a, b) => a > b ? a : b) + 1 : 1;

        state = state.copyWith(
          pageToBlockIndexMap: pageToBlockMap,
          totalPages: totalPages,
          isCalculatingLayout: false,
          layoutCalculationProgress: 1.0,
          isUsingCachedLayout: true,
          currentLayoutKey: _layoutCacheService.generateLayoutKey(_currentPreferences!, _currentScreenSize!),
        );

        print('📚 [ReadingController] Layout calculation complete. Total pages: $totalPages');
      }
    } catch (e) {
      print('Error calculating layouts: $e');
      if (mounted) {
        state = state.copyWith(
          isCalculatingLayout: false,
        );
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

      // Check if we need to load a new chapter
      _checkAndLoadChapterForPage(page);

      // Check for prefetching based on current page position
      checkForPrefetching(page);

      // Manage memory by unloading distant chapters
      _manageLoadedChapters();
    }
  }

  /// Checks if the current page is in a new chapter and loads it if needed
  Future<void> _checkAndLoadChapterForPage(int page) async {
    if (!mounted || state.blocks.isEmpty) return;

    // Get the block index for this page
    final blockIndex = state.pageToBlockIndexMap[page];
    if (blockIndex == null || blockIndex >= state.blocks.length) return;

    // Get the chapter index for this block
    final chapterIndex = state.blocks[blockIndex].chapterIndex;
    if (chapterIndex == null) return;

    // If this is a different chapter than the current one, load it
    if (chapterIndex != state.currentChapterIndex) {
      await loadChapter(chapterIndex);
    }

    // Check if we're near the end of the chapter and should pre-fetch the next one
    _checkIfNearChapterEnd(page, chapterIndex);
  }

  /// Checks if the user is near the end of a chapter and pre-fetches the next one
  void _checkIfNearChapterEnd(int page, int chapterIndex) {
    if (!mounted || state.book == null) return;

    // Find the last page in this chapter
    int? lastPageInChapter;
    int? firstPageInNextChapter;

    // Find the last block with this chapter index
    final lastBlockIndex = state.blocks.lastIndexWhere((block) => block.chapterIndex == chapterIndex);
    if (lastBlockIndex == -1) return;

    // Find the page containing this block
    for (final entry in state.pageToBlockIndexMap.entries) {
      if (entry.value > lastBlockIndex) {
        firstPageInNextChapter = entry.key;
        break;
      }
      lastPageInChapter = entry.key;
    }

    if (lastPageInChapter == null) return;

    // If we're within 3 pages of the end of the chapter, pre-fetch the next chapter
    final pagesRemaining = lastPageInChapter - page;
    if (pagesRemaining <= 3) {
      _prefetchNextChapter(chapterIndex);
    }
  }

  /// Manages loaded chapters to conserve memory
  /// Unloads chapters that are far from the current reading position
  /// Uses an adaptive approach based on chapter size and reading position
  void _manageLoadedChapters() {
    // Get the current chapter and page
    final currentChapter = state.currentChapterIndex ?? 0;
    final currentPage = state.currentPage;

    // Determine how many chapters to keep in memory based on their size
    // For small chapters (less than 10 blocks), keep more chapters in memory
    int chaptersToKeep = 5; // Default to 5 chapters instead of 3

    // Check if we have enough information to determine chapter sizes
    if (state.blocks.isNotEmpty) {
      // Count blocks per chapter to determine chapter sizes
      final blocksPerChapter = <int, int>{};
      for (final block in state.blocks) {
        if (block.chapterIndex != null) {
          blocksPerChapter[block.chapterIndex!] = 
              (blocksPerChapter[block.chapterIndex!] ?? 0) + 1;
        }
      }

      // If the current chapter is small, keep more chapters in memory
      final currentChapterSize = blocksPerChapter[currentChapter] ?? 0;
      if (currentChapterSize < 10) {
        chaptersToKeep = 7; // Keep even more chapters for very small chapters
      } else if (currentChapterSize < 20) {
        chaptersToKeep = 6; // Keep more chapters for small chapters
      }

      // If we're near a chapter boundary, keep an extra chapter
      // Check if we're within 2 pages of the start or end of the current chapter
      bool nearChapterBoundary = false;

      // Find the first and last page of the current chapter
      int? firstPageInChapter;
      int? lastPageInChapter;

      // Find the first and last block with this chapter index
      final firstBlockIndex = state.blocks.indexWhere((block) => block.chapterIndex == currentChapter);
      final lastBlockIndex = state.blocks.lastIndexWhere((block) => block.chapterIndex == currentChapter);

      if (firstBlockIndex != -1 && lastBlockIndex != -1) {
        // Find the pages containing these blocks
        for (final entry in state.pageToBlockIndexMap.entries) {
          if (entry.value >= firstBlockIndex && firstPageInChapter == null) {
            firstPageInChapter = entry.key;
          }
          if (entry.value <= lastBlockIndex) {
            lastPageInChapter = entry.key;
          }
        }

        // Check if we're near a chapter boundary
        if (firstPageInChapter != null && lastPageInChapter != null) {
          final pagesFromStart = (currentPage - firstPageInChapter).abs();
          final pagesFromEnd = (lastPageInChapter - currentPage).abs();

          if (pagesFromStart <= 2 || pagesFromEnd <= 2) {
            nearChapterBoundary = true;
            chaptersToKeep += 1; // Keep one more chapter if near a boundary
          }
        }
      }
    }

    // Only unload chapters if we have more than the target number
    if (state.loadedChapterIndices.length > chaptersToKeep) {
      // Create a list of chapters with their distance from current chapter
      final chapterDistances = state.loadedChapterIndices
          .map((idx) => MapEntry(idx, (idx - currentChapter).abs()))
          .toList();

      // Sort by distance
      chapterDistances.sort((a, b) => a.value.compareTo(b.value));

      // Take the 3 closest chapters
      final chaptersToKeep = chapterDistances
          .take(3)
          .map((e) => e.key)
          .toSet();

      // Filter blocks to keep only those from chapters we want to keep
      final keptBlocks = state.blocks.where((block) => 
          chaptersToKeep.contains(block.chapterIndex)).toList();

      // Update state
      state = state.copyWith(
        blocks: keptBlocks,
        loadedChapterIndices: chaptersToKeep,
      );
    }
  }

  /// Checks if the user is nearing the end of the current chapter and starts loading the next chapter
  void checkForPrefetching(int currentPage) {
    if (!mounted || state.currentChapterIndex == null) return;

    // Get the current chapter's page range
    final currentChapterIndex = state.currentChapterIndex!;
    int? chapterStartPage;
    int? chapterEndPage;

    // Find chapter start page
    for (final entry in state.pageToBlockIndexMap.entries) {
      final blockIndex = entry.value;
      if (blockIndex < state.blocks.length && 
          state.blocks[blockIndex].chapterIndex == currentChapterIndex) {
        chapterStartPage = entry.key;
        break;
      }
    }

    // Find chapter end page
    for (final entry in state.pageToBlockIndexMap.entries.toList().reversed) {
      final blockIndex = entry.value;
      if (blockIndex < state.blocks.length && 
          state.blocks[blockIndex].chapterIndex == currentChapterIndex) {
        chapterEndPage = entry.key;
        break;
      }
    }

    // If we're in the last 20% of the chapter, prefetch the next chapter
    if (chapterStartPage != null && chapterEndPage != null) {
      final chapterLength = chapterEndPage - chapterStartPage;
      final threshold = chapterStartPage + (chapterLength * 0.8).round();

      if (currentPage >= threshold) {
        _prefetchNextChapter(currentChapterIndex);
      }
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
    // First, ensure the chapter is loaded
    if (entry.chapterIndex != null) {
      await loadChapter(entry.chapterIndex!);
    }

    // If blockIndexStart is available, use it for precise navigation
    if (entry.blockIndexStart != null) {
      final targetBlockIndex = entry.blockIndexStart!;

      // Check if we need to load more blocks to find this index
      if (targetBlockIndex >= state.blocks.length) {
        // We might need to load more chapters to find this block
        // For now, just try to load the chapter that should contain this block
        if (entry.chapterIndex != null) {
          await loadChapter(entry.chapterIndex!);
        }
      }

      if (targetBlockIndex >= 0 && targetBlockIndex < state.blocks.length) {
        final targetPage = await _findPageForBlock(targetBlockIndex);
        if (targetPage != null && mounted) {
          state = state.copyWith(currentPage: targetPage);

          // Also check if we need to load a new chapter based on this page
          _checkAndLoadChapterForPage(targetPage);
        }
        return;
      }
    }

    // Fall back to src-based navigation if blockIndexStart is not available
    if (entry.src == null) return;

    // First check if we need to load the chapter that contains this src
    if (entry.chapterIndex != null && !state.loadedChapterIndices.contains(entry.chapterIndex)) {
      await loadChapter(entry.chapterIndex!);
    }

    // Now try to find the block with this src
    final targetBlockIndex = state.blocks.indexWhere((b) => b.src == entry.src);
    if (targetBlockIndex != -1) {
      final targetPage = await _findPageForBlock(targetBlockIndex);
      if (targetPage != null && mounted) {
        state = state.copyWith(currentPage: targetPage);

        // Also check if we need to load a new chapter based on this page
        _checkAndLoadChapterForPage(targetPage);
      }
    } else {
      // If we still can't find the block, we might need to query the database directly
      final blocks = await _isar.contentBlocks
          .filter()
          .bookIdEqualTo(state.bookId)
          .srcEqualTo(entry.src)
          .findAll();

      if (blocks.isNotEmpty && blocks.first.chapterIndex != null) {
        // Load the chapter that contains this block
        await loadChapter(blocks.first.chapterIndex!);

        // Try again to find the block
        final targetBlockIndex = state.blocks.indexWhere((b) => b.src == entry.src);
        if (targetBlockIndex != -1) {
          final targetPage = await _findPageForBlock(targetBlockIndex);
          if (targetPage != null && mounted) {
            state = state.copyWith(currentPage: targetPage);

            // Also check if we need to load a new chapter based on this page
            _checkAndLoadChapterForPage(targetPage);
          }
        }
      }
    }
  }

  Future<void> jumpToHref(String href, String currentBlockSrc) async {
    final resolvedPath = p.normalize(p.join(p.dirname(currentBlockSrc), href));
    final parts = resolvedPath.split('#');
    final src = parts.isNotEmpty ? parts[0] : null;
    if (src != null) {
      // First try to find the chapter that contains this src
      final blocks = await _isar.contentBlocks
          .filter()
          .bookIdEqualTo(state.bookId)
          .srcEqualTo(src)
          .findAll();

      if (blocks.isNotEmpty && blocks.first.chapterIndex != null) {
        // Create a TOC entry with both src and chapterIndex for more efficient navigation
        final entry = TOCEntry()
          ..src = src
          ..title = 'Internal Link'
          ..chapterIndex = blocks.first.chapterIndex;

        await jumpToLocation(entry);
      } else {
        // Fall back to src-only navigation if we can't determine the chapter
        await jumpToLocation(TOCEntry()..src = src..title = 'Internal Link');
      }
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
