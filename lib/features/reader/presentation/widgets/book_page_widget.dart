import 'package:flutter/material.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/presentation/widgets/html_content_widget.dart';
import 'package:visualit/features/reader/presentation/reading_screen.dart'; // Contains the TextHighlight model.

        // If TextHighlight is not imported, define a minimal version for compilation:
        class TextHighlight {
          final int blockIndex;
          final int startOffset;
          final int endOffset;
          final Color color;
          TextHighlight({required this.blockIndex, required this.startOffset, required this.endOffset, required this.color});
        }

        /// A widget that represents a single, paginated "page" of a book.
        class BookPageWidget extends StatefulWidget {
          final List<ContentBlock> allBlocks;
          final int startingBlockIndex;
          final Size viewSize;
          final Function(int pageIndex, int startingBlock, int endingBlock) onPageBuilt;
          final int pageIndex;
          final List<TextHighlight> highlights;
          final void Function(TextSelection?, RenderObject?, int, String?)? onSelectionChanged;

          const BookPageWidget({
            super.key,
            required this.allBlocks,
            required this.startingBlockIndex,
            required this.viewSize,
            required this.onPageBuilt,
            required this.pageIndex,
            this.highlights = const [],
            this.onSelectionChanged,
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

            while (currentBlockIndex < widget.allBlocks.length) {
              final block = widget.allBlocks[currentBlockIndex];

              // Null-safe access to blockIndex
              final blockHighlights = widget.highlights.where((h) => h.blockIndex == currentBlockIndex).toList();

              currentWidgets.add(HtmlContentWidget(
                key: ValueKey('block_${block.id}_${block.chapterIndex}_${block.blockIndexInChapter}'),
                block: block,
                blockIndex: currentBlockIndex,
                viewSize: widget.viewSize,
                highlights: blockHighlights,
                onSelectionChanged: (selection, renderObject, blockTextContent) {
                  widget.onSelectionChanged?.call(selection, renderObject, currentBlockIndex, blockTextContent);
                },
              ));

              setState(() {
                _pageContent.clear();
                _pageContent.addAll(currentWidgets);
              });

              await Future.delayed(Duration.zero);
              if (!mounted) return;

              final RenderBox? renderBox = _columnKey.currentContext?.findRenderObject() as RenderBox?;
              if (renderBox != null) {
                if (renderBox.size.height > availableHeight && currentWidgets.isNotEmpty) {
                  currentWidgets.removeLast();
                  setState(() {
                    _pageContent.clear();
                    _pageContent.addAll(currentWidgets);
                  });
                  break;
                }
              }

              _endingBlockIndex = currentBlockIndex;
              currentBlockIndex++;
            }

            if (mounted && !_isLayoutDone) {
              _isLayoutDone = true;
              debugPrint("  [BookPageWidget] Page ${widget.pageIndex} layout complete. Starts at ${widget.startingBlockIndex}, ends at $_endingBlockIndex.");
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