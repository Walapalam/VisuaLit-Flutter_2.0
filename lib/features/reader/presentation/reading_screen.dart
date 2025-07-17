import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:visualit/features/reader/presentation/bookmarks_provider.dart';
import 'package:visualit/features/reader/presentation/reading_controller.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';
import 'package:visualit/features/reader/presentation/reading_screen_ui_controller.dart';
import 'package:visualit/features/reader/presentation/widgets/book_page_widget.dart';
import 'package:visualit/features/reader/presentation/widgets/html_content_widget.dart';
import 'package:visualit/features/reader/presentation/widgets/line_guide_painter.dart';
import 'package:visualit/features/reader/presentation/widgets/reader_speed_dial.dart';
import 'package:visualit/features/reader/presentation/widgets/reading_app_bar.dart';
import 'package:visualit/features/reader/presentation/widgets/reading_bottom_bar.dart';

// Provider for tracking if the current page is bookmarked
class IsCurrentPageBookmarkedNotifier extends StateNotifier<bool> {
  IsCurrentPageBookmarkedNotifier() : super(false);

  Future<void> checkIfPageIsBookmarked(int bookId, int page) async {
    debugPrint("[DEBUG] IsCurrentPageBookmarkedNotifier: Checking if page $page is bookmarked for book $bookId");
    try {
      final container = ProviderContainer();
      final bookmarksController = container.read(bookmarksControllerProvider);
      final isBookmarked = await bookmarksController.isPageBookmarked(bookId, page);
      state = isBookmarked;
      debugPrint("[DEBUG] IsCurrentPageBookmarkedNotifier: Page is bookmarked: $isBookmarked");
    } catch (e) {
      debugPrint("[ERROR] IsCurrentPageBookmarkedNotifier: Failed to check if page is bookmarked: $e");
    }
  }
}

final _isCurrentPageBookmarkedProvider = StateNotifierProvider.family<IsCurrentPageBookmarkedNotifier, bool, int>(
  (ref, bookId) {
    final notifier = IsCurrentPageBookmarkedNotifier();
    final state = ref.watch(readingControllerProvider(bookId));

    // Initialize on first load
    if (state.isBookLoaded) {
      notifier.checkIfPageIsBookmarked(bookId, state.currentPage);
    }

    return notifier;
  },
);

// Provider for managing page controllers
class PageControllersNotifier extends StateNotifier<PageControllers> {
  PageControllersNotifier() : super(const PageControllers());

  void initializeControllers(int bookId, PageTurnStyle pageTurnStyle, ReadingState readingState) {
    debugPrint("[DEBUG] PageControllersNotifier: Initializing controllers for page turn style: $pageTurnStyle");
    try {
      if (pageTurnStyle == PageTurnStyle.paged) {
        final pageController = PageController(initialPage: readingState.currentPage);

        // Dispose old scroll controller if exists
        if (state.scrollController != null) {
          state.scrollController!.dispose();
        }

        state = PageControllers(pageController: pageController);
      } else {
        final scrollController = ScrollController();

        // Dispose old page controller if exists
        if (state.pageController != null) {
          state.pageController!.dispose();
        }

        state = PageControllers(scrollController: scrollController);
      }

      debugPrint("[DEBUG] PageControllersNotifier: Controllers initialized successfully");
    } catch (e) {
      debugPrint("[ERROR] PageControllersNotifier: Failed to initialize controllers: $e");
    }
  }

  void disposeControllers() {
    debugPrint("[DEBUG] PageControllersNotifier: Disposing controllers");
    try {
      if (state.pageController != null) {
        state.pageController!.dispose();
      }
      if (state.scrollController != null) {
        state.scrollController!.dispose();
      }
    } catch (e) {
      debugPrint("[ERROR] PageControllersNotifier: Failed to dispose controllers: $e");
    }
  }
}

class PageControllers {
  final PageController? pageController;
  final ScrollController? scrollController;

