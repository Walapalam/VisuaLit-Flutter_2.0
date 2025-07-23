import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/presentation/reading_controller.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';
import 'package:visualit/features/reader/presentation/widgets/page_content_widget.dart';
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
  bool _isLocked = false; // State for the lock button

  @override
  void initState() {
    super.initState();
    print("-> [ReadingScreen] initState for bookId: ${widget.bookId}");
    _pageController = PageController();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []); // Immersive mode
  }

  @override
  void dispose() {
    print("-> [ReadingScreen] dispose called.");
    _pageController?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values); // Restore UI overlays
    super.dispose();
  }

  void _toggleUiVisibility() {
    if (_isLocked) return; // Prevent UI toggle when screen is locked

    setState(() {
      _isUiVisible = !_isUiVisible;
      print("  - UI visibility toggled to: $_isUiVisible");
      if (_isUiVisible) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print("-> [ReadingScreen] build called.");

    final isarAsync = ref.watch(isarDBProvider);

    return isarAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text("Database Error")),
        body: Center(child: Text("Could not open database.\n\n$err")),
      ),
      data: (isar) {
        final readingState = ref.watch(readingControllerProvider(widget.bookId));
        final prefs = ref.watch(readingPreferencesProvider);

        // Listener to sync PageController
        ref.listen(readingControllerProvider(widget.bookId), (prev, next) {
          if (prev == null || !_pageController!.hasClients) return;
          if (prev.currentChapterIndex != next.currentChapterIndex) {
            _pageController!.jumpToPage(0);
          } else if (prev.currentPageInChapter != next.currentPageInChapter) {
            if (_pageController!.page?.round() != next.currentPageInChapter) {
              _pageController!.jumpToPage(next.currentPageInChapter);
            }
          }
        });

        // The main Scaffold, now structured like your old implementation
        return Scaffold(
          backgroundColor: prefs.pageColor,
          // --- AppBar IMPLEMENTATION ---
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: AnimatedOpacity(
              opacity: _isUiVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: _buildTopBar(readingState, prefs),
            ),
          ),
          // --- BottomNavigationBar IMPLEMENTATION ---
          bottomNavigationBar: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: _isUiVisible ? 80 : 0,
            child: _isUiVisible ? _buildBottomScrubber(readingState, prefs) : null,
          ),
          // --- FloatingActionButton IMPLEMENTATION ---
          floatingActionButton: _buildSpeedDialFab(readingState),
          // The main body of the scaffold
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

  // --- Helper methods for building UI sections ---

  Widget _buildTopBar(ReadingState state, ReadingPreferences prefs) {
    // This is the actual AppBar widget, now built separately for clarity
    return AppBar(
      backgroundColor: prefs.pageColor.withAlpha(200),
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
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

  Widget _buildReaderBody(ReadingState state, ReadingPreferences prefs) {
    return LayoutBuilder(builder: (context, constraints) {
      final pageHeight = constraints.maxHeight;
      final providerNotifier = ref.read(readingControllerProvider(widget.bookId).notifier);
      final pageContentKey = ValueKey('chapter_${state.currentChapterIndex}_${prefs.fontSize}_${prefs.fontFamily}_${prefs.lineSpacing}_${prefs.textIndent}');

      return PageView.builder(
        controller: _pageController,
        itemCount: state.pagesInCurrentChapter,
        onPageChanged: providerNotifier.onPageChangedBySwipe,
        itemBuilder: (context, index) {
          if (state.blocksForCurrentChapter.isEmpty) {
            return const Center(child: Text("Empty Chapter"));
          }
          return Padding( // Added padding here to match old layout
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: PageContentWidget(
              key: pageContentKey,
              chapterBlocks: state.blocksForCurrentChapter,
              preferences: prefs,
              currentPage: index,
              pageHeight: pageHeight,
              chapterIndex: state.currentChapterIndex,
              onLayoutCalculated: (chapterIdx, totalHeight) {
                providerNotifier.updateChapterLayout(chapterIdx, totalHeight, pageHeight);
              },
            ),
          );
        },
      );
    });
  }

  // NOTE: This now combines the scrubber and chapter navigation
  Widget _buildBottomScrubber(ReadingState state, ReadingPreferences prefs) {
    final totalPagesInChapter = state.pagesInCurrentChapter;
    return BottomAppBar(
      color: Theme.of(context).colorScheme.surface.withAlpha(242),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            IconButton(onPressed: ref.read(readingControllerProvider(widget.bookId).notifier).goToPreviousChapter, icon: Icon(Icons.chevron_left, color: prefs.textColor)),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Page ${state.currentPageInChapter + 1} of $totalPagesInChapter', style: TextStyle(color: prefs.textColor, fontSize: 12)),
                  Slider(
                    value: state.currentPageInChapter.toDouble().clamp(0, (totalPagesInChapter > 0 ? totalPagesInChapter - 1 : 0).toDouble()),
                    min: 0,
                    max: (totalPagesInChapter > 0 ? totalPagesInChapter - 1 : 0).toDouble(),
                    divisions: totalPagesInChapter > 1 ? totalPagesInChapter - 1 : null,
                    onChanged: (value) => _pageController?.jumpToPage(value.round()),
                  ),
                ],
              ),
            ),
            IconButton(onPressed: ref.read(readingControllerProvider(widget.bookId).notifier).goToNextChapter, icon: Icon(Icons.chevron_right, color: prefs.textColor)),
          ],
        ),
      ),
    );
  }

  // --- SpeedDial FAB implementation, just like the old one ---
  Widget _buildSpeedDialFab(ReadingState state) {
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
          onTap: () {
            setState(() => _isLocked = !_isLocked);
            print("DEBUG: [ReadingScreen] Screen lock toggled. New state: $_isLocked");
          },
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