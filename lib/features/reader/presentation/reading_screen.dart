import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/reader/presentation/reading_controller.dart';
import 'package:visualit/features/reader/presentation/reading_screen_ui_controller.dart';
import 'package:visualit/features/reader/presentation/widgets/reader_speed_dial.dart';
import 'package:visualit/features/reader/presentation/widgets/reading_app_bar.dart';
import 'package:visualit/features/reader/presentation/widgets/reading_bottom_bar.dart';
import 'package:visualit/features/reader/presentation/widgets/epub_view_widget.dart';


// Provider for managing page controllers - simplified for EPUB View only
class PageControllersNotifier extends StateNotifier<PageControllers> {
  PageControllersNotifier() : super(const PageControllers());

  void initializeControllers(int bookId, ReadingState readingState) {
    debugPrint("[DEBUG] PageControllersNotifier: Initializing controllers for EPUB View");
    // No controllers needed for EPUB View as it manages its own state
  }

  void disposeControllers() {
    debugPrint("[DEBUG] PageControllersNotifier: No controllers to dispose for EPUB View");
    // No controllers to dispose for EPUB View
  }
}

class PageControllers {
  // Empty class maintained for compatibility
  const PageControllers();
}

final _pageControllerProvider = StateNotifierProvider.family<PageControllersNotifier, PageControllers, int>(
  (ref, bookId) => PageControllersNotifier(),
);

class ReadingScreen extends ConsumerWidget {
  final int bookId;

  const ReadingScreen({super.key, required this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewSize = MediaQuery.of(context).size;
    final provider = readingControllerProvider(bookId);
    final state = ref.watch(provider);
    final uiState = ref.watch(readingScreenUiProvider);
    final uiController = ref.read(readingScreenUiProvider.notifier);


    // Initialize controllers and system UI on first build
    ref.listen(provider, (previous, next) {
      if (previous == null) {
        _initializeSystemUI();
        // Initialize controllers
        ref.read(_pageControllerProvider(bookId).notifier).initializeControllers(bookId, next);
      }
    });

    // Listen for page changes
    ref.listen(provider.select((s) => s.currentPage), (previous, next) {
      if (next != previous) {
        // No need to synchronize PageController with EPUB View rendering
      }
    });

    // Note: In a ConsumerWidget, we can't use ref.onDispose
    // Cleanup will be handled by the provider itself

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. BookContentView - Widget that displays the actual book pages/text
          _buildBookContentView(context, ref, state, viewSize, provider),

          // 2. TapDetector - A GestureDetector to toggle control visibility
          _buildTapDetector(uiState, uiController),

          // 3. ReadingAppBar - The top bar with title, back button, etc.
          ReadingAppBar(state: state),

          // 4. ReadingBottomBar - The bottom bar with the page scrubber
          ReadingBottomBar(state: state, bookId: bookId),

          // 5. ReaderSpeedDial - The floating action button menu
          ReaderSpeedDial(
            bookId: bookId,
          ),
        ],
      ),
    );
  }

  // 1. BookContentView - Widget that displays the actual book pages/text
  Widget _buildBookContentView(BuildContext context, WidgetRef ref, ReadingState state, Size viewSize, 
      AutoDisposeStateNotifierProvider<ReadingController, ReadingState> provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: _buildBody(context, ref, state, viewSize, provider),
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
      AutoDisposeStateNotifierProvider<ReadingController, ReadingState> provider) {
    debugPrint("[DEBUG] ReadingScreen: Building body with EPUB View rendering");

    if (!state.isBookLoaded) {
      debugPrint("[DEBUG] ReadingScreen: Book not loaded yet, showing loading indicator");
      return const Center(child: CircularProgressIndicator());
    }

    if (state.book == null) {
      debugPrint("[WARN] ReadingScreen: Book object is null");
      return const Center(child: Text('Book data not available.'));
    }

    // Check for pending TOC navigation
    if (state.pendingTocNavigation != null) {
      debugPrint("[DEBUG] ReadingScreen: Detected pending TOC navigation to: ${state.pendingTocNavigation!.title}");

      // Schedule a post-frame callback to show a message and clear the pending navigation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Show a message about the navigation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Navigating to '${state.pendingTocNavigation!.title ?? 'Unknown'}' (EpubView mode)"),
            duration: const Duration(seconds: 2),
          ),
        );

        // Clear the pending navigation
        ref.read(provider.notifier).clearPendingTocNavigation();
      });
    }

    return EpubViewWidget(
      bookId: bookId,
      viewSize: viewSize,
      onPageChanged: (page) {
        try {
          ref.read(provider.notifier).onPageChanged(page);
        } catch (e) {
          debugPrint("[ERROR] ReadingScreen: Error in onPageChanged: $e");
        }
      },
    );
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
      debugPrint("[DEBUG] ReadingScreen: Resetting system UI mode");
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      debugPrint("[DEBUG] ReadingScreen: Resetting orientation");
      SystemChrome.setPreferredOrientations([]);
    } catch (e) {
      debugPrint("[ERROR] ReadingScreen: Error during cleanup: $e");
    }
  }
}