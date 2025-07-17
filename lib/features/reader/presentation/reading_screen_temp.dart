import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart'; // Added for DragStartBehavior
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:share_plus/share_plus.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/data/bookmark.dart';
import 'package:visualit/features/reader/presentation/bookmarks_provider.dart';
import 'package:visualit/features/reader/presentation/reading_controller.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';
import 'package:visualit/features/reader/presentation/widgets/book_page_widget.dart';
import 'package:visualit/features/reader/presentation/widgets/html_content_widget.dart';
import 'package:visualit/features/reader/presentation/widgets/reading_settings_panel.dart';
import 'package:visualit/features/reader/presentation/widgets/search_dialog.dart';

class ReadingScreen extends ConsumerStatefulWidget {
  final int bookId;
  const ReadingScreen({super.key, required this.bookId});

  @override
  ConsumerState<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends ConsumerState<ReadingScreen> {
  bool _isUiVisible = false;
  PageController? _pageController;
  ScrollController? _scrollController;
  bool _isLocked = false;
  bool _isCurrentPageBookmarked = false;

  // Track the current orientation mode
  DeviceOrientation _currentOrientation = DeviceOrientation.portraitUp;

  @override
  void initState() {
    super.initState();
    debugPrint("[DEBUG] ReadingScreen: Initializing for bookId: ${widget.bookId}");
    _initializePageStyleControllers();
    try {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      // Set initial orientation to portrait
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      debugPrint("[DEBUG] ReadingScreen: System UI and orientation set");
    } catch (e) {
      debugPrint("[ERROR] ReadingScreen: Failed to set system UI or orientation: $e");
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfPageIsBookmarked();
    });
  }

  Future<void> _checkIfPageIsBookmarked() async {
    debugPrint("[DEBUG] ReadingScreen: Checking if current page is bookmarked");
    try {
      final state = ref.read(readingControllerProvider(widget.bookId));
      final bookmarksController = ref.read(bookmarksControllerProvider);
      final isBookmarked = await bookmarksController.isPageBookmarked(
        widget.bookId, 
        state.currentPage
      );

      if (mounted) {
        setState(() {
          _isCurrentPageBookmarked = isBookmarked;
          debugPrint("[DEBUG] ReadingScreen: Page is bookmarked: $_isCurrentPageBookmarked");
        });
      }
    } catch (e) {
      debugPrint("[ERROR] ReadingScreen: Failed to check if page is bookmarked: $e");
    }
  }

  void _initializePageStyleControllers() {
    debugPrint("[DEBUG] ReadingScreen: Initializing page style controllers");
    try {
      final prefs = ref.read(readingPreferencesProvider);
      final readingState = ref.read(readingControllerProvider(widget.bookId));
      final pageTurnStyle = prefs.pageTurnStyle;

      debugPrint("[DEBUG] ReadingScreen: Page turn style: $pageTurnStyle, current page: ${readingState.currentPage}");

      if (pageTurnStyle == PageTurnStyle.scroll) {
        // For scroll mode, use ScrollController
        _scrollController = ScrollController();
        if (_pageController != null) {
          debugPrint("[DEBUG] ReadingScreen: Disposing page controller");
          _pageController?.dispose();
          _pageController = null;
        }
      } else {
        // For all paged modes (paged, slide, curl, fastFade), use PageController
        _pageController = PageController(initialPage: readingState.currentPage);
        if (_scrollController != null) {
          debugPrint("[DEBUG] ReadingScreen: Disposing scroll controller");
          _scrollController?.dispose();
          _scrollController = null;
        }
      }
      debugPrint("[DEBUG] ReadingScreen: Controllers initialized successfully");
    } catch (e) {
      debugPrint("[ERROR] ReadingScreen: Failed to initialize controllers: $e");
    }
  }

