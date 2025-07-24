import 'package:flutter/material.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/presentation/widgets/html_content_widget.dart';

class BookPageWidget extends StatefulWidget {
  final List<ContentBlock> allBlocks;
  final int startingBlockIndex;
  final Size viewSize;
  final Function(int pageIndex, int startingBlock, int endingBlock) onPageBuilt;
  final int pageIndex;
  final double verticalPadding;

  const BookPageWidget({
    super.key,
    required this.allBlocks,
    required this.startingBlockIndex,
    required this.viewSize,
    required this.onPageBuilt,
    required this.pageIndex,
    required this.verticalPadding,
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
    final double availableHeight = widget.viewSize.height - widget.verticalPadding;

    while (currentBlockIndex < widget.allBlocks.length) {
      final block = widget.allBlocks[currentBlockIndex];

      currentWidgets.add(HtmlContentWidget(
        key: ValueKey(block.id),
        block: block,
        blockIndex: currentBlockIndex,
        viewSize: widget.viewSize,
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
        endingBlockIndex = currentBlockIndex;
        currentBlockIndex++;
      }
    }

    if (currentWidgets.isEmpty && widget.startingBlockIndex < widget.allBlocks.length) {
      final block = widget.allBlocks[widget.startingBlockIndex];
      currentWidgets.add(HtmlContentWidget(
        key: ValueKey(block.id),
        block: block,
        blockIndex: widget.startingBlockIndex,
        viewSize: widget.viewSize,
      ));
      endingBlockIndex = widget.startingBlockIndex;
      setState(() {
        _pageContent.clear();
        _pageContent.addAll(currentWidgets);
      });
    }

    if (mounted && !_isLayoutDone) {
      _isLayoutDone = true;
      widget.onPageBuilt(widget.pageIndex, widget.startingBlockIndex, endingBlockIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
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