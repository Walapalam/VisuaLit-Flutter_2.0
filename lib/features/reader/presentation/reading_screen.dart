import 'dart:async';
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
import 'package:visualit/features/reader/presentation/widgets/book_overview_dialog.dart';
import 'package:visualit/features/reader/data/book_data.dart' as local_book_data;

/// A unified, shared definition for a text highlight.
/// This is the SINGLE SOURCE OF TRUTH for this class.
class TextHighlight {
  final int blockIndex;
  final int startOffset;
  final int endOffset;
  final Color color;

  TextHighlight({
    required this.blockIndex,
    required this.startOffset,
    required this.endOffset,
    required this.color,
  });
}

/// A utility extension to provide `firstWhereOrNull` functionality.
extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

class ReadingScreen extends ConsumerStatefulWidget {
  final int bookId;
  const ReadingScreen({super.key, required this.bookId});

  @override
  ConsumerState<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends ConsumerState<ReadingScreen> with SingleTickerProviderStateMixin {
  bool _isUiVisible = true;
  PageController? _pageController;
  ScrollController? _scrollController;
  bool _isLocked = false;

  Timer? _saveProgressTimer;
  Timer? _autoHideTimer;
  late AnimationController _barAnimationController;

  // State for handling text selection and highlighting
  TextSelection? _lastSelection;
  int? _lastSelectedBlockIndex;
  final List<TextHighlight> _highlights = []; // This list now uses the unified TextHighlight class
  final List<Color> _highlightColors = [
    Colors.yellow.withOpacity(0.5),
    Colors.green.withOpacity(0.5),
    Colors.blue.withOpacity(0.5),
    Colors.pink.withOpacity(0.5),
  ];

  @override
  void initState() {
    super.initState();
    _initializePageStyleControllers();
    _barAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _barAnimationController.value = 1.0;
    _startAutoHideTimer();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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
      _scrollController!.addListener(() => _onScroll(readingState));
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
    _saveProgressTimer?.cancel();
    _autoHideTimer?.cancel();
    _barAnimationController.dispose();
    super.dispose();
  }

  void _startAutoHideTimer() {
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(const Duration(seconds: 4), _hideBars);
  }

  void _toggleUiVisibility() {
    if (_isLocked) return;
    setState(() {
      _isUiVisible = !_isUiVisible;
      if (_isUiVisible) {
        _barAnimationController.forward();
        _startAutoHideTimer();
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      } else {
        _barAnimationController.reverse();
        _autoHideTimer?.cancel();
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      }
    });
  }

  void _hideBars() {
    if (mounted && _isUiVisible) {
      setState(() {
        _isUiVisible = false;
        _barAnimationController.reverse();
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      });
    }
  }

  void _onScroll(ReadingState state) {
    _saveProgressTimer?.cancel();
    _saveProgressTimer = Timer(const Duration(seconds: 1), () => _saveProgress(state));
    if (_isUiVisible) {
      _hideBars();
    }
  }

  Future<void> _saveProgress(ReadingState state) async {
    ref.read(readingControllerProvider(widget.bookId).notifier).onPageChanged(state.currentPage);
  }

  void _showMainSettingsPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ReadingSettingsPanel(),
    );
  }

  void _showBookOverviewDialog() {
    final readingState = ref.read(readingControllerProvider(widget.bookId));
    final localBook = readingState.book;
    if (localBook == null || localBook.title == null) return;

    final currentBlockStart = readingState.pageToBlockIndexMap[readingState.currentPage];
    if (currentBlockStart == null || currentBlockStart >= readingState.blocks.length) return;

    final currentChapterIndex = readingState.blocks[currentBlockStart].chapterIndex;
    if (currentChapterIndex == null) return;

    final chapterContent = readingState.blocks
        .where((block) => block.chapterIndex == currentChapterIndex)
        .map((block) => block.textContent ?? '')
        .join('\n');

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Book Overview',
      pageBuilder: (context, _, __) => BookOverviewDialog(
        bookTitleForLookup: localBook.title!,
        localBookISBN: localBook.isbn,
        localChapterNumber: currentChapterIndex,
        localChapterContent: chapterContent,
      ),
    );
  }

  void _onTextSelectionChanged(TextSelection? selection, int? blockIndex, String? blockTextContent) {
    if (selection == null || blockIndex == null || !selection.isValid || selection.isCollapsed) {
      _lastSelection = null;
      _lastSelectedBlockIndex = null;
      return;
    }

    _lastSelection = selection;
    _lastSelectedBlockIndex = blockIndex;
    _showHighlightOptions();
  }

  void _showHighlightOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900.withOpacity(0.95),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Choose a highlight color", style: TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _highlightColors.map((color) {
                  return GestureDetector(
                    onTap: () => _addHighlight(color),
                    child: CircleAvatar(backgroundColor: color, radius: 22),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addHighlight(Color color) {
    if (_lastSelection == null || _lastSelectedBlockIndex == null) return;

    final newHighlight = TextHighlight(
      blockIndex: _lastSelectedBlockIndex!,
      startOffset: _lastSelection!.start,
      endOffset: _lastSelection!.end,
      color: color,
    );

    setState(() {
      _highlights.removeWhere((h) =>
      h.blockIndex == newHighlight.blockIndex &&
          h.endOffset > newHighlight.startOffset &&
          h.startOffset < newHighlight.endOffset);
      _highlights.add(newHighlight);
    });

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final viewSize = MediaQuery.of(context).size;
    final provider = readingControllerProvider(widget.bookId);
    final state = ref.watch(provider);
    final prefs = ref.watch(readingPreferencesProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(provider.notifier).setLayoutParameters(prefs, viewSize);
    });

    ref.listen(provider.select((s) => s.currentPage), (previous, next) {
      if (next != previous && _pageController?.hasClients == true && _pageController!.page?.round() != next) {
        _pageController!.jumpToPage(next);
      }
    });

    ref.listen(readingPreferencesProvider, (prev, next) {
      if (prev?.fontSize != next.fontSize ||
          prev?.lineSpacing != next.lineSpacing ||
          prev?.fontFamily != next.fontFamily ||
          prev?.pageTurnStyle != next.pageTurnStyle) {
        ref.read(provider.notifier).setLayoutParameters(next, viewSize);
      }
      if (prev?.pageTurnStyle != next.pageTurnStyle) {
        setState(_initializePageStyleControllers);
      }
    });

    ref.listen(readingPreferencesProvider.select((p) => p.brightness), (_, next) async {
      try { await ScreenBrightness().setScreenBrightness(next); } catch (_) {}
    });

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
              state.chapterProgress,
              style: TextStyle(color: prefs.textColor, fontSize: 12),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.close, color: prefs.textColor),
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: _isUiVisible ? 80 : 0,
        child: _isUiVisible ? _buildBottomScrubber(state, prefs) : null,
      ),
      floatingActionButton: _isUiVisible ? _buildSpeedDialFab() : null,
      body: GestureDetector(
        onTap: _toggleUiVisibility,
        child: AbsorbPointer(
          absorbing: _isLocked,
          child: _buildBody(state, viewSize, provider, prefs),
        ),
      ),
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
      children: [
        SpeedDialChild(
            child: const Icon(Icons.visibility),
            label: 'Overview',
            onTap: _showBookOverviewDialog),
        SpeedDialChild(
          child: Icon(_isLocked ? Icons.lock_open_outlined : Icons.lock_outline),
          label: _isLocked ? 'Unlock' : 'Lock Screen',
          onTap: () => setState(() => _isLocked = !_isLocked),
        ),
        SpeedDialChild(
            child: const Icon(Icons.tune_outlined),
            label: 'Theme & Settings',
            onTap: _showMainSettingsPanel),
      ],
    );
  }

  Widget _buildBody(ReadingState state, Size viewSize, AutoDisposeStateNotifierProvider<ReadingController, ReadingState> provider, ReadingPreferences prefs) {
    if (!state.isBookLoaded) return const Center(child: CircularProgressIndicator());
    if (state.blocks.isEmpty) return const Center(child: Text('This book has no content.'));

    if (prefs.pageTurnStyle == PageTurnStyle.scroll) {
      return ListView.builder(
        controller: _scrollController,
        itemCount: state.blocks.length,
        itemBuilder: (context, index) {
          final block = state.blocks[index];
          return HtmlContentWidget(
            key: ValueKey('block_${block.id}'),
            block: block,
            blockIndex: index,
            viewSize: viewSize,
            highlights: _highlights.where((h) => h.blockIndex == index).toList(),
            onSelectionChanged: (selection, renderObject, blockTextContent) {
              _onTextSelectionChanged(selection, index, blockTextContent);
            },
          );
        },
      );
    } else {
      return PageView.builder(
        controller: _pageController,
        itemCount: state.totalPages,
        onPageChanged: (pageIndex) {
          ref.read(provider.notifier).onPageChanged(pageIndex);
          _saveProgress(state);
        },
        itemBuilder: (context, pageIndex) {
          final startingBlockIndex = state.pageToBlockIndexMap[pageIndex];
          if (startingBlockIndex == null) return const Center(child: CircularProgressIndicator());

          final endingBlockIndex = (pageIndex + 1 < state.totalPages)
              ? (state.pageToBlockIndexMap[pageIndex + 1] ?? state.blocks.length) - 1
              : state.blocks.length - 1;

          return BookPageWidget(
            key: ValueKey('page_${pageIndex}_$startingBlockIndex'),
            allBlocks: state.blocks,
            startingBlockIndex: startingBlockIndex,
            viewSize: viewSize,
            pageIndex: pageIndex,
            onPageBuilt: ref.read(provider.notifier).updatePageLayout,
            highlights: _highlights.where((h) => h.blockIndex >= startingBlockIndex && h.blockIndex <= endingBlockIndex).toList(),
            onSelectionChanged: (selection, renderObject, blockIndex, blockTextContent) {
              _onTextSelectionChanged(selection, blockIndex, blockTextContent);
            },
          );
        },
      );
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
