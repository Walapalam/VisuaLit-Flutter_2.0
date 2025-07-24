import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/presentation/reading_controller.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';
import 'package:visualit/features/reader/presentation/widgets/html_content_widget.dart';
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
  bool _isUiVisible = true; // Changed to true for debugging
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    print("-> [ReadingScreen] initState for bookId: ${widget.bookId}");
    print("  - Initial lock state: $_isLocked");
    _pageController = PageController();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  @override
  void dispose() {
    print("-> [ReadingScreen] dispose called.");
    _pageController?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  void _toggleUiVisibility() {
    print("-> [ReadingScreen] GestureDetector tapped");
    if (_isLocked) {
      print("  - UI toggle blocked: screen is locked");
      return;
    }

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

        print("  - ReadingState: isBookLoaded=${readingState.isBookLoaded}, "
            "chapter=${readingState.currentChapterIndex}, page=${readingState.currentPageInChapter}");
        print("  - Preferences: pageColor=${prefs.pageColor}, textColor=${prefs.textColor}, "
            "fontSize=${prefs.fontSize}");

        ref.listen(readingControllerProvider(widget.bookId), (prev, next) {
          if (prev == null || !_pageController!.hasClients) return;
          if (prev.currentChapterIndex != next.currentChapterIndex) {
            print("  - Chapter changed from ${prev.currentChapterIndex} to ${next.currentChapterIndex}");
            _pageController!.jumpToPage(0);
          } else if (prev.currentPageInChapter != next.currentPageInChapter) {
            if (_pageController!.page?.round() != next.currentPageInChapter) {
              print("  - Page changed from ${prev.currentPageInChapter} to ${next.currentPageInChapter}");
              _pageController!.jumpToPage(next.currentPageInChapter);
            }
          }
        });

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
          body: GestureDetector(
            onTap: _toggleUiVisibility,
            child: readingState.isBookLoaded
                ? _buildReaderBody(readingState, prefs)
                : const Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(ReadingState state, ReadingPreferences prefs) {
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
    print("-> [ReadingScreen] _buildReaderBody: blocks=${state.blocksForCurrentChapter.length}, "
        "pages=${state.pagesInCurrentChapter}");
    if (state.blocksForCurrentChapter.isEmpty) {
      return const Center(
        child: Text(
          "No content available",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      );
    }

    final viewSize = MediaQuery.of(context).size;
    final providerNotifier = ref.read(readingControllerProvider(widget.bookId).notifier);

    if (prefs.pageTurnStyle == PageTurnStyle.scroll) {
      return ListView.builder(
        itemCount: state.blocksForCurrentChapter.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: HtmlContentWidget(
              key: ValueKey('block_${state.blocksForCurrentChapter[index].id}'),
              block: state.blocksForCurrentChapter[index],
              blockIndex: index,
              viewSize: viewSize,
            ),
          );
        },
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      final pageHeight = constraints.maxHeight - 40.0;
      final pageContentKey = ValueKey(
          'chapter_${state.currentChapterIndex}_${prefs.fontSize}_${prefs.fontFamily}_${prefs.lineSpacing}_${prefs.textIndent}_${prefs.themeMode}_${prefs.brightness}');

      final pageMap = state.chapterPageToBlockIndexMap[state.currentChapterIndex] ?? {0: 0};
      final startBlockIndex = pageMap[state.currentPageInChapter] ?? 0;
      final endBlockIndex = pageMap[state.currentPageInChapter + 1] != null
          ? pageMap[state.currentPageInChapter + 1]! - 1
          : state.blocksForCurrentChapter.length - 1;

      print("  - PageMap: $pageMap");
      print("  - Page ${state.currentPageInChapter}: startIndex=$startBlockIndex, endIndex=$endBlockIndex");

      return PageView.builder(
        controller: _pageController,
        itemCount: state.pagesInCurrentChapter,
        onPageChanged: providerNotifier.onPageChangedBySwipe,
        itemBuilder: (context, index) {
          if (state.blocksForCurrentChapter.isEmpty) {
            return const Center(child: Text("Empty Chapter", style: TextStyle(color: Colors.white)));
          }
          final pageStartIndex = pageMap[index] ?? 0;
          final pageEndIndex = pageMap[index + 1] != null
              ? pageMap[index + 1]! - 1
              : state.blocksForCurrentChapter.length - 1;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: PageContentWidget(
              key: pageContentKey,
              chapterBlocks: state.blocksForCurrentChapter,
              preferences: prefs,
              currentPage: index,
              pageHeight: pageHeight,
              chapterIndex: state.currentChapterIndex,
              startBlockIndex: pageStartIndex,
              endBlockIndex: pageEndIndex,
              onLayoutCalculated: (chapterIdx, startIdx, endIdx) {
                providerNotifier.updateChapterPageLayout(chapterIdx, index, startIdx, endIdx);
              },
            ),
          );
        },
      );
    });
  }

  Widget _buildBottomScrubber(ReadingState state, ReadingPreferences prefs) {
    final totalPagesInChapter = state.pagesInCurrentChapter;
    return BottomAppBar(
      color: Theme.of(context).colorScheme.surface.withAlpha(242),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            IconButton(
              onPressed: ref.read(readingControllerProvider(widget.bookId).notifier).goToPreviousChapter,
              icon: Icon(Icons.chevron_left, color: prefs.textColor),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Page ${state.currentPageInChapter + 1} of $totalPagesInChapter',
                      style: TextStyle(color: prefs.textColor, fontSize: 12),
                    ),
                    Slider(
                      value: state.currentPageInChapter
                          .toDouble()
                          .clamp(0, (totalPagesInChapter > 0 ? totalPagesInChapter - 1 : 0).toDouble()),
                      min: 0,
                      max: (totalPagesInChapter > 0 ? totalPagesInChapter - 1 : 0).toDouble(),
                      divisions: totalPagesInChapter > 1 ? totalPagesInChapter - 1 : null,
                      onChanged: (value) => _pageController?.jumpToPage(value.round()),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: ref.read(readingControllerProvider(widget.bookId).notifier).goToNextChapter,
              icon: Icon(Icons.chevron_right, color: prefs.textColor),
            ),
          ],
        ),
      ),
    );
  }

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