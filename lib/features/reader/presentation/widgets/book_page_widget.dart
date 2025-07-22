import 'package:flutter/material.dart';
import 'package:visualit/features/reader/data/book_data.dart' as isar_models;
import 'package:visualit/features/reader/data/new_models.dart' as new_models;
import 'package:visualit/features/reader/presentation/widgets/html_content_widget.dart';

class BookPageWidget extends StatefulWidget {
  final dynamic _allBlocks;
  final int startingBlockIndex;
  final Size viewSize;
  final Function(int pageIndex, int startingBlock, int endingBlock) onPageBuilt;
  final int pageIndex;

  // Internal flag to track the type of blocks
  final bool _isIsarModel;

  // Constructor for isar_models.ContentBlock list
  const BookPageWidget.fromIsarModel({
    super.key,
    required List<isar_models.ContentBlock> allBlocks,
    required this.startingBlockIndex,
    required this.viewSize,
    required this.onPageBuilt,
    required this.pageIndex,
  }) : _allBlocks = allBlocks, _isIsarModel = true;

  // Constructor for new_models.ContentBlock list
  const BookPageWidget.fromNewModel({
    super.key,
    required List<new_models.ContentBlock> allBlocks,
    required this.startingBlockIndex,
    required this.viewSize,
    required this.onPageBuilt,
    required this.pageIndex,
  }) : _allBlocks = allBlocks, _isIsarModel = false;

  // Factory constructor to handle either type
  factory BookPageWidget({
    Key? key,
    required dynamic allBlocks,
    required int startingBlockIndex,
    required Size viewSize,
    required Function(int pageIndex, int startingBlock, int endingBlock) onPageBuilt,
    required int pageIndex,
  }) {
    if (allBlocks is List<isar_models.ContentBlock>) {
      return BookPageWidget.fromIsarModel(
        key: key,
        allBlocks: allBlocks,
        startingBlockIndex: startingBlockIndex,
        viewSize: viewSize,
        onPageBuilt: onPageBuilt,
        pageIndex: pageIndex,
      );
    } else if (allBlocks is List<new_models.ContentBlock>) {
      return BookPageWidget.fromNewModel(
        key: key,
        allBlocks: allBlocks,
        startingBlockIndex: startingBlockIndex,
        viewSize: viewSize,
        onPageBuilt: onPageBuilt,
        pageIndex: pageIndex,
      );
    } else {
      throw ArgumentError('allBlocks must be either List<isar_models.ContentBlock> or List<new_models.ContentBlock>');
    }
  }

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

  // Helper method to get the length of the blocks list
  int get _blocksLength {
    if (widget._isIsarModel) {
      return (widget._allBlocks as List<isar_models.ContentBlock>).length;
    } else {
      return (widget._allBlocks as List<new_models.ContentBlock>).length;
    }
  }

  // Helper method to get a block at a specific index
  dynamic _getBlockAt(int index) {
    if (widget._isIsarModel) {
      return (widget._allBlocks as List<isar_models.ContentBlock>)[index];
    } else {
      return (widget._allBlocks as List<new_models.ContentBlock>)[index];
    }
  }

  Future<void> _buildPageContent() async {
    if (!mounted) return;

    final List<Widget> currentWidgets = [];
    int currentBlockIndex = widget.startingBlockIndex;
    final double availableHeight = widget.viewSize.height - 60;

    while (currentBlockIndex < _blocksLength) {
      final block = _getBlockAt(currentBlockIndex);
      // Pass the block's absolute index to the widget.
      currentWidgets.add(HtmlContentWidget(
          block: block,
          blockIndex: currentBlockIndex,
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