  const PageControllers({this.pageController, this.scrollController});
}

final _pageControllerProvider = StateNotifierProvider.family<PageControllersNotifier, PageControllers, int>(
  (ref, bookId) => PageControllersNotifier(),
);

// Provider for tracking the line guide position
final _lineGuidePositionProvider = StateProvider<double>((ref) {
  // Start with the line guide in the middle of the screen
  return 300.0;
});

class ReadingScreen extends ConsumerWidget {
  final int bookId;

  const ReadingScreen({super.key, required this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewSize = MediaQuery.of(context).size;
    final provider = readingControllerProvider(bookId);
    final state = ref.watch(provider);
    final prefs = ref.watch(readingPreferencesProvider);
    final uiState = ref.watch(readingScreenUiProvider);
    final uiController = ref.read(readingScreenUiProvider.notifier);

    // Local state for bookmarks
    final isCurrentPageBookmarked = ref.watch(_isCurrentPageBookmarkedProvider(bookId));

    // Initialize controllers and system UI on first build
    ref.listen(provider, (previous, next) {
      if (previous == null) {
        _initializeSystemUI();
        // Initialize controllers with current page turn style
        final pageTurnStyle = ref.read(readingPreferencesProvider).pageTurnStyle;
        ref.read(_pageControllerProvider(bookId).notifier).initializeControllers(bookId, pageTurnStyle, next);
      }
    });

    // Listen for page changes to check bookmarks and update page controller
    ref.listen(provider.select((s) => s.currentPage), (previous, next) {
      if (next != previous) {
        // Check if the page is bookmarked
        ref.read(_isCurrentPageBookmarkedProvider(bookId).notifier).checkIfPageIsBookmarked(bookId, next);

        // Synchronize PageController with ReadingState
        final controllers = ref.read(_pageControllerProvider(bookId));
        if (controllers.pageController != null && 
            controllers.pageController!.hasClients && 
            controllers.pageController!.page?.round() != next) {
          try {
            debugPrint("[DEBUG] ReadingScreen: Synchronizing PageController with ReadingState - jumping to page $next");
            controllers.pageController!.jumpToPage(next);
          } catch (e) {
            debugPrint("[ERROR] ReadingScreen: Failed to synchronize PageController: $e");
          }
        }
      }
    });

    // Listen for page turn style changes
    ref.listen(readingPreferencesProvider.select((p) => p.pageTurnStyle), (prev, next) {
      if (prev != next) {
        ref.read(_pageControllerProvider(bookId).notifier).initializeControllers(bookId, next, state);
      }
    });

    // Listen for brightness changes
    ref.listen(readingPreferencesProvider.select((p) => p.brightness), (_, next) async {
      try { 
        debugPrint("[DEBUG] ReadingScreen: Setting screen brightness to $next");
        await ScreenBrightness().setScreenBrightness(next); 
      } catch (e) { 
        debugPrint("[ERROR] ReadingScreen: Failed to set screen brightness: $e");
      }
    });

    // Note: In a ConsumerWidget, we can't use ref.onDispose
    // Cleanup will be handled by the provider itself

    return Scaffold(
      backgroundColor: prefs.pageColor,
      body: Stack(
        children: [
          // 1. BookContentView - Widget that displays the actual book pages/text
          _buildBookContentView(context, ref, state, viewSize, provider, prefs),

          // 2. Line Guide - A draggable line guide to help with reading
          _buildLineGuide(context, ref, prefs, viewSize),

          // 3. TapDetector - A GestureDetector to toggle control visibility
          _buildTapDetector(uiState, uiController),

          // 4. ReadingAppBar - The top bar with title, back button, etc.
          ReadingAppBar(state: state, prefs: prefs),

          // 5. ReadingBottomBar - The bottom bar with the page scrubber
          ReadingBottomBar(state: state, prefs: prefs, bookId: bookId),

          // 6. ReaderSpeedDial - The floating action button menu
          ReaderSpeedDial(
            bookId: bookId,
            isCurrentPageBookmarked: isCurrentPageBookmarked,
            onToggleBookmark: () => _toggleBookmark(ref, bookId, isCurrentPageBookmarked),
          ),
        ],
      ),
    );
  }

  // 1. BookContentView - Widget that displays the actual book pages/text
  Widget _buildBookContentView(BuildContext context, WidgetRef ref, ReadingState state, Size viewSize, 
      AutoDisposeStateNotifierProvider<ReadingController, ReadingState> provider, ReadingPreferences prefs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: _buildBody(context, ref, state, viewSize, provider, prefs),
    );
  }

