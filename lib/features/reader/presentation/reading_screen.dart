import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/presentation/reading_controller.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';
import 'package:visualit/features/reader/presentation/widgets/book_page_widget.dart'; // IMPORTANT: Using BookPageWidget
import 'package:visualit/features/reader/presentation/widgets/reading_settings_panel.dart';
import 'package:visualit/features/reader/presentation/widgets/toc_panel.dart';

class ReadingScreen extends ConsumerStatefulWidget {
  final int bookId;
  const ReadingScreen({super.key, required this.bookId});

  @override
  ConsumerState<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends ConsumerState<ReadingScreen> {
  PageController? _pageController;
  bool _isUiVisible = false;
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    // Initialize with the saved page number from the now-correct controller
    final initialPage = ref.read(readingControllerProvider(widget.bookId)).currentPage;
    _pageController = PageController(initialPage: initialPage);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  @override
  void dispose() {
    _pageController?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  void _toggleUiVisibility() {
    if (_isLocked) return;
    setState(() {
      _isUiVisible = !_isUiVisible;
      if (_isUiVisible) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isarAsync = ref.watch(isarDBProvider);

    return isarAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(appBar: AppBar(title: const Text("Database Error")), body: Center(child: Text("Could not open database.\n\n$err"))),
      data: (isar) {
        final readingState = ref.watch(readingControllerProvider(widget.bookId));
        final prefs = ref.watch(readingPreferencesProvider);

        // Listener to sync PageController if state changes externally (e.g., TOC jump)
        ref.listen(readingControllerProvider(widget.bookId).select((s) => s.currentPage), (prev, next) {
          if (_pageController?.hasClients == true && _pageController!.page?.round() != next) {
            _pageController!.jumpToPage(next);
          }
        });

        // The Scaffold is structured exactly like your original implementation
        return Scaffold(
          backgroundColor: prefs.pageColor,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: AnimatedOpacity(
              opacity: _isUiVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: _buildTopBar(readingState, prefs),
            ),
          ),
          bottomNavigationBar: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: _isUiVisible ? 80 : 0,
            child: _isUiVisible ? _buildBottomScrubber(readingState, prefs) : null,
          ),
          floatingActionButton: _buildSpeedDialFab(readingState),
          body: !readingState.isBookLoaded
              ? const Center(child: CircularProgressIndicator())
              : GestureDetector(
            onTap: _toggleUiVisibility,
            child: AbsorbPointer(
              absorbing: _isLocked,
              child: _buildReaderBody(readingState, prefs),
            ),
          ),
        );
      },
    );
  }

  // --- UI Helper Methods ---

  Widget _buildTopBar(ReadingState state, ReadingPreferences prefs) {
    return AppBar(
      backgroundColor: prefs.pageColor.withAlpha(200),
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      // The chapterProgress getter in the new controller provides meaningful text
      title: Text(state.chapterProgress, style: TextStyle(color: prefs.textColor, fontSize: 12)),
      actions: [
        IconButton(
          icon: Icon(Icons.list, color: prefs.textColor),
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => TOCPanel(bookId: state.bookId, viewSize: MediaQuery.of(context).size),
          ),
        ),
        IconButton(
          icon: Icon(Icons.close, color: prefs.textColor),
          onPressed: () => context.go('/home'),
        ),
      ],
    );
  }

  // THIS IS THE CORE CHANGE: It now uses BookPageWidget
  Widget _buildReaderBody(ReadingState state, ReadingPreferences prefs) {
    final viewSize = MediaQuery.of(context).size;
    final providerNotifier = ref.read(readingControllerProvider(widget.bookId).notifier);

    // The reading mode toggle is now implemented correctly here
    if (prefs.pageTurnStyle == PageTurnStyle.scroll) {
      // NOTE: ScrollContentWidget needs to be created for this mode to work
      return Center(child: Text("Scroll Mode UI needs to be implemented."));
    } else {
      // --- PAGED MODE (TRUE PAGINATION) ---
      return PageView.builder(
        controller: _pageController,
        itemCount: state.totalPages, // Driven by dynamically discovered total pages
        onPageChanged: providerNotifier.onPageChanged,
        itemBuilder: (context, index) {
          final startingBlockIndex = state.pageToBlockIndexMap[index];

          if (startingBlockIndex == null) {
            // This is normal. It means the app is still calculating the layout for this page.
            return const Center(child: CircularProgressIndicator());
          }

          // Create the widget that will measure and render this single page
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
            child: BookPageWidget(
              // The key now includes font settings to force a recalculation on style change
              key: ValueKey('page_${index}_${prefs.fontSize}_${prefs.fontFamily}_${prefs.lineSpacing}'),
              allBlocks: state.allBlocks,
              startingBlockIndex: startingBlockIndex,
              viewSize: viewSize,
              pageIndex: index,
              onPageBuilt: providerNotifier.updatePageLayout,
            ),
          );
        },
      );
    }
  }

  Widget _buildBottomScrubber(ReadingState state, ReadingPreferences prefs) {
    // This now correctly uses the book-wide page numbers from the new controller
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
                onChanged: (value) => _pageController?.jumpToPage(value.round()),
              ),
            ),
            Text('${state.totalPages}', style: TextStyle(color: prefs.textColor, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedDialFab(ReadingState state) {
    // This is identical to your original implementation
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
      visible: _isUiVisible,
      children: [
        SpeedDialChild(child: const Icon(Icons.bookmark_border), label: 'Bookmark', onTap: () {}),
        SpeedDialChild(
          child: Icon(_isLocked ? Icons.lock_open_outlined : Icons.lock_outline),
          label: _isLocked ? 'Unlock' : 'Lock Screen',
          onTap: () => setState(() => _isLocked = !_isLocked),
        ),
        SpeedDialChild(
          child: const Icon(Icons.tune_outlined),
          label: 'Theme & Settings',
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const ReadingSettingsPanel(),
          ),
        ),
      ],
    );
  }
}