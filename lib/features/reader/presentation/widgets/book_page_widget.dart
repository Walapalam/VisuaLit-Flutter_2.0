import 'package:flutter/foundation.dart';
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

// Helper class to store the result of a rendering attempt
class _RenderResult {
  final bool fits;
  final List<Widget> widgets;

  _RenderResult({required this.fits, required this.widgets});
}

class _BookPageWidgetState extends State<BookPageWidget> {
  final List<Widget> _pageContent = [];
  final GlobalKey _columnKey = GlobalKey();
  int _endingBlockIndex = 0;
  bool _isLayoutDone = false;

  @override
  void initState() {
    super.initState();
    debugPrint("[DEBUG] BookPageWidget: Initializing page ${widget.pageIndex} starting at block ${widget.startingBlockIndex}");
    _endingBlockIndex = widget.startingBlockIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint("[DEBUG] BookPageWidget: Starting to build page content after first frame");
      _buildPageContent();
    });
  }

  Future<void> _buildPageContent() async {
    if (!mounted) {
      debugPrint("[DEBUG] BookPageWidget: Widget not mounted, skipping build");
      return;
    }

    try {
      debugPrint("[DEBUG] BookPageWidget: Building page ${widget.pageIndex} content");

      // Calculate available height for content
      final double availableHeight = widget.viewSize.height - 60;
      debugPrint("[DEBUG] BookPageWidget: Available height: $availableHeight, total blocks: ${widget.allBlocks.length}");

      // Use a more efficient approach to build the page
      await _buildPageWithBinarySearch(availableHeight);

    } catch (e, stack) {
      debugPrint("[ERROR] BookPageWidget: Error building page content: $e");
      debugPrintStack(stackTrace: stack);

      // Even if there's an error, try to show at least one block
      if (mounted && _pageContent.isEmpty && widget.startingBlockIndex < widget.allBlocks.length) {
        try {
          final block = widget.allBlocks[widget.startingBlockIndex];
          final contentWidget = HtmlContentWidget(
            block: block,
            blockIndex: widget.startingBlockIndex,
            viewSize: widget.viewSize
          );

          setState(() {
            _pageContent.add(contentWidget);
            _endingBlockIndex = widget.startingBlockIndex;
          });

          debugPrint("[DEBUG] BookPageWidget: Added at least one block after error");

          if (!_isLayoutDone) {
            _isLayoutDone = true;
            widget.onPageBuilt(widget.pageIndex, widget.startingBlockIndex, _endingBlockIndex);
          }
        } catch (fallbackError) {
          debugPrint("[ERROR] BookPageWidget: Even fallback rendering failed: $fallbackError");
        }
      }
    }
  }

  // A more efficient pagination algorithm using binary search approach
  Future<void> _buildPageWithBinarySearch(double availableHeight) async {
    // Start with a reasonable estimate of blocks per page
    // This helps reduce the number of iterations needed
    int estimatedBlocksPerPage = 5;

    // Define min and max blocks to try
    int minBlocks = 1;
    int maxBlocks = widget.allBlocks.length - widget.startingBlockIndex;

    // Limit max blocks to a reasonable number to prevent excessive rendering attempts
    maxBlocks = maxBlocks.clamp(1, 50);

    // Track our best result so far
    int bestBlockCount = 0;
    List<Widget> bestWidgets = [];

    debugPrint("[DEBUG] BookPageWidget: Starting binary search pagination with range $minBlocks-$maxBlocks blocks");

    // Binary search to find the optimal number of blocks
    while (minBlocks <= maxBlocks) {
      // Try the middle point
      int midBlocks = (minBlocks + maxBlocks) ~/ 2;

      // Build a page with this many blocks
      final result = await _tryRenderingBlocks(midBlocks, availableHeight);

      if (result.fits) {
        // If it fits, this is a candidate solution
        // Save it and try with more blocks
        bestBlockCount = midBlocks;
        bestWidgets = result.widgets;
        minBlocks = midBlocks + 1;
        debugPrint("[DEBUG] BookPageWidget: $midBlocks blocks fit, trying more");
      } else {
        // If it doesn't fit, try with fewer blocks
        maxBlocks = midBlocks - 1;
        debugPrint("[DEBUG] BookPageWidget: $midBlocks blocks don't fit, trying fewer");
      }
    }

    // If we found a valid solution, use it
    if (bestBlockCount > 0) {
      setState(() {
        _pageContent.clear();
        _pageContent.addAll(bestWidgets);
        _endingBlockIndex = widget.startingBlockIndex + bestBlockCount - 1;
      });

      debugPrint("[DEBUG] BookPageWidget: Final solution: $bestBlockCount blocks");

      if (!_isLayoutDone) {
        _isLayoutDone = true;
        final blocksOnPage = _endingBlockIndex - widget.startingBlockIndex + 1;
        debugPrint("[DEBUG] BookPageWidget: Page ${widget.pageIndex} layout complete. Starts at ${widget.startingBlockIndex}, ends at $_endingBlockIndex ($blocksOnPage blocks)");

        widget.onPageBuilt(widget.pageIndex, widget.startingBlockIndex, _endingBlockIndex);
      }
    } else {
      // If no solution was found, add at least one block
      debugPrint("[WARN] BookPageWidget: Could not find a fitting solution, adding at least one block");

      if (widget.startingBlockIndex < widget.allBlocks.length) {
        final block = widget.allBlocks[widget.startingBlockIndex];
        final contentWidget = HtmlContentWidget(
          block: block,
          blockIndex: widget.startingBlockIndex,
          viewSize: widget.viewSize
        );

        setState(() {
          _pageContent.clear();
          _pageContent.add(contentWidget);
          _endingBlockIndex = widget.startingBlockIndex;
        });

        if (!_isLayoutDone) {
          _isLayoutDone = true;
          widget.onPageBuilt(widget.pageIndex, widget.startingBlockIndex, _endingBlockIndex);
        }
      }
    }
  }

  // Try rendering a specific number of blocks and check if they fit
  Future<_RenderResult> _tryRenderingBlocks(int blockCount, double availableHeight) async {
    if (!mounted) return _RenderResult(fits: false, widgets: []);

    final List<Widget> widgets = [];
    final int endIndex = (widget.startingBlockIndex + blockCount - 1).clamp(0, widget.allBlocks.length - 1);

    // Create widgets for all blocks we want to try
    for (int i = widget.startingBlockIndex; i <= endIndex; i++) {
      try {
        final block = widget.allBlocks[i];
        widgets.add(HtmlContentWidget(
          block: block,
          blockIndex: i,
          viewSize: widget.viewSize
        ));
      } catch (e) {
        debugPrint("[ERROR] BookPageWidget: Error creating widget for block $i: $e");
        // Skip problematic blocks but continue with others
      }
    }

    // If we couldn't create any widgets, return early
    if (widgets.isEmpty) return _RenderResult(fits: false, widgets: []);

    // Set the widgets and wait for layout
    setState(() {
      _pageContent.clear();
      _pageContent.addAll(widgets);
    });

    // Wait for layout to complete
    await Future.delayed(Duration.zero);
    if (!mounted) return _RenderResult(fits: false, widgets: []);

    // Measure the height
    final RenderBox? renderBox = _columnKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      debugPrint("[WARN] BookPageWidget: RenderBox is null, cannot measure height");
      return _RenderResult(fits: false, widgets: []);
    }

    final currentHeight = renderBox.size.height;
    final fits = currentHeight <= availableHeight;

    debugPrint("[DEBUG] BookPageWidget: Tried $blockCount blocks, height: $currentHeight/$availableHeight, fits: $fits");

    return _RenderResult(fits: fits, widgets: widgets);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("[DEBUG] BookPageWidget: Building page ${widget.pageIndex} with ${_pageContent.length} content widgets");
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        key: _columnKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: _pageContent,
      ),
    );
  }
}
