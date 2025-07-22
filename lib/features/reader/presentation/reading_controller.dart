import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:visualit/core/models/content_block_schema.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/core/providers/font_providers.dart';
import 'package:visualit/features/reader/data/layout_cache_service.dart';
import 'package:visualit/features/reader/data/reading_providers.dart';

/// The state of the reading controller
enum ReadingState {
  /// Initial state
  initial,
  
  /// Loading content blocks
  loading,
  
  /// Formatting the book (paginating)
  formatting,
  
  /// Ready to display content
  ready,
  
  /// Error state
  error,
}

/// Provider for the ReadingController
final readingControllerProvider = StateNotifierProvider.family<ReadingController, ReadingState, int>(
  (ref, bookId) => ReadingController(
    ref: ref,
    bookId: bookId,
  ),
);

/// Controller for the reading experience
class ReadingController extends StateNotifier<ReadingState> {
  final Ref _ref;
  final int _bookId;
  
  /// The current page index
  int _currentPageIndex = 0;
  
  /// The layout key for the current book and settings
  late String _layoutKey;
  
  /// The page map for the current book
  /// Maps page index to a list of block indices [startBlockIndex, endBlockIndex]
  Map<int, List<int>>? _pageMap;
  
  /// The content blocks for the current chapter
  List<ContentBlockSchema> _loadedBlocks = [];
  
  /// The index of the current chapter
  int _currentChapterIndex = 0;
  
  /// The total number of pages
  int _totalPages = 0;
  
  /// Flag to indicate if the next chapter is being pre-fetched
  bool _isPreFetchingNextChapter = false;
  
  /// Constructor
  ReadingController({
    required Ref ref,
    required int bookId,
  }) : _ref = ref,
       _bookId = bookId,
       super(ReadingState.initial) {
    _initialize();
  }
  
  /// Initialize the controller
  Future<void> _initialize() async {
    state = ReadingState.loading;
    
    try {
      // Generate the layout key
      final deviceSize = MediaQueryData.fromView(WidgetsBinding.instance.window).size;
      final fontSettings = _ref.read(fontSettingsProvider);
      
      _layoutKey = LayoutCacheService.generateLayoutKey(
        bookId: _bookId,
        deviceDimensions: deviceSize,
        fontSettings: fontSettings,
      );
      
      // Check if we have a cached layout
      final cacheService = _ref.read(layoutCacheServiceProvider);
      _pageMap = await cacheService.getPageMap(layoutKey: _layoutKey);
      
      if (_pageMap != null) {
        // Cache hit - we can render immediately
        _totalPages = _pageMap!.length;
        
        // Load the first chapter's content blocks
        await _loadChapterBlocks(_currentChapterIndex);
        
        state = ReadingState.ready;
      } else {
        // Cache miss - we need to load content and paginate
        await _loadChapterBlocks(_currentChapterIndex);
        
        state = ReadingState.formatting;
        
        // Paginate the loaded blocks
        await _paginateContent();
        
        state = ReadingState.ready;
      }
    } catch (e) {
      print('ReadingController: Error initializing: $e');
      state = ReadingState.error;
    }
  }
  
  /// Load content blocks for a specific chapter
  Future<void> _loadChapterBlocks(int chapterIndex) async {
    try {
      final isar = await _ref.read(isarProvider).db;
      
      // Query for content blocks in the specified chapter
      _loadedBlocks = await isar.contentBlockSchemas
          .filter()
          .bookIdEqualTo(_bookId)
          .chapterIndexEqualTo(chapterIndex)
          .sortByBlockIndexInChapter()
          .findAll();
      
      _currentChapterIndex = chapterIndex;
      
      print('ReadingController: Loaded ${_loadedBlocks.length} blocks for chapter $chapterIndex');
    } catch (e) {
      print('ReadingController: Error loading chapter blocks: $e');
      rethrow;
    }
  }
  
  /// Paginate the loaded content
  Future<void> _paginateContent() async {
    try {
      // This would normally be a complex process that measures text and determines
      // how many blocks fit on each page based on the device dimensions and font settings.
      // For simplicity, we'll use a fixed number of blocks per page.
      const int blocksPerPage = 5;
      
      final newPageMap = <int, List<int>>{};
      int pageIndex = 0;
      
      for (int i = 0; i < _loadedBlocks.length; i += blocksPerPage) {
        final endIndex = (i + blocksPerPage - 1).clamp(0, _loadedBlocks.length - 1);
        newPageMap[pageIndex] = [i, endIndex];
        pageIndex++;
      }
      
      _pageMap = newPageMap;
      _totalPages = newPageMap.length;
      
      // Save the page map to the cache
      final cacheService = _ref.read(layoutCacheServiceProvider);
      await cacheService.savePageMap(
        layoutKey: _layoutKey,
        pageMap: newPageMap,
      );
      
      print('ReadingController: Paginated content into $_totalPages pages');
    } catch (e) {
      print('ReadingController: Error paginating content: $e');
      rethrow;
    }
  }
  
