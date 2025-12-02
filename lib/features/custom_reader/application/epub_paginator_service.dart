import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as html_dom;
import 'package:visualit/features/reader/data/pagination_cache.dart';
import 'package:isar/isar.dart';
import 'package:crypto/crypto.dart';

class PageContent {
  final List<RenderBlock> blocks;
  final int pageIndex;
  final int textStartIndex; // Global index of the first character on this page

  PageContent({
    required this.blocks,
    required this.pageIndex,
    this.textStartIndex = 0,
  });
}

abstract class RenderBlock {}

class TextBlock extends RenderBlock {
  final TextSpan content;

  TextBlock({required this.content});
}

class ImageBlock extends RenderBlock {
  final String src;
  final double? width;
  final double? height;

  ImageBlock({required this.src, this.width, this.height});
}

class SpacingBlock extends RenderBlock {
  final double height;

  SpacingBlock({required this.height});
}

class EpubPaginatorService {
  final Isar isar;

  EpubPaginatorService(this.isar);

  Future<List<PageContent>> paginateChapter({
    required int bookId,
    required String chapterHref,
    required String htmlContent,
    required TextStyle baseStyle,
    Map<String, TextStyle>? tagStyles,
    required Size pageSize,
    required EdgeInsets padding,
  }) async {
    final settingsHash = _generateSettingsHash(baseStyle, pageSize, padding);

    // 1. Check Cache
    final cached = await isar.paginationCaches
        .filter()
        .bookIdEqualTo(bookId)
        .chapterHrefEqualTo(chapterHref)
        .settingsHashEqualTo(settingsHash)
        .findFirst();

    if (cached != null) {
      return _restorePagesFromCache(
        cached.pageBreaks,
        htmlContent,
        baseStyle,
        tagStyles,
      );
    }

    // 2. Parse HTML to Blocks
    final blocks = _parseHtmlToBlocks(htmlContent, baseStyle, tagStyles);

    // 3. Paginate Blocks
    final pages = await _layoutBlocks(blocks, pageSize, padding);

    // 4. Save to Cache
    await _saveToCache(bookId, chapterHref, settingsHash, pages);

    return pages;
  }

  Future<List<PageContent>> _restorePagesFromCache(
    List<String> pageBreaks,
    String htmlContent,
    TextStyle baseStyle,
    Map<String, TextStyle>? tagStyles,
  ) async {
    final blocks = _parseHtmlToBlocks(htmlContent, baseStyle, tagStyles);
    final pages = <PageContent>[];

    // Reconstruct pages based on breaks
    int currentBlockIndex = 0;

    for (int i = 0; i < pageBreaks.length; i++) {
      final breakInfo = jsonDecode(pageBreaks[i]);
      final endBlockIndex = breakInfo['endBlockIndex'] as int;

      if (currentBlockIndex < blocks.length && endBlockIndex < blocks.length) {
        final pageBlocks = blocks.sublist(currentBlockIndex, endBlockIndex + 1);
        pages.add(PageContent(blocks: pageBlocks, pageIndex: i));
      }

      currentBlockIndex = endBlockIndex + 1;
    }

    // Add remaining blocks if any
    if (currentBlockIndex < blocks.length) {
      pages.add(
        PageContent(
          blocks: blocks.sublist(currentBlockIndex),
          pageIndex: pages.length,
        ),
      );
    }

    return pages;
  }

  Future<void> _saveToCache(
    int bookId,
    String chapterHref,
    String settingsHash,
    List<PageContent> pages,
  ) async {
    final pageBreaks = <String>[];
    int currentBlockCount = 0;

    for (final page in pages) {
      currentBlockCount += page.blocks.length;
      pageBreaks.add(jsonEncode({'endBlockIndex': currentBlockCount - 1}));
    }

    final cache = PaginationCache()
      ..bookId = bookId
      ..chapterHref = chapterHref
      ..settingsHash = settingsHash
      ..pageBreaks = pageBreaks;

    await isar.writeTxn(() async {
      await isar.paginationCaches.put(cache);
    });
  }

