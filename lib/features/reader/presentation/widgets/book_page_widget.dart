// In lib/features/reader/presentation/widgets/book_page_widget.dart

import 'package:flutter/material.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/presentation/widgets/html_content_widget.dart';

class BookPageWidget extends StatefulWidget {
  final List<ContentBlock> allBlocks;
  final int startingBlockIndex;
  final Size viewSize;
  final Function(int pageIndex, int startingBlock, int endingBlock) onPageBuilt;
  final int pageIndex;

  const BookPageWidget({
    super.key,
    required this.allBlocks,
    required this.startingBlockIndex,
    required this.viewSize,
    required this.onPageBuilt,
    required this.pageIndex,
  });

  @override
  State<BookPageWidget> createState() => _BookPageWidgetState();
}

class _BookPageWidgetState extends State<BookPageWidget> {
  final List<Widget> _pageContent = [];
  final GlobalKey _columnKey = GlobalKey();
  bool _isLayoutDone = false;

  @override
  void initState() {
    super.initState();
    // Use a post-frame callback to ensure the widget is in the tree before we build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _buildPageContent();
      }
    });
  }

  Future<void> _buildPageContent() async {
    final List<Widget> currentWidgets = [];
    int currentBlockIndex = widget.startingBlockIndex;
    int endingBlockIndex = widget.startingBlockIndex;

    // Use available height from viewSize, accounting for padding.
    final double availableHeight = widget.viewSize.height - 80; // Approx vertical padding

    while (currentBlockIndex < widget.allBlocks.length) {
      final block = widget.allBlocks[currentBlockIndex];

      // Add the next block to our list of widgets for this page
      currentWidgets.add(HtmlContentWidget(
        key: ValueKey(block.id),
        block: block,
        blockIndex: currentBlockIndex,
        viewSize: widget.viewSize,
      ));

      // This is the core trick: we temporarily update the UI with the new widget,
      // wait for Flutter to render it, and then measure the total height.
      setState(() {
        _pageContent.clear();
        _pageContent.addAll(currentWidgets);
      });

      // Wait for the next frame to be rendered.
      await Future.delayed(Duration.zero);
      if (!mounted) return;

      // Measure the height of the column.
      final RenderBox? renderBox = _columnKey.currentContext?.findRenderObject() as RenderBox?;

      if (renderBox != null && renderBox.size.height > availableHeight) {
        // --- OVERFLOW DETECTED ---
        // The last widget we added made the column too tall.
        // Remove it from our list.
        currentWidgets.removeLast();

        // Update the UI one last time to show the page without the overflowing widget.
        setState(() {
          _pageContent.clear();
          _pageContent.addAll(currentWidgets);
        });

        // Break the loop, this page is full.
        break;
      } else {
        // The widget fits. Update the ending index and continue to the next block.
        endingBlockIndex = currentBlockIndex;
        currentBlockIndex++;
      }
    }

    if (mounted && !_isLayoutDone) {
      _isLayoutDone = true;
      print("  -> [BookPageWidget] Page ${widget.pageIndex} layout complete. Starts at ${widget.startingBlockIndex}, ends at $endingBlockIndex.");
      // Report our findings back to the controller.
      widget.onPageBuilt(widget.pageIndex, widget.startingBlockIndex, endingBlockIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    // This SingleChildScrollView prevents overflow errors during the build process.
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        key: _columnKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _pageContent,
      ),
    );
  }
}