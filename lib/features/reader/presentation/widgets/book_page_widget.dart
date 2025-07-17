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
      final List<Widget> currentWidgets = [];
      int currentBlockIndex = widget.startingBlockIndex;
      final double availableHeight = widget.viewSize.height - 60;

      debugPrint("[DEBUG] BookPageWidget: Available height: $availableHeight, total blocks: ${widget.allBlocks.length}");

      int attemptedBlocks = 0;
      while (currentBlockIndex < widget.allBlocks.length) {
        attemptedBlocks++;
        try {
          final block = widget.allBlocks[currentBlockIndex];
          debugPrint("[DEBUG] BookPageWidget: Adding block $currentBlockIndex (type: ${block.blockType})");

          // Pass the block's absolute index to the widget.
          currentWidgets.add(HtmlContentWidget(
              block: block,
              blockIndex: currentBlockIndex, // <-- THE FIX
              viewSize: widget.viewSize
          ));

          setState(() {
            _pageContent.clear();
            _pageContent.addAll(currentWidgets);
          });

          await Future.delayed(Duration.zero);
          if (!mounted) {
            debugPrint("[DEBUG] BookPageWidget: Widget no longer mounted during build, exiting");
            return;
          }

          final RenderBox? renderBox = _columnKey.currentContext?.findRenderObject() as RenderBox?;
          if (renderBox == null) {
            debugPrint("[WARN] BookPageWidget: RenderBox is null, cannot measure height");
            break;
          }

          final currentHeight = renderBox.size.height;
          debugPrint("[DEBUG] BookPageWidget: Current height: $currentHeight / $availableHeight");

          if (currentHeight > availableHeight) {
            debugPrint("[DEBUG] BookPageWidget: Page height exceeded, removing last block");
            currentWidgets.removeLast();
            setState(() {
              _pageContent.clear();
              _pageContent.addAll(currentWidgets);
            });
            break;
          } else {
            _endingBlockIndex = currentBlockIndex;
            currentBlockIndex++;
          }
        } catch (e) {
          debugPrint("[ERROR] BookPageWidget: Error processing block $currentBlockIndex: $e");
          // Skip this block and continue with the next one
          currentBlockIndex++;
        }
      }

      if(mounted && !_isLayoutDone) {
        _isLayoutDone = true;
        final blocksOnPage = _endingBlockIndex - widget.startingBlockIndex + 1;
        debugPrint("[DEBUG] BookPageWidget: Page ${widget.pageIndex} layout complete. Starts at ${widget.startingBlockIndex}, ends at $_endingBlockIndex (${blocksOnPage} blocks)");
        debugPrint("[DEBUG] BookPageWidget: Attempted to add $attemptedBlocks blocks, successfully added ${currentWidgets.length}");

        widget.onPageBuilt(widget.pageIndex, widget.startingBlockIndex, _endingBlockIndex);
      }
    } catch (e, stack) {
      debugPrint("[ERROR] BookPageWidget: Error building page content: $e");
      debugPrintStack(stackTrace: stack);
    }
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
