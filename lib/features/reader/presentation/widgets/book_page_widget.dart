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
    _endingBlockIndex = widget.startingBlockIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _buildPageContent();
    });
  }

  Future<void> _buildPageContent() async {
    if (!mounted) return;

    final List<Widget> currentWidgets = [];
    int currentBlockIndex = widget.startingBlockIndex;
    final double availableHeight = widget.viewSize.height - 60;

    // Show a temporary "Formatting..." indicator while building the page
    setState(() {
      _pageContent.clear();
      _pageContent.add(
        const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      );
    });

    while (currentBlockIndex < widget.allBlocks.length) {
      final block = widget.allBlocks[currentBlockIndex];
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
      if (!mounted) return;

      final RenderBox? renderBox = _columnKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.size.height > availableHeight) {
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
    }

    if(mounted && !_isLayoutDone) {
      _isLayoutDone = true;
      print("  [BookPageWidget] Page ${widget.pageIndex} layout complete. Starts at ${widget.startingBlockIndex}, ends at $_endingBlockIndex.");
      widget.onPageBuilt(widget.pageIndex, widget.startingBlockIndex, _endingBlockIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
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