  String _generateSettingsHash(TextStyle style, Size size, EdgeInsets padding) {
    final key =
        '${style.fontSize}_${style.height}_${style.fontFamily}_'
        '${size.width}_${size.height}_${padding.toString()}';
    return md5.convert(utf8.encode(key)).toString();
  }

  List<RenderBlock> _parseHtmlToBlocks(
    String html,
    TextStyle baseStyle,
    Map<String, TextStyle>? tagStyles,
  ) {
    final document = html_parser.parse(html);
    final blocks = <RenderBlock>[];
    List<InlineSpan> currentSpans = [];

    void flushBuffer() {
      if (currentSpans.isNotEmpty) {
        blocks.add(
          TextBlock(content: TextSpan(children: List.from(currentSpans))),
        );
        currentSpans.clear();
      }
    }

    // Recursive helper to traverse DOM
    void traverse(html_dom.Node node, TextStyle currentStyle) {
      if (node.nodeType == html_dom.Node.TEXT_NODE) {
        final text = node.text; // Don't trim blindly, might need spaces
        if (text != null && text.isNotEmpty) {
          // Collapse whitespace but preserve single spaces between words
          final cleanText = text.replaceAll(RegExp(r'\s+'), ' ');
          if (cleanText.isNotEmpty) {
            currentSpans.add(TextSpan(text: cleanText, style: currentStyle));
          }
        }
      } else if (node.nodeType == html_dom.Node.ELEMENT_NODE) {
        final element = node as html_dom.Element;

        // Handle Images - Block level
        if (element.localName == 'img') {
          flushBuffer(); // Images break text flow
          final src = element.attributes['src'];
          if (src != null) {
            blocks.add(ImageBlock(src: src));
          }
          return;
        }

        // Handle Block Elements
        final isBlock = [
          'p',
          'div',
          'h1',
          'h2',
          'h3',
          'h4',
          'h5',
          'h6',
          'li',
          'br',
        ].contains(element.localName);

        if (isBlock) {
          flushBuffer();
        }

        // Handle Styles
        var nextStyle = currentStyle;

        if (tagStyles != null && tagStyles.containsKey(element.localName)) {
          nextStyle = currentStyle.merge(tagStyles[element.localName]);
        } else {
          // Fallback defaults
          if (element.localName == 'h1') {
            nextStyle = currentStyle.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            );
          } else if (element.localName == 'h2') {
            nextStyle = currentStyle.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            );
          } else if (element.localName == 'b' ||
              element.localName == 'strong') {
            nextStyle = currentStyle.copyWith(fontWeight: FontWeight.bold);
          } else if (element.localName == 'i' || element.localName == 'em') {
            nextStyle = currentStyle.copyWith(fontStyle: FontStyle.italic);
          }
        }

        if (element.localName == 'br') {
          currentSpans.add(const TextSpan(text: '\n'));
        }

        for (final child in node.nodes) {
          traverse(child, nextStyle);
        }

        // Post-element handling
        if (isBlock) {
          flushBuffer();
          // Add spacing after block elements
          if (element.localName == 'p' || element.localName == 'div') {
            blocks.add(
              SpacingBlock(height: (baseStyle.fontSize ?? 16.0) * 0.8),
            );
          } else if (['h1', 'h2', 'h3'].contains(element.localName)) {
            blocks.add(
              SpacingBlock(height: (baseStyle.fontSize ?? 16.0) * 0.5),
            );
          }
        }
      }
    }

    traverse(document.body ?? document, baseStyle);
    flushBuffer(); // Final flush
    return blocks;
  }

  // Helper to split a TextSpan tree at a given character index
  // Returns [firstPart, secondPart]
  List<TextSpan?> _splitTextSpan(TextSpan span, int splitIndex) {
    if (splitIndex <= 0) return [null, span];
    final fullText = span.toPlainText();
    if (splitIndex >= fullText.length) return [span, null];

    // If no children, simple substring
    if (span.children == null || span.children!.isEmpty) {
      final text = span.text ?? '';
      if (text.isEmpty) return [null, null];

      final firstText = text.substring(0, splitIndex);
      final secondText = text.substring(splitIndex);

      return [
        TextSpan(text: firstText, style: span.style),
        TextSpan(text: secondText, style: span.style),
      ];
    }

    // If children, traverse
    final firstChildren = <InlineSpan>[];
    final secondChildren = <InlineSpan>[];
    int currentCount = 0;
    bool splitFound = false;

    for (final child in span.children!) {
      if (splitFound) {
        secondChildren.add(child);
        continue;
      }

      final childLength = child.toPlainText().length;

      if (currentCount + childLength <= splitIndex) {
        firstChildren.add(child);
        currentCount += childLength;
      } else {
        // Split happens in this child
        if (child is TextSpan) {
          final localSplitIndex = splitIndex - currentCount;
          final splitResult = _splitTextSpan(child, localSplitIndex);

          if (splitResult[0] != null) firstChildren.add(splitResult[0]!);
          if (splitResult[1] != null) secondChildren.add(splitResult[1]!);
        } else {
          // Non-TextSpan (e.g. WidgetSpan) - cannot split inside.
          // Decide which side it goes to based on where the split falls.
          // For now, if we are here, it means the split point is INSIDE this atomic span.
          // We put it in the second part to avoid cutting it off?
          // Or first? Let's put it in the second part to be safe (push to next page).
          secondChildren.add(child);
        }
        splitFound = true;
      }
    }

    return [
      TextSpan(style: span.style, children: firstChildren),
      TextSpan(style: span.style, children: secondChildren),
    ];
  }

  Future<List<PageContent>> _layoutBlocks(
    List<RenderBlock> blocks,
    Size pageSize,
    EdgeInsets padding,
  ) async {
    final pages = <PageContent>[];
    var currentBlocks = <RenderBlock>[];
    double currentHeight = padding.top;
    int currentTextIndex = 0; // Track global text index
    int pageStartIndex = 0; // Start index for the current page

    final contentWidth = pageSize.width - padding.horizontal;
    // Add a safety margin to prevent slight overflows due to rendering differences
    // We subtract an extra 180.0 to be safe and avoid the rounded corners
    final maxHeight = pageSize.height - padding.bottom - 180.0;

    for (int i = 0; i < blocks.length; i++) {
      final block = blocks[i];

      // Yield to UI thread every 50 blocks to prevent freeze
      if (i % 50 == 0) {
        await Future.delayed(Duration.zero);
      }

      if (block is TextBlock) {
        final textSpan = block.content;
        final painter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
          // Use StrutStyle from the first span's style or a default to ensure consistent line heights
          strutStyle: StrutStyle.fromTextStyle(
            textSpan.style ??
                textSpan.children?.first.style ??
                const TextStyle(),
          ),
        );
        painter.layout(maxWidth: contentWidth);

        if (currentHeight + painter.height <= maxHeight) {
          currentBlocks.add(block);
          currentHeight += painter.height;
          currentTextIndex += textSpan.toPlainText().length;
        } else {
          // Block doesn't fit. Try to split it.
          final remainingHeight = maxHeight - currentHeight;
          print('DEBUG: Block fits? NO. Remaining height: $remainingHeight');

          // If remaining height is too small, just push to next page
          if (remainingHeight < 50) {
            print(
              'DEBUG: Remaining height too small (<50), pushing to next page.',
            );
            if (currentBlocks.isNotEmpty) {
              pages.add(
                PageContent(
                  blocks: List.from(currentBlocks),
                  pageIndex: pages.length,
                  textStartIndex: pageStartIndex,
                ),
              );
              pageStartIndex =
                  currentTextIndex; // Update start index for next page
              currentBlocks = [];
              currentHeight = padding.top;
            }

            // Check if it fits on new page
            painter.layout(maxWidth: contentWidth);
            if (padding.top + painter.height <= maxHeight) {
              currentBlocks.add(block);
              currentHeight += painter.height;
            } else {
              print('DEBUG: Block too big for new page, forcing split/add.');
              currentBlocks.add(block);
              pages.add(
                PageContent(
                  blocks: List.from(currentBlocks),
                  pageIndex: pages.length,
                ),
              );
              currentBlocks = [];
              currentHeight = padding.top;
            }
          } else {
            // Try to split using line metrics for accuracy
            final metrics = painter.computeLineMetrics();
            double accumulatedHeight = 0;
            int targetLineIndex = -1;

            for (int j = 0; j < metrics.length; j++) {
              final line = metrics[j];
              if (accumulatedHeight + line.height <= remainingHeight) {
                accumulatedHeight += line.height;
                targetLineIndex = j;
              } else {
                break;
              }
            }

            int splitIndex = 0;
            if (targetLineIndex >= 0) {
              // We found at least one line that fits.
              // Get the position at the end of this line.
              // We use the vertical center of the line to be safe.
              final line = metrics[targetLineIndex];
              final lineTop = accumulatedHeight - line.height;
              final lineCenterY = lineTop + (line.height / 2);

              final endPos = painter.getPositionForOffset(
                Offset(contentWidth, lineCenterY),
              );
              splitIndex = endPos.offset;
            }

            print(
              'DEBUG: Split analysis. Remaining: $remainingHeight, Fits lines: ${targetLineIndex + 1}, SplitIndex: $splitIndex',
            );

            if (splitIndex > 0 && splitIndex < textSpan.toPlainText().length) {
              final splitResult = _splitTextSpan(textSpan, splitIndex);
              final firstSpan = splitResult[0];
              final secondSpan = splitResult[1];

              if (firstSpan != null) {
                currentBlocks.add(TextBlock(content: firstSpan));
                currentTextIndex += firstSpan.toPlainText().length;
              }

              pages.add(
                PageContent(
                  blocks: List.from(currentBlocks),
                  pageIndex: pages.length,
                  textStartIndex: pageStartIndex,
                ),
              );
              pageStartIndex = currentTextIndex; // Next page starts here
              currentBlocks = [];
              currentHeight = padding.top;

              if (secondSpan != null) {
                blocks.insert(i + 1, TextBlock(content: secondSpan));
                // We don't increment currentTextIndex here because the loop will process this inserted block next
                // But wait, we inserted it at i+1, so the loop will pick it up.
                // However, we just added firstSpan length.
              }
            } else {
              // Could not split effectively (e.g. first line doesn't fit), push to next page
              print(
                'DEBUG: Could not split (Index $splitIndex). Pushing to next page.',
              );
              if (currentBlocks.isNotEmpty) {
                pages.add(
                  PageContent(
                    blocks: List.from(currentBlocks),
                    pageIndex: pages.length,
                  ),
                );
                currentBlocks = [];
                currentHeight = padding.top;
              }
              currentBlocks.add(block);
              currentHeight += painter.height;
            }
          }
        }
      } else if (block is ImageBlock) {
        // Estimate image height (placeholder)
        const imageHeight = 200.0;
        if (currentHeight + imageHeight > maxHeight) {
          if (currentBlocks.isNotEmpty) {
            pages.add(
              PageContent(
                blocks: List.from(currentBlocks),
                pageIndex: pages.length,
              ),
            );
            currentBlocks = [];
            currentHeight = padding.top;
          }
        }
        currentBlocks.add(block);
        currentHeight += imageHeight;
      } else if (block is SpacingBlock) {
        if (currentHeight + block.height <= maxHeight) {
          currentBlocks.add(block);
          currentHeight += block.height;
        } else {
          // Spacing doesn't fit, ignore it or start new page?
          // Usually spacing at bottom of page is dropped.
          // We'll just drop it if it doesn't fit.
        }
      }
    }

    if (currentBlocks.isNotEmpty) {
      pages.add(
        PageContent(
          blocks: currentBlocks,
          pageIndex: pages.length,
          textStartIndex: pageStartIndex,
        ),
      );
    }

    return pages;
  }
}
