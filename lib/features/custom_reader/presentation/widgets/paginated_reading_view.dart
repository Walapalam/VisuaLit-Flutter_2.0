import 'dart:io';
import 'package:flutter/material.dart';

import 'package:visualit/features/custom_reader/application/epub_paginator_service.dart';

class PaginatedReadingView extends StatefulWidget {
  final List<PageContent> pages;
  final int initialPageIndex;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onNextChapter;
  final VoidCallback onPreviousChapter;
  final Widget Function(String src)? imageBuilder;
  final EdgeInsetsGeometry padding;

  const PaginatedReadingView({
    Key? key,
    required this.pages,
    required this.initialPageIndex,
    required this.onPageChanged,
    required this.onNextChapter,
    required this.onPreviousChapter,
    this.imageBuilder,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  State<PaginatedReadingView> createState() => _PaginatedReadingViewState();
}

class _PaginatedReadingViewState extends State<PaginatedReadingView> {
  late PageController _pageController;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPageIndex);
  }

  @override
  void didUpdateWidget(PaginatedReadingView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPageIndex != oldWidget.initialPageIndex) {
      _pageController.jumpToPage(widget.initialPageIndex);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (details) {
        final width = MediaQuery.of(context).size.width;
        final dx = details.globalPosition.dx;
        if (dx < width * 0.3) {
          // Left tap
          if (_pageController.page! > 0) {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else {
            widget.onPreviousChapter();
          }
        } else if (dx > width * 0.7) {
          // Right tap
          if (_pageController.page! < widget.pages.length - 1) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else {
            widget.onNextChapter();
          }
        }
      },
      child: Listener(
        onPointerMove: (details) {
          // Detect edge swipes for chapter navigation
          if (widget.pages.isEmpty) return;

          final double delta = details.delta.dx;
          if (delta.abs() < 5) return; // Ignore small movements

          // Check if we are at the edges
          if (_pageController.hasClients) {
            final page = _pageController.page ?? 0.0;
            final isFirstPage = page <= 0.0;
            final isLastPage = page >= widget.pages.length - 1;

            if (isFirstPage && delta > 10) {
              // Swiping Right on First Page -> Previous Chapter
              // Debounce manual call to avoid multiple triggers
              if (!_isNavigating) {
                _isNavigating = true;
                widget.onPreviousChapter();
                Future.delayed(
                  const Duration(seconds: 1),
                  () => _isNavigating = false,
                );
              }
            } else if (isLastPage && delta < -10) {
              // Swiping Left on Last Page -> Next Chapter
              if (!_isNavigating) {
                _isNavigating = true;
                widget.onNextChapter();
                Future.delayed(
                  const Duration(seconds: 1),
                  () => _isNavigating = false,
                );
              }
            }
          }
        },
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.pages.length,
          onPageChanged: widget.onPageChanged,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final page = widget.pages[index];

            // Combine blocks into a single TextSpan for selection
            final List<InlineSpan> spans = [];

            for (final block in page.blocks) {
              if (block is TextBlock) {
                spans.add(block.content);
                // Add a newline if it's a block element?
                // Actually, our blocks are usually paragraphs.
                // We might need to add a newline at the end of each block to ensure separation.
                // But TextSpan doesn't automatically add newlines.
                // Let's check if the content already has a newline.
                if (!block.content.toPlainText().endsWith('\n')) {
                  spans.add(const TextSpan(text: '\n'));
                }
              } else if (block is ImageBlock) {
                Widget imageWidget;
                if (widget.imageBuilder != null) {
                  imageWidget = widget.imageBuilder!(block.src);
                } else if (block.src.startsWith('http')) {
                  imageWidget = Image.network(block.src);
                } else {
                  imageWidget = Image.file(File(block.src));
                }

                spans.add(
                  WidgetSpan(
                    child: imageWidget,
                    alignment: PlaceholderAlignment.middle,
                  ),
                );
                spans.add(const TextSpan(text: '\n'));
              } else if (block is SpacingBlock) {
                // Use a newline with specific font size to create exact vertical spacing
                // This avoids WidgetSpan alignment issues and ensures the space is rendered
                if (block.height > 0) {
                  spans.add(
                    TextSpan(
                      text: '\n',
                      style: TextStyle(
                        fontSize: block.height,
                        height: 0.5,
                        // Ensure no color/decoration affects this empty space
                        color: Colors.transparent,
                      ),
                    ),
                  );
                }
              }
            }

            return SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: widget.padding,
                child: SelectableText.rich(
                  TextSpan(children: spans),
                  textAlign: TextAlign.justify,
                  onSelectionChanged: (selection, cause) {
                    // Handle selection change if needed
                    if (selection.baseOffset != selection.extentOffset) {
                      // print('Selection: ${selection.baseOffset} - ${selection.extentOffset}');
                    }
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
