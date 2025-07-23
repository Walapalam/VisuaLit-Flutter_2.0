import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:visualit/features/reader/presentation/reading_controller.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';
import 'package:visualit/features/reader/presentation/widgets/book_page_widget.dart';
import 'package:visualit/features/reader/presentation/widgets/html_content_widget.dart';
import 'package:visualit/features/reader/presentation/widgets/reading_settings_panel.dart';

class ReadingScreen extends ConsumerStatefulWidget {
  final int bookId;
  const ReadingScreen({super.key, required this.bookId});

  @override
  ConsumerState<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends ConsumerState<ReadingScreen> {
  bool _isUiVisible = false;
  bool _isLocked = false;
  late final PageController _pageController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    final initialPage = ref.read(readingControllerProvider(widget.bookId)).currentPage;
    _pageController = PageController(initialPage: initialPage);
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      print("SCREEN: initState callback - Initializing controller.");
      final viewSize = MediaQuery.of(context).size;
      final prefs = ref.read(readingPreferencesProvider);
      ref.read(readingControllerProvider(widget.bookId).notifier).initialize(viewSize: viewSize, preferences: prefs);
    });
  }

  @override
  void dispose() {
    print("SCREEN: Disposing ReadingScreen.");
    _pageController.dispose();
    _scrollController.dispose();
    ScreenBrightness().resetScreenBrightness();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleUiVisibility() {
    if (_isLocked) return;
    setState(() {
      _isUiVisible = !_isUiVisible;
      SystemChrome.setEnabledSystemUIMode(_isUiVisible ? SystemUiMode.edgeToEdge : SystemUiMode.immersive);
    });
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
    print("SCREEN: Build method called.");
    final viewSize = MediaQuery.of(context).size;
    final provider = readingControllerProvider(widget.bookId);
    final state = ref.watch(provider);
    final prefs = ref.watch(readingPreferencesProvider);

    ref.listen(provider.select((s) => s.currentPage), (previous, next) {
      if (_pageController.hasClients && _pageController.page?.round() != next) {
        print("SCREEN: State changed to page $next. Commanding PageController to jump.");
        _pageController.jumpToPage(next);
      }
    });

    ref.listen(readingPreferencesProvider.select((p) => p.pageTurnStyle), (prev, next) {
      if (prev != next) {
        print("SCREEN: Page turn style changed. Rebuilding UI.");
        setState(() {});
      }
    });

    ref.listen(readingPreferencesProvider.select((p) => p.brightness), (_, next) async {
      try { await ScreenBrightness().setScreenBrightness(next); } catch (e) { print("SCREEN: Failed to set brightness: $e"); }
    });

    Widget screenBody;
    if (state.viewStatus == ReadingViewStatus.formatting || !state.isBookLoaded) {
      screenBody = const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Formatting book..."),
          ],
        ),
      );
    }
    // FIX: Defensive check for when processing completes but yields no content.
    else if (state.isBookLoaded && state.blocks.isEmpty) {
      screenBody = const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            "This book appears to have no content or could not be loaded correctly.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }
    else {
      if (prefs.pageTurnStyle == PageTurnStyle.scroll) {
        screenBody = _buildScrollView(state, viewSize);
      } else {
        screenBody = _buildPageView(state);
      }
    }

    return Scaffold(
      backgroundColor: prefs.pageColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedOpacity(
          opacity: _isUiVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 250),
          child: AppBar(
            backgroundColor: prefs.pageColor.withAlpha(200),
            elevation: 0,
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Text(
              state.viewStatus == ReadingViewStatus.ready ? state.chapterProgress : "Formatting...",
              style: TextStyle(color: prefs.textColor, fontSize: 12),
            ),
            actions: [IconButton(icon: Icon(Icons.close, color: prefs.textColor), onPressed: () => context.go('/home'))],
          ),
        ),
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: _isUiVisible ? 80 : 0,
        child: _isUiVisible ? _buildBottomScrubber(state, prefs) : null,
      ),
      floatingActionButton: _buildSpeedDialFab(),
      body: GestureDetector(
        onTap: _toggleUiVisibility,
        child: AbsorbPointer(
          absorbing: _isLocked,
          child: screenBody,
        ),
      ),
    );
  }

  Widget _buildPageView(ReadingState state) {
    return PageView.builder(
      controller: _pageController,
      itemCount: state.totalPages,
      onPageChanged: ref.read(readingControllerProvider(widget.bookId).notifier).onPageChanged,
      itemBuilder: (context, index) {
        final startingBlockIndex = state.pageToBlockIndexMap[index];
        if (startingBlockIndex == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return BookPageWidget(
          key: ValueKey('page_${index}_$startingBlockIndex'),
          allBlocks: state.blocks,
          startingBlockIndex: startingBlockIndex,
          viewSize: MediaQuery.of(context).size,
          pageIndex: index,
          onPageBuilt: ref.read(readingControllerProvider(widget.bookId).notifier).updatePageLayout,
        );
      },
    );
  }

  Widget _buildScrollView(ReadingState state, Size viewSize) {
    if (state.blocks.isEmpty) return const Center(child: Text('This book has no content.'));
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
  }

  Widget _buildSpeedDialFab() {
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
        SpeedDialChild(child: const Icon(Icons.share_outlined), label: 'Share', onTap: () {}),
        SpeedDialChild(
          child: Icon(_isLocked ? Icons.lock_open_outlined : Icons.lock_outline),
          label: _isLocked ? 'Unlock' : 'Lock Screen',
          onTap: () => setState(() => _isLocked = !_isLocked),
        ),
        SpeedDialChild(child: const Icon(Icons.search), label: 'Search', onTap: () {}),
        SpeedDialChild(child: const Icon(Icons.tune_outlined), label: 'Theme & Settings', onTap: _showMainSettingsPanel),
      ],
    );
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