  @override
  void dispose() {
    debugPrint("[DEBUG] ReadingScreen: Disposing screen for bookId: ${widget.bookId}");
    try {
      if (_pageController != null) {
        debugPrint("[DEBUG] ReadingScreen: Disposing page controller");
        _pageController?.dispose();
      }
      if (_scrollController != null) {
        debugPrint("[DEBUG] ReadingScreen: Disposing scroll controller");
        _scrollController?.dispose();
      }

      debugPrint("[DEBUG] ReadingScreen: Resetting screen brightness");
      ScreenBrightness().resetScreenBrightness().catchError((e) {
        debugPrint("[ERROR] ReadingScreen: Failed to reset screen brightness: $e");
      });

      debugPrint("[DEBUG] ReadingScreen: Resetting system UI mode");
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      debugPrint("[DEBUG] ReadingScreen: Resetting orientation");
      SystemChrome.setPreferredOrientations([]);
    } catch (e) {
      debugPrint("[ERROR] ReadingScreen: Error during dispose: $e");
    }
    super.dispose();
  }

  // Toggle between portrait, landscape, and auto orientation modes
  void _toggleOrientation() {
    debugPrint("[DEBUG] ReadingScreen: Toggling orientation from $_currentOrientation");
    try {
      setState(() {
        switch (_currentOrientation) {
          case DeviceOrientation.portraitUp:
            // Switch to landscape
            _currentOrientation = DeviceOrientation.landscapeLeft;
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]);
            debugPrint("[DEBUG] ReadingScreen: Switched to landscape orientation");
            break;
          case DeviceOrientation.landscapeLeft:
          case DeviceOrientation.landscapeRight:
            // Switch to auto (all orientations)
            _currentOrientation = DeviceOrientation.portraitUp;
            SystemChrome.setPreferredOrientations([]);
            debugPrint("[DEBUG] ReadingScreen: Switched to auto orientation");
            break;
          default:
            // Switch to portrait
            _currentOrientation = DeviceOrientation.portraitUp;
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
            ]);
            debugPrint("[DEBUG] ReadingScreen: Switched to portrait orientation");
            break;
        }
      });
    } catch (e) {
      debugPrint("[ERROR] ReadingScreen: Failed to toggle orientation: $e");
    }
  }

  void _toggleUiVisibility() {
    if (_isLocked) {
      debugPrint("[DEBUG] ReadingScreen: UI toggle ignored - screen is locked");
      return;
    }

    debugPrint("[DEBUG] ReadingScreen: Toggling UI visibility from $_isUiVisible to ${!_isUiVisible}");
    try {
      setState(() {
        _isUiVisible = !_isUiVisible;
        SystemChrome.setEnabledSystemUIMode(
          _isUiVisible ? SystemUiMode.edgeToEdge : SystemUiMode.immersive,
        );
      });
    } catch (e) {
      debugPrint("[ERROR] ReadingScreen: Failed to toggle UI visibility: $e");
    }
  }

  void _showMainSettingsPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ReadingSettingsPanel(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewSize = MediaQuery.of(context).size;
    final provider = readingControllerProvider(widget.bookId);
    final state = ref.watch(provider);
    final prefs = ref.watch(readingPreferencesProvider);

    ref.listen(provider.select((s) => s.currentPage), (previous, next) {
      if (next != previous) {
        if (_pageController?.hasClients == true && _pageController!.page?.round() != next) {
          _pageController!.jumpToPage(next);
        }
        // Check if the new page is bookmarked
        _checkIfPageIsBookmarked();
      }
    });

    ref.listen(readingPreferencesProvider.select((p) => p.pageTurnStyle), (prev, next) {
      if (prev != next) setState(_initializePageStyleControllers);
    });

    ref.listen(readingPreferencesProvider.select((p) => p.brightness), (_, next) async {
      try { 
        debugPrint("[DEBUG] ReadingScreen: Setting screen brightness to $next");
        await ScreenBrightness().setScreenBrightness(next); 
      } catch (e) { 
        debugPrint("[ERROR] ReadingScreen: Failed to set screen brightness: $e");
      }
    });

    return Scaffold(
      backgroundColor: prefs.pageColor,
      body: Stack(
        children: [
          // 1. BookContentView - Widget that displays the actual book pages/text
          _buildBookContentView(state, viewSize, provider, prefs),

          // 2. TapDetector - A GestureDetector to toggle control visibility
          _buildTapDetector(),

          // 3. ReadingAppBar - The top bar with title, back button, etc.
          _buildReadingAppBar(state, prefs, context),

          // 4. ReadingBottomBar - The bottom bar with the page scrubber
          _buildReadingBottomBar(state, prefs),

          // 5. ReaderSpeedDial - The floating action button menu
          _buildReaderSpeedDial(),
        ],
      ),
    );
  }

  // 1. BookContentView - Widget that displays the actual book pages/text
  Widget _buildBookContentView(ReadingState state, Size viewSize, 
      AutoDisposeStateNotifierProvider<ReadingController, ReadingState> provider, ReadingPreferences prefs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: _buildBody(state, viewSize, provider, prefs),
    );
  }

  // 2. TapDetector - A GestureDetector to toggle control visibility
  Widget _buildTapDetector() {
    // If the screen is locked, absorb all pointer events
    if (_isLocked) {
      return Positioned.fill(
        child: AbsorbPointer(
          child: Container(
            color: Colors.transparent,
          ),
        ),
      );
    }

    // If the screen is not locked, only detect taps for UI visibility toggle
    return Positioned.fill(
      child: GestureDetector(
        onTap: _toggleUiVisibility,
        // Use deferToChild to allow the PageView to handle swipe gestures
        behavior: HitTestBehavior.deferToChild,
        child: Container(
          // Use a transparent container that doesn't respond to hit tests
          color: Colors.transparent,
        ),
      ),
    );
  }

  // 3. ReadingAppBar - The top bar with title, back button, etc.
  Widget _buildReadingAppBar(ReadingState state, ReadingPreferences prefs, BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        opacity: _isUiVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        child: AppBar(
          backgroundColor: _isUiVisible ? prefs.pageColor.withAlpha(200) : Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            _isUiVisible ? state.chapterProgress : state.book?.title ?? "Loading...",
            style: TextStyle(color: prefs.textColor, fontSize: 12),
          ),
          actions: [
            AnimatedOpacity(
              opacity: _isUiVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: IconButton(
                icon: Icon(Icons.close, color: prefs.textColor),
                onPressed: () => context.go('/home'),
              ),
            )
          ],
        ),
      ),
    );
  }

  // 4. ReadingBottomBar - The bottom bar with the page scrubber
  Widget _buildReadingBottomBar(ReadingState state, ReadingPreferences prefs) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: _isUiVisible ? 80 : 0,
        child: _isUiVisible ? _buildBottomScrubber(state, prefs) : null,
      ),
    );
  }

  // 5. ReaderSpeedDial - The floating action button menu
  Widget _buildReaderSpeedDial() {
    return Positioned(
      bottom: _isUiVisible ? 90 : -60, // Position it above the bottom bar when visible
      right: 16,
      child: AnimatedOpacity(
        opacity: _isUiVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        child: _buildSpeedDialFab(),
      ),
    );
  }

  Widget _buildBody(ReadingState state, Size viewSize,
      AutoDisposeStateNotifierProvider<ReadingController, ReadingState> provider, ReadingPreferences prefs) {
    debugPrint("[DEBUG] ReadingScreen: Building body with page turn style: ${prefs.pageTurnStyle}");

    if (!state.isBookLoaded) {
      debugPrint("[DEBUG] ReadingScreen: Book not loaded yet, showing loading indicator");
      return const Center(child: CircularProgressIndicator());
    }

    if (state.blocks.isEmpty) {
      debugPrint("[WARN] ReadingScreen: Book has no content blocks");
      return const Center(child: Text('This book has no content.'));
    }

    debugPrint("[DEBUG] ReadingScreen: Book has ${state.blocks.length} blocks and ${state.totalPages} pages");

    if (prefs.pageTurnStyle == PageTurnStyle.scroll) {
      debugPrint("[DEBUG] ReadingScreen: Using scroll view for content");
      return ListView.builder(
        controller: _scrollController,
        itemCount: state.blocks.length,
        itemBuilder: (context, index) {
          return HtmlContentWidget(
            key: ValueKey('block_${state.blocks[index].id}'),
            block: state.blocks[index],
            blockIndex: index,
            viewSize: viewSize,
          );
        },
      );
    } else {
      debugPrint("[DEBUG] ReadingScreen: Using page view for content with style: ${prefs.pageTurnStyle}");

      // Common page builder function
      Widget pageBuilder(BuildContext context, int index) {
        final startingBlockIndex = state.pageToBlockIndexMap[index];
        if (startingBlockIndex == null) {
          debugPrint("[WARN] ReadingScreen: No starting block index for page $index");
          return const Center(child: CircularProgressIndicator());
        }

        debugPrint("[DEBUG] ReadingScreen: Building page $index starting at block $startingBlockIndex");
        return BookPageWidget(
          key: ValueKey('page_${index}_$startingBlockIndex'),
          allBlocks: state.blocks,
          startingBlockIndex: startingBlockIndex,
          viewSize: viewSize,
          pageIndex: index,
          onPageBuilt: ref.read(provider.notifier).updatePageLayout,
        );
      }

      // Common PageView configuration
      final pageViewConfig = PageView.builder(
        controller: _pageController,
        itemCount: state.totalPages,
        onPageChanged: ref.read(provider.notifier).onPageChanged,
        // Ensure page turning gestures are properly detected
        pageSnapping: true,
        scrollDirection: Axis.horizontal,
        // Use PageScrollPhysics for better page turning behavior
        physics: const PageScrollPhysics(),
        itemBuilder: pageBuilder,
      );

      // Return the PageView directly without wrapping it in a GestureDetector
      // This allows the PageView to handle its own gestures
      return pageViewConfig;
    }
  }

  Future<void> _toggleBookmark() async {
    debugPrint("[DEBUG] ReadingScreen: Toggling bookmark for current page");
    try {
      final state = ref.read(readingControllerProvider(widget.bookId));
      final bookmarksController = ref.read(bookmarksControllerProvider);
      final currentPage = state.currentPage;

      if (_isCurrentPageBookmarked) {
        debugPrint("[DEBUG] ReadingScreen: Removing bookmark for page $currentPage");
        // Find the bookmark ID for this book and page
        final bookmarkId = await bookmarksController.getBookmarkIdByPage(
          widget.bookId, 
          currentPage
        );

        // If found, remove it
        if (bookmarkId != null) {
          debugPrint("[DEBUG] ReadingScreen: Found bookmark ID $bookmarkId, removing");
          await bookmarksController.removeBookmark(bookmarkId);
        } else {
          debugPrint("[WARN] ReadingScreen: Page was marked as bookmarked but no bookmark ID found");
        }
      } else {
        // Add a new bookmark
        final title = state.book?.title ?? 'Untitled Book';
        final pageTitle = "Page ${currentPage + 1}";
        final bookmarkTitle = "$title - $pageTitle";

        debugPrint("[DEBUG] ReadingScreen: Adding bookmark for page $currentPage with title: $bookmarkTitle");
        await bookmarksController.addBookmark(
          widget.bookId, 
          currentPage,
          title: bookmarkTitle
        );
      }

      // Update the UI
      _checkIfPageIsBookmarked();
    } catch (e) {
      debugPrint("[ERROR] ReadingScreen: Failed to toggle bookmark: $e");
    }
  }

  Future<void> _shareReading() async {
    debugPrint("[DEBUG] ReadingScreen: Sharing reading progress");
    try {
      final state = ref.read(readingControllerProvider(widget.bookId));
      final book = state.book;

      if (book == null) {
        debugPrint("[WARN] ReadingScreen: Cannot share - book is null");
        return;
      }

      final title = book.title ?? 'Untitled Book';
      final author = book.author != null && book.author!.isNotEmpty 
          ? ' by ${book.author}' 
          : '';
      final currentPage = state.currentPage + 1;
      final totalPages = state.totalPages;

      final shareText = 'I\'m reading "$title"$author - Page $currentPage of $totalPages in VisuaLit';
      debugPrint("[DEBUG] ReadingScreen: Sharing text: $shareText");

      await Share.share(shareText);
      debugPrint("[DEBUG] ReadingScreen: Share completed successfully");
    } catch (e) {
      debugPrint("[ERROR] ReadingScreen: Failed to share reading: $e");
    }
  }

  // Helper method to get the appropriate icon for the current page turn style
  IconData _getPageStyleIcon(PageTurnStyle style) {
    switch (style) {
      case PageTurnStyle.paged:
        return Icons.auto_stories;
      case PageTurnStyle.scroll:
        return Icons.vertical_align_bottom;
      case PageTurnStyle.slide:
        return Icons.swipe;
      case PageTurnStyle.curl:
        return Icons.flip_to_back;
      case PageTurnStyle.fastFade:
        return Icons.flash_on;
      default:
        return Icons.auto_stories;
    }
  }

  // Helper method to get the label for the current page turn style
  String _getPageTurnStyleLabel(PageTurnStyle style) {
    switch (style) {
      case PageTurnStyle.paged:
        return 'Page Turn';
      case PageTurnStyle.scroll:
        return 'Scroll Mode';
      case PageTurnStyle.slide:
        return 'Slide Mode';
      case PageTurnStyle.curl:
        return 'Curl Mode';
      case PageTurnStyle.fastFade:
        return 'Fast Fade Mode';
      default:
        return 'Page Turn Mode';
    }
  }

  // Method to cycle to the next page turn style
  void _cyclePageTurnStyle() {
    debugPrint("[DEBUG] ReadingScreen: Cycling page turn style");
    final prefs = ref.read(readingPreferencesProvider);
    final currentStyle = prefs.pageTurnStyle;

    // Determine the next style in the cycle
    PageTurnStyle nextStyle;
    switch (currentStyle) {
      case PageTurnStyle.paged:
        nextStyle = PageTurnStyle.scroll;
        break;
      case PageTurnStyle.scroll:
        nextStyle = PageTurnStyle.slide;
        break;
      case PageTurnStyle.slide:
        nextStyle = PageTurnStyle.curl;
        break;
      case PageTurnStyle.curl:
        nextStyle = PageTurnStyle.fastFade;
        break;
      case PageTurnStyle.fastFade:
        nextStyle = PageTurnStyle.paged;
        break;
      default:
        nextStyle = PageTurnStyle.paged;
    }

    // Update the preference
    ref.read(readingPreferencesProvider.notifier).setPageTurnStyle(nextStyle);
    debugPrint("[DEBUG] ReadingScreen: Page turn style changed to $nextStyle");

    // Show a snackbar to inform the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Page turn style changed to ${nextStyle.toString().split('.').last}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildSpeedDialFab() {
    final prefs = ref.watch(readingPreferencesProvider);

    return SpeedDial(
      icon: Icons.more_horiz,
      activeIcon: Icons.close,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      foregroundColor: Theme.of(context).colorScheme.onSecondary,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      buttonSize: const Size(48, 48),
      childrenButtonSize: const Size(44, 44),
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          child: Icon(_isCurrentPageBookmarked ? Icons.bookmark : Icons.bookmark_border),
          label: _isCurrentPageBookmarked ? 'Remove Bookmark' : 'Add Bookmark',
          onTap: _toggleBookmark,
        ),
        SpeedDialChild(
          child: const Icon(Icons.share_outlined), 
          label: 'Share', 
          onTap: _shareReading
        ),
        SpeedDialChild(
          child: Icon(_isLocked ? Icons.lock_open_outlined : Icons.lock_outline),
          label: _isLocked ? 'Unlock' : 'Lock Screen',
          onTap: () => setState(() => _isLocked = !_isLocked),
        ),
        SpeedDialChild(
          child: const Icon(Icons.search), 
          label: 'Search', 
          onTap: () {
            final state = ref.read(readingControllerProvider(widget.bookId));
            if (state.blocks.isEmpty) return;

            showDialog(
              context: context,
              builder: (context) => SearchDialog(
                bookId: widget.bookId,
                blocks: state.blocks,
              ),
            ).then((result) {
              if (result is SearchNavigation) {
                ref.read(readingControllerProvider(widget.bookId).notifier)
                  .onPageChanged(result.page);
              }
            });
          },
        ),
        // New SpeedDialChild for toggling page turn style
        SpeedDialChild(
          child: Icon(prefs.pageTurnStyle == PageTurnStyle.paged 
              ? Icons.auto_stories 
              : prefs.pageTurnStyle == PageTurnStyle.scroll 
                ? Icons.vertical_align_bottom 
                : prefs.pageTurnStyle == PageTurnStyle.slide 
                  ? Icons.swipe 
                  : prefs.pageTurnStyle == PageTurnStyle.curl 
                    ? Icons.flip_to_back 
                    : Icons.flash_on),
          label: prefs.pageTurnStyle == PageTurnStyle.paged 
              ? 'Page Turn' 
              : prefs.pageTurnStyle == PageTurnStyle.scroll 
                ? 'Scroll Mode' 
                : prefs.pageTurnStyle == PageTurnStyle.slide 
                  ? 'Slide Mode' 
                  : prefs.pageTurnStyle == PageTurnStyle.curl 
                    ? 'Curl Mode' 
                    : 'Fast Fade Mode',
          onTap: _cyclePageTurnStyle,
        ),
        SpeedDialChild(
          child: Icon(_getOrientationIcon()),
          label: _getOrientationLabel(),
          onTap: _toggleOrientation,
        ),
        SpeedDialChild(child: const Icon(Icons.tune_outlined), label: 'Theme & Settings', onTap: _showMainSettingsPanel),
      ],
    );
  }

  // Helper methods for orientation control
  IconData _getOrientationIcon() {
    switch (_currentOrientation) {
      case DeviceOrientation.portraitUp:
        return Icons.screen_rotation;
      case DeviceOrientation.landscapeLeft:
      case DeviceOrientation.landscapeRight:
        return Icons.screen_lock_landscape;
      default:
        return Icons.screen_lock_portrait;
    }
  }

  String _getOrientationLabel() {
    switch (_currentOrientation) {
      case DeviceOrientation.portraitUp:
        return 'Switch to Landscape';
      case DeviceOrientation.landscapeLeft:
      case DeviceOrientation.landscapeRight:
        return 'Auto Rotation';
      default:
        return 'Switch to Portrait';
    }
  }

  Widget _buildBottomScrubber(ReadingState state, ReadingPreferences prefs) {
    if (prefs.pageTurnStyle == PageTurnStyle.scroll) return const SizedBox.shrink();

    return BottomAppBar(
      color: Theme.of(context).colorScheme.surface.withAlpha(242),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Text('Page ${state.currentPage + 1}', style: TextStyle(color: prefs.textColor, fontSize: 12)),
            Expanded(
              child: Slider(
                value: state.currentPage.toDouble().clamp(0, (state.totalPages > 0 ? state.totalPages - 1 : 0).toDouble()),
                min: 0,
                max: (state.totalPages > 0 ? state.totalPages - 1 : 0).toDouble(),
                // It can now access the provider directly using `ref`.
                onChanged: (value) => ref.read(readingControllerProvider(widget.bookId).notifier).onPageChanged(value.round()),
                activeColor: prefs.textColor,
                inactiveColor: prefs.textColor.withAlpha(77),
              ),
            ),
            Text('${state.totalPages}', style: TextStyle(color: prefs.textColor, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
