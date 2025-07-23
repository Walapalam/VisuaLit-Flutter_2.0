import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';

class PageContentWidget extends ConsumerStatefulWidget {
  final List<ContentBlock> chapterBlocks;
  final ReadingPreferences preferences;
  final int currentPage;
  final double pageHeight;
  final Function(int, double) onLayoutCalculated;
  final int chapterIndex;

  const PageContentWidget({
    super.key,
    required this.chapterBlocks,
    required this.preferences,
    required this.currentPage,
    required this.pageHeight,
    required this.onLayoutCalculated,
    required this.chapterIndex,
  });

  @override
  ConsumerState<PageContentWidget> createState() => _PageContentWidgetState();
}

class _PageContentWidgetState extends ConsumerState<PageContentWidget> {
  final GlobalKey _contentKey = GlobalKey();
  String? _fullHtmlContent;
  bool _hasCalculated = false;

  @override
  void initState() {
    super.initState();
    _prepareHtml();
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculateAndReportHeight());
  }

  void _prepareHtml() {
    final buffer = StringBuffer();
    for (var block in widget.chapterBlocks) {
      if (block.htmlContent != null) {
        buffer.writeln(block.htmlContent);
      }
    }
    _fullHtmlContent = buffer.toString();
  }

  void _calculateAndReportHeight() {
    if (_hasCalculated || !mounted) return;

    final context = _contentKey.currentContext;
    if (context == null) {
      Future.delayed(const Duration(milliseconds: 50), _calculateAndReportHeight);
      return;
    }
    final renderBox = context.findRenderObject() as RenderBox;
    final totalHeight = renderBox.size.height;
    print("  - [PageContentWidget] Calculated total height for chapter ${widget.chapterIndex}: $totalHeight");

    // Set flag to prevent recalculating on every rebuild
    _hasCalculated = true;
    widget.onLayoutCalculated(widget.chapterIndex, totalHeight);
  }

  @override
  Widget build(BuildContext context) {
    final offset = -widget.currentPage * widget.pageHeight;

    return ClipRect(
      child: Transform.translate(
        offset: Offset(0, offset),
        child: Column(
          key: _contentKey,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            HtmlWidget(
              _fullHtmlContent ?? '',
              textStyle: widget.preferences.getStyleForBlock(BlockType.p),
            ),
          ],
        ),
      ),
    );
  }
}