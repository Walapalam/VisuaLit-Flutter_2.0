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

  PageContent({required this.blocks, required this.pageIndex});
}

abstract class RenderBlock {}

class TextBlock extends RenderBlock {
  final String text;
  final TextStyle style;
  final String? tag; // p, h1, etc.

  TextBlock({required this.text, required this.style, this.tag});
}

class ImageBlock extends RenderBlock {
  final String src;
  final double? width;
  final double? height;

  ImageBlock({required this.src, this.width, this.height});
}

class EpubPaginatorService {
  final Isar isar;

  EpubPaginatorService(this.isar);

  Future<List<PageContent>> paginateChapter({
    required int bookId,
    required String chapterHref,
    required String htmlContent,
    required TextStyle baseStyle,
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
      return _restorePagesFromCache(cached.pageBreaks, htmlContent, baseStyle);
    }

    // 2. Parse HTML to Blocks
    final blocks = _parseHtmlToBlocks(htmlContent, baseStyle);

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
  ) async {
    final blocks = _parseHtmlToBlocks(htmlContent, baseStyle);
    final pages = <PageContent>[];

    // Reconstruct pages based on breaks
    // This is a simplified reconstruction. For robust restoration, we need to know exactly which blocks go where.
    // Since we store "pageBreaks" as JSON, let's parse it.

    int currentBlockIndex = 0;

    for (int i = 0; i < pageBreaks.length; i++) {
      final breakInfo = jsonDecode(pageBreaks[i]);
      final endBlockIndex = breakInfo['endBlockIndex'] as int;

      final pageBlocks = blocks.sublist(currentBlockIndex, endBlockIndex + 1);
      pages.add(PageContent(blocks: pageBlocks, pageIndex: i));

      currentBlockIndex = endBlockIndex + 1;
    }

    // Add remaining blocks if any (shouldn't happen if cache is correct)
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
      // We store the index of the LAST block in this page relative to the whole chapter
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

  List<RenderBlock> _parseHtmlToBlocks(String html, TextStyle baseStyle) {
    final document = html_parser.parse(html);
    final blocks = <RenderBlock>[];

    // Recursive helper to traverse DOM
    void traverse(html_dom.Node node, TextStyle currentStyle) {
      if (node.nodeType == html_dom.Node.TEXT_NODE) {
        final text = node.text?.trim();
        if (text != null && text.isNotEmpty) {
          blocks.add(TextBlock(text: text, style: currentStyle));
        }
      } else if (node.nodeType == html_dom.Node.ELEMENT_NODE) {
        final element = node as html_dom.Element;

        // Handle Images
        if (element.localName == 'img') {
          final src = element.attributes['src'];
          if (src != null) {
            blocks.add(ImageBlock(src: src));
          }
          return;
        }

        // Handle Styles
        var nextStyle = currentStyle;
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
        } else if (element.localName == 'p') {
          // Paragraphs usually add a newline or spacing, handled in layout
        } else if (element.localName == 'b' || element.localName == 'strong') {
          nextStyle = currentStyle.copyWith(fontWeight: FontWeight.bold);
        } else if (element.localName == 'i' || element.localName == 'em') {
          nextStyle = currentStyle.copyWith(fontStyle: FontStyle.italic);
        }

        for (final child in node.nodes) {
          traverse(child, nextStyle);
        }

        // Add block spacing after block elements
        if (['p', 'h1', 'h2', 'h3', 'div'].contains(element.localName)) {
          // We might need a "SpacingBlock" or handle it in layout
        }
      }
    }

    traverse(document.body ?? document, baseStyle);
    return blocks;
  }

  Future<List<PageContent>> _layoutBlocks(
    List<RenderBlock> blocks,
    Size pageSize,
    EdgeInsets padding,
  ) async {
    final pages = <PageContent>[];
    var currentBlocks = <RenderBlock>[];
    double currentHeight = padding.top;
    final contentWidth = pageSize.width - padding.horizontal;
    // Add a safety margin to prevent slight overflows due to rendering differences
    final maxHeight = pageSize.height - padding.bottom - 20.0;

    for (int i = 0; i < blocks.length; i++) {
      final block = blocks[i];

      // Yield to UI thread every 50 blocks to prevent freeze
      if (i % 50 == 0) {
        await Future.delayed(Duration.zero);
      }

      if (block is TextBlock) {
        final textSpan = TextSpan(text: block.text, style: block.style);
        final painter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        painter.layout(maxWidth: contentWidth);

        if (currentHeight + painter.height > maxHeight) {
          // Block doesn't fit. Try to split it?
          // For MVP, we just push to next page if it's not huge.
          // If it's huge (larger than a page), we MUST split it.

          if (painter.height > maxHeight - padding.top) {
            // TODO: Implement splitting logic
            // For now, push to next page
            pages.add(
              PageContent(
                blocks: List.from(currentBlocks),
                pageIndex: pages.length,
              ),
            );
            currentBlocks = [block];
            currentHeight = padding.top + painter.height;
          } else {
            // Push to next page
            pages.add(
              PageContent(
                blocks: List.from(currentBlocks),
                pageIndex: pages.length,
              ),
            );
            currentBlocks = [block];
            currentHeight = padding.top + painter.height;
          }
        } else {
          currentBlocks.add(block);
          currentHeight += painter.height;
        }
      } else if (block is ImageBlock) {
        // Estimate image height (placeholder)
        const imageHeight = 200.0;
        if (currentHeight + imageHeight > maxHeight) {
          pages.add(
            PageContent(
              blocks: List.from(currentBlocks),
              pageIndex: pages.length,
            ),
          );
          currentBlocks = [block];
          currentHeight = padding.top + imageHeight;
        } else {
          currentBlocks.add(block);
          currentHeight += imageHeight;
        }
      }
    }

    if (currentBlocks.isNotEmpty) {
      pages.add(PageContent(blocks: currentBlocks, pageIndex: pages.length));
    }

    return pages;
  }
}