  /// Get the content blocks for the current page
  List<ContentBlockSchema> getCurrentPageBlocks() {
    if (_pageMap == null || _currentPageIndex >= _totalPages) {
      return [];
    }
    
    final blockIndices = _pageMap![_currentPageIndex];
    if (blockIndices == null || blockIndices.length != 2) {
      return [];
    }
    
    final startIndex = blockIndices[0];
    final endIndex = blockIndices[1];
    
    // Check if we need to pre-fetch the next chapter
    _checkAndPreFetchNextChapter();
    
    return _loadedBlocks.sublist(
      startIndex,
      endIndex + 1, // +1 because sublist end is exclusive
    );
  }
  
  /// Check if we need to pre-fetch the next chapter
  void _checkAndPreFetchNextChapter() {
    if (_isPreFetchingNextChapter) {
      return;
    }
    
    // If we're at 80% of the current chapter, pre-fetch the next chapter
    final currentProgress = _currentPageIndex / _totalPages;
    if (currentProgress >= 0.8) {
      _isPreFetchingNextChapter = true;
      
      // Pre-fetch the next chapter
      _preFetchNextChapter();
    }
  }
  
  /// Pre-fetch the next chapter
  Future<void> _preFetchNextChapter() async {
    try {
      final nextChapterIndex = _currentChapterIndex + 1;
      
      final isar = await _ref.read(isarProvider).db;
      
      // Check if the next chapter exists
      final nextChapterBlocks = await isar.contentBlockSchemas
          .filter()
          .bookIdEqualTo(_bookId)
          .chapterIndexEqualTo(nextChapterIndex)
          .sortByBlockIndexInChapter()
          .findAll();
      
      if (nextChapterBlocks.isNotEmpty) {
        // Append the next chapter's blocks to the loaded blocks
        _loadedBlocks.addAll(nextChapterBlocks);
        
        // Re-paginate the content
        await _paginateContent();
        
        print('ReadingController: Pre-fetched next chapter with ${nextChapterBlocks.length} blocks');
      }
      
      _isPreFetchingNextChapter = false;
    } catch (e) {
      print('ReadingController: Error pre-fetching next chapter: $e');
      _isPreFetchingNextChapter = false;
    }
  }
  
  /// Navigate to the next page
  bool goToNextPage() {
    if (_currentPageIndex < _totalPages - 1) {
      _currentPageIndex++;
      return true;
    }
    return false;
  }
  
  /// Navigate to the previous page
  bool goToPreviousPage() {
    if (_currentPageIndex > 0) {
      _currentPageIndex--;
      return true;
    }
    return false;
  }
  
  /// Navigate to a specific page
  bool goToPage(int pageIndex) {
    if (pageIndex >= 0 && pageIndex < _totalPages) {
      _currentPageIndex = pageIndex;
      return true;
    }
    return false;
  }
  
  /// Get the current page index
  int getCurrentPageIndex() {
    return _currentPageIndex;
  }
  
  /// Get the total number of pages
  int getTotalPages() {
    return _totalPages;
  }
  
  /// Get the current reading progress (0.0 to 1.0)
  double getReadingProgress() {
    if (_totalPages == 0) {
      return 0.0;
    }
    return _currentPageIndex / (_totalPages - 1);
  }
  
  /// Refresh the layout (e.g., when font settings change)
  Future<void> refreshLayout() async {
    state = ReadingState.formatting;
    
    try {
      // Generate a new layout key
      final deviceSize = MediaQueryData.fromView(WidgetsBinding.instance.window).size;
      final fontSettings = _ref.read(fontSettingsProvider);
      
      _layoutKey = LayoutCacheService.generateLayoutKey(
        bookId: _bookId,
        deviceDimensions: deviceSize,
        fontSettings: fontSettings,
      );
      
      // Check if we have a cached layout
      final cacheService = _ref.read(layoutCacheServiceProvider);
      _pageMap = await cacheService.getPageMap(layoutKey: _layoutKey);
      
      if (_pageMap != null) {
        // Cache hit - we can render immediately
        _totalPages = _pageMap!.length;
        state = ReadingState.ready;
      } else {
        // Cache miss - we need to paginate
        await _paginateContent();
        state = ReadingState.ready;
      }
    } catch (e) {
      print('ReadingController: Error refreshing layout: $e');
      state = ReadingState.error;
    }
  }
}