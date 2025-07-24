import 'package:flutter/material.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/presentation/widgets/html_content_widget.dart';

class ScrollContentWidget extends StatelessWidget {
  final List<ContentBlock> allBlocks;
  final Size viewSize;
  final ScrollController scrollController;

  const ScrollContentWidget({
    super.key,
    required this.allBlocks,
    required this.viewSize,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
      itemCount: allBlocks.length,
      itemBuilder: (context, index) {
        final block = allBlocks[index];
        // We reuse our efficient "brick" renderer for each block.
        return HtmlContentWidget(
          key: ValueKey(block.id),
          block: block,
          blockIndex: index,
          viewSize: viewSize,
        );
      },
    );
  }
}