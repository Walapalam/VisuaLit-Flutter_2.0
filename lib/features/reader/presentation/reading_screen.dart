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
  PageController? _pageController;
  ScrollController? _scrollController;
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    _initializePageStyleControllers();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  void _initializePageStyleControllers() {
    final prefs = ref.read(readingPreferencesProvider);
    final readingState = ref.read(readingControllerProvider(widget.bookId));

    if (prefs.pageTurnStyle == PageTurnStyle.paged) {
      _pageController = PageController(initialPage: readingState.currentPage);
      _scrollController?.dispose();
      _scrollController = null;
    } else {
      _scrollController = ScrollController();
      _pageController?.dispose();
      _pageController = null;
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    _scrollController?.dispose();
    ScreenBrightness().resetScreenBrightness();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleUiVisibility() {
    if (_isLocked) return;
    setState(() {
      _isUiVisible = !_isUiVisible;
      SystemChrome.setEnabledSystemUIMode(
        _isUiVisible ? SystemUiMode.edgeToEdge : SystemUiMode.immersive,
      );
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
    final viewSize = MediaQuery.of(context).size;
    final provider = readingControllerProvider(widget.bookId);
    final state = ref.watch(provider);
    final prefs = ref.watch(readingPreferencesProvider);

    ref.listen(provider.select((s) => s.currentPage), (previous, next) {
      if (next != previous && _pageController?.hasClients == true) {
        if (_pageController!.page?.round() != next) {
          _pageController!.jumpToPage(next);
        }
      }
    });

    ref.listen(readingPreferencesProvider.select((p) => p.pageTurnStyle), (prev, next) {
      if (prev != next) setState(_initializePageStyleControllers);
    });

    ref.listen(readingPreferencesProvider.select((p) => p.brightness), (_, next) async {
      try { await ScreenBrightness().setScreenBrightness(next); } catch (e) { /* ignore */ }
    });

    final readerContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: _buildBody(state, viewSize, provider, prefs),
    );

    return Scaffold(
      backgroundColor: prefs.pageColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedOpacity(
          opacity: 1.0,
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
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: _isUiVisible ? 80 : 0,
        // --- FIX: The method signature is simplified ---
        child: _isUiVisible ? _buildBottomScrubber(state, prefs) : null,
      ),
      floatingActionButton: _buildSpeedDialFab(),
      body: GestureDetector(
        onTap: _toggleUiVisibility,
        child: AbsorbPointer(
          absorbing: _isLocked,
          child: Stack(
            children: [
              readerContent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ReadingState state, Size viewSize,
      AutoDisposeStateNotifierProvider<ReadingController, ReadingState> provider, ReadingPreferences prefs) {
    if (!state.isBookLoaded) return const Center(child: CircularProgressIndicator());
    if (state.blocks.isEmpty) return const Center(child: Text('This book has no content.'));

    // Show formatting indicator when the book is being formatted
    if (state.isFormatting) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Formatting book...',
              style: TextStyle(
                color: prefs.textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This will only happen once for this device and font settings.',
              style: TextStyle(
                color: prefs.textColor.withOpacity(0.7),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (prefs.pageTurnStyle == PageTurnStyle.scroll) {
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
      return PageView.builder(
        controller: _pageController,
        itemCount: state.totalPages,
        onPageChanged: ref.read(provider.notifier).onPageChanged,
        itemBuilder: (context, index) {
          final startingBlockIndex = state.pageToBlockIndexMap[index];
          if (startingBlockIndex == null) return const Center(child: CircularProgressIndicator());
          return BookPageWidget(
            key: ValueKey('page_${index}_$startingBlockIndex'),
            allBlocks: state.blocks,
            startingBlockIndex: startingBlockIndex,
            viewSize: viewSize,
            pageIndex: index,
            onPageBuilt: ref.read(provider.notifier).updatePageLayout,
          );
        },
      );
    }
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

  // --- FIX: The method no longer needs the provider passed to it ---
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
