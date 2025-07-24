import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';
import 'package:visualit/features/reader/presentation/widgets/html_content_widget.dart';

class PageContentWidget extends ConsumerStatefulWidget {
  final List<ContentBlock> chapterBlocks;
  final ReadingPreferences preferences;
  final int currentPage;
  final double pageHeight;
  // UPDATED: Simpler callback signature
  final Function(int, int) onLayoutCalculated;
  final int startBlockIndex;

  const PageContentWidget({
    super.key,
    required this.chapterBlocks,
    required this.preferences,
    required this.currentPage,
    required this.pageHeight,
    required this.onLayoutCalculated,
    required this.startBlockIndex,
  });

  @override
  ConsumerState<PageContentWidget> createState() => _PageContentWidgetState();
}

class _PageContentWidgetState extends ConsumerState<PageContentWidget> {
  final GlobalKey _contentKey = GlobalKey();
  bool _hasCalculated = false;
  final List<Widget> _pageContent = [];

  @override
  void initState() {
    super.initState();
    // This now runs every time the key changes (i.e., when chapter changes)
    WidgetsBinding.instance.addPostFrameCallback((_) => _buildPageContent());
  }

  Future<void> _buildPageContent() async {
    if (_hasCalculated || !mounted) return;

    final List<Widget> currentWidgets = [];
    int currentBlockIndex = widget.startBlockIndex;
    int endingBlockIndex = widget.startBlockIndex;

    while (currentBlockIndex < widget.chapterBlocks.length) {
      final block = widget.chapterBlocks[currentBlockIndex];

      currentWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: HtmlContentWidget(
            key: ValueKey('block_${block.id}'),
            block: block,
            blockIndex: currentBlockIndex,
            viewSize: Size(widget.pageHeight, widget.pageHeight),
          ),
        ),
      );

      setState(() {
        _pageContent.clear();
        _pageContent.addAll(currentWidgets);
      });

      await Future.delayed(Duration.zero);
      if (!mounted) return;

      final RenderBox? renderBox = _contentKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.size.height > widget.pageHeight) {
        if (currentBlockIndex == widget.startBlockIndex) {
          // Single block exceeds page height; include it to avoid empty pages
          endingBlockIndex = currentBlockIndex;
          break;
        }
        currentWidgets.removeLast();
        setState(() {
          _pageContent.clear();
          _pageContent.addAll(currentWidgets);
        });
        break;
      } else {
        endingBlockIndex = currentBlockIndex;
        currentBlockIndex++;
      }
    }

    if (mounted && !_hasCalculated) {
      _hasCalculated = true;
      print(
          "  -> [PageContentWidget] Page ${widget.currentPage} layout complete. Starts at ${widget.startBlockIndex}, ends at $endingBlockIndex.");
      // UPDATED: Call the simpler callback
      widget.onLayoutCalculated(widget.startBlockIndex, endingBlockIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final opacity = () {
      switch (widget.preferences.backgroundDimming) {
        case BackgroundDimming.none:
          return 1.0;
        case BackgroundDimming.low:
          return 0.9;
        case BackgroundDimming.medium:
          return 0.7;
        case BackgroundDimming.high:
          return 0.5;
      }
    }();

    return Opacity(
      opacity: opacity * widget.preferences.brightness,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          key: _contentKey,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _pageContent,
        ),
      ),
    );
  }
}