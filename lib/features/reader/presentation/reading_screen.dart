import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/providers/isar_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/features/reader/presentation/reading_controller.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';
import 'package:visualit/features/reader/presentation/widgets/book_page_widget.dart';
import 'package:visualit/features/reader/presentation/widgets/scroll_content_widget.dart';
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
  ScrollController? _scrollController;
  bool _isUiVisible = false;
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    // It's safer to initialize controllers after the first frame
    // to ensure providers are ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _initializeControllers();
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  void _initializeControllers() {
    final readingState = ref.read(readingControllerProvider(widget.bookId));
    final prefs = ref.read(readingPreferencesProvider);

    if (prefs.pageTurnStyle == PageTurnStyle.paged) {
      _pageController = PageController(initialPage: readingState.currentPage);
    } else {
      _scrollController = ScrollController();
      // A full implementation would calculate the pixel offset from the saved page
    }
    // Force a rebuild to ensure the correct controller is used in the build method
    setState(() {});
  }

  @override
  void dispose() {
    _pageController?.dispose();
    _scrollController?.dispose();
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

        // Listener to switch controllers if the user changes the reading mode
        ref.listen(readingPreferencesProvider.select((p) => p.pageTurnStyle), (prev, next) {
          if (prev != next) {
            setState(() {
              if (next == PageTurnStyle.paged) {
                _scrollController?.dispose();
                _scrollController = null;
                _pageController = PageController(initialPage: readingState.currentPage);
              } else {
                _pageController?.dispose();
                _pageController = null;
                _scrollController = ScrollController();
              }
            });
          }
        });

        // Listener to sync PageController for Paged Mode
        if (prefs.pageTurnStyle == PageTurnStyle.paged) {
          ref.listen(readingControllerProvider(widget.bookId).select((s) => s.currentPage), (prev, next) {
            if (_pageController?.hasClients == true && _pageController!.page?.round() != next) {
              _pageController!.jumpToPage(next);
            }
          });
        }

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
          onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => TOCPanel(bookId: state.bookId, viewSize: MediaQuery.of(context).size)),
        ),
        IconButton(
          icon: Icon(Icons.close, color: prefs.textColor),
          onPressed: () => context.go('/home'),
        ),
      ],
    );
  }

  Widget _buildReaderBody(ReadingState state, ReadingPreferences prefs) {
    final viewSize = MediaQuery.of(context).size;
    final providerNotifier = ref.read(readingControllerProvider(widget.bookId).notifier);

    if (prefs.pageTurnStyle == PageTurnStyle.scroll) {
      if (_scrollController == null) return const Center(child: CircularProgressIndicator());
      return ScrollContentWidget(
        allBlocks: state.allBlocks,
        viewSize: viewSize,
        scrollController: _scrollController!,
      );
    } else {
      if (_pageController == null) return const Center(child: CircularProgressIndicator());
      return PageView.builder(
        controller: _pageController,
        itemCount: state.totalPages,
        onPageChanged: providerNotifier.onPageChanged,
        itemBuilder: (context, index) {
          final startingBlockIndex = state.pageToBlockIndexMap[index];

          if (startingBlockIndex == null) {
            return const Center(child: CircularProgressIndicator());
          }

          const double verticalPadding = 80.0;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: verticalPadding / 2),
            child: BookPageWidget(
              key: ValueKey('page_${index}_${prefs.fontSize}_${prefs.fontFamily}_${prefs.lineSpacing}'),
              allBlocks: state.allBlocks,
              startingBlockIndex: startingBlockIndex,
              viewSize: viewSize,
              pageIndex: index,
              onPageBuilt: providerNotifier.updatePageLayout,
              verticalPadding: verticalPadding,
            ),
          );
        },
      );
    }
  }

  Widget _buildBottomScrubber(ReadingState state, ReadingPreferences prefs) {
    if (prefs.pageTurnStyle == PageTurnStyle.scroll) {
      // The scrubber is not shown in scroll mode.
      return const SizedBox.shrink();
    }
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
                onChanged: (value) {
                  // Only allow jumping to pages that have been calculated
                  if((state.pageToBlockIndexMap[value.round()] != null)) {
                    _pageController?.jumpToPage(value.round());
                  }
                },
              ),
            ),
            Text('${state.totalPages}', style: TextStyle(color: prefs.textColor, fontSize: 12)),
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
          onTap: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => const ReadingSettingsPanel()),
        ),
      ],
    );
  }
}