  // 2. TapDetector - A GestureDetector to toggle control visibility
  Widget _buildTapDetector(ReadingScreenUiState uiState, ReadingScreenUiController uiController) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: uiController.toggleUiVisibility,
        behavior: HitTestBehavior.translucent,
        child: AbsorbPointer(
          absorbing: uiState.isLocked,
          child: Container(
            color: Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, ReadingState state, Size viewSize,
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

    final controllers = ref.watch(_pageControllerProvider(bookId));

    if (prefs.pageTurnStyle == PageTurnStyle.scroll) {
      debugPrint("[DEBUG] ReadingScreen: Using scroll view for content");

      // Check if scroll controller is available
      if (controllers.scrollController == null) {
        debugPrint("[WARN] ReadingScreen: ScrollController is null, initializing controllers");
        ref.read(_pageControllerProvider(bookId).notifier).initializeControllers(bookId, prefs.pageTurnStyle, state);
        return const Center(child: CircularProgressIndicator());
      }

      return ListView.builder(
        controller: controllers.scrollController,
        itemCount: state.blocks.length,
        itemBuilder: (context, index) {
          if (index >= state.blocks.length) {
            debugPrint("[WARN] ReadingScreen: Block index $index out of bounds (total: ${state.blocks.length})");
            return const SizedBox.shrink();
          }

          return HtmlContentWidget(
            key: ValueKey('block_${state.blocks[index].id}'),
            block: state.blocks[index],
            blockIndex: index,
            viewSize: viewSize,
          );
        },
      );
    } else {
      debugPrint("[DEBUG] ReadingScreen: Using page view for content");

      // Check if page controller is available
      if (controllers.pageController == null) {
        debugPrint("[WARN] ReadingScreen: PageController is null, initializing controllers");
        ref.read(_pageControllerProvider(bookId).notifier).initializeControllers(bookId, prefs.pageTurnStyle, state);
        return const Center(child: CircularProgressIndicator());
      }

      // Ensure total pages is valid
      final totalPages = state.totalPages > 0 ? state.totalPages : 1;

      return PageView.builder(
        controller: controllers.pageController,
        itemCount: totalPages,
        onPageChanged: (page) {
          try {
            if (page >= 0 && page < totalPages) {
              ref.read(provider.notifier).onPageChanged(page);
            } else {
              debugPrint("[WARN] ReadingScreen: Page index $page out of bounds (total: $totalPages)");
            }
          } catch (e) {
            debugPrint("[ERROR] ReadingScreen: Error in onPageChanged: $e");
          }
        },
        itemBuilder: (context, index) {
          if (index < 0 || index >= totalPages) {
            debugPrint("[WARN] ReadingScreen: Page index $index out of bounds (total: $totalPages)");
            return const Center(child: Text('Invalid page'));
          }

          final startingBlockIndex = state.pageToBlockIndexMap[index];
          if (startingBlockIndex == null) {
            debugPrint("[WARN] ReadingScreen: No starting block index for page $index");
            return const Center(child: CircularProgressIndicator());
          }

          if (startingBlockIndex < 0 || startingBlockIndex >= state.blocks.length) {
            debugPrint("[WARN] ReadingScreen: Starting block index $startingBlockIndex out of bounds (total: ${state.blocks.length})");
            return const Center(child: Text('Invalid block index'));
          }

          debugPrint("[DEBUG] ReadingScreen: Building page $index starting at block $startingBlockIndex");
          return BookPageWidget(
            key: ValueKey('page_${index}_$startingBlockIndex'),
            allBlocks: state.blocks,
            startingBlockIndex: startingBlockIndex,
            viewSize: viewSize,
            pageIndex: index,
            onPageBuilt: (pageIndex, startBlock, endBlock) {
              try {
                ref.read(provider.notifier).updatePageLayout(pageIndex, startBlock, endBlock);
              } catch (e) {
                debugPrint("[ERROR] ReadingScreen: Error in updatePageLayout: $e");
              }
            },
          );
        },
      );
    }
  }

  void _initializeSystemUI() {
    debugPrint("[DEBUG] ReadingScreen: Initializing system UI");
    try {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      // Set initial orientation to portrait
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      debugPrint("[DEBUG] ReadingScreen: System UI and orientation set");
    } catch (e) {
      debugPrint("[ERROR] ReadingScreen: Failed to set system UI or orientation: $e");
    }
  }

  void _cleanupSystemUI() {
    debugPrint("[DEBUG] ReadingScreen: Cleaning up system UI");
    try {
      debugPrint("[DEBUG] ReadingScreen: Resetting screen brightness");
      ScreenBrightness().resetScreenBrightness().catchError((e) {
        debugPrint("[ERROR] ReadingScreen: Failed to reset screen brightness: $e");
      });

      debugPrint("[DEBUG] ReadingScreen: Resetting system UI mode");
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      debugPrint("[DEBUG] ReadingScreen: Resetting orientation");
      SystemChrome.setPreferredOrientations([]);
    } catch (e) {
      debugPrint("[ERROR] ReadingScreen: Error during cleanup: $e");
    }
  }

  // Build the line guide widget
  Widget _buildLineGuide(BuildContext context, WidgetRef ref, ReadingPreferences prefs, Size viewSize) {
    // Only show the line guide if it's enabled in preferences
    if (!prefs.isLineGuideEnabled) {
      return const SizedBox.shrink();
    }

    // Get the current line guide position
    final lineGuideY = ref.watch(_lineGuidePositionProvider);

    return Positioned.fill(
      child: GestureDetector(
        // Allow the user to drag the line guide up and down
        onVerticalDragUpdate: (details) {
          ref.read(_lineGuidePositionProvider.notifier).state = 
              (lineGuideY + details.delta.dy).clamp(0.0, viewSize.height);
        },
        // Make sure the gesture detector doesn't interfere with other interactions
        behavior: HitTestBehavior.translucent,
        child: CustomPaint(
          painter: LineGuidePainter(
            lineGuideY: lineGuideY,
            preferences: prefs,
          ),
          size: viewSize,
        ),
      ),
    );
  }

  Future<void> _toggleBookmark(WidgetRef ref, int bookId, bool isCurrentPageBookmarked) async {
    debugPrint("[DEBUG] ReadingScreen: Toggling bookmark for current page");
    try {
      final state = ref.read(readingControllerProvider(bookId));
      final bookmarksController = ref.read(bookmarksControllerProvider);
      final currentPage = state.currentPage;

      if (isCurrentPageBookmarked) {
        debugPrint("[DEBUG] ReadingScreen: Removing bookmark for page $currentPage");
        // Find the bookmark ID for this book and page
        final bookmarkId = await bookmarksController.getBookmarkIdByPage(
          bookId, 
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
          bookId, 
          currentPage,
          title: bookmarkTitle
        );
      }

      // Update the UI
      ref.read(_isCurrentPageBookmarkedProvider(bookId).notifier).checkIfPageIsBookmarked(bookId, currentPage);
    } catch (e) {
      debugPrint("[ERROR] ReadingScreen: Failed to toggle bookmark: $e");
    }
  }
}
