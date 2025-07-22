import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/data/page_cache.dart';
import 'package:visualit/features/reader/data/chapter.dart';

final pageRenderServiceProvider = Provider<PageRenderService>((ref) {
  final isar = ref.watch(isarDBProvider).requireValue;
  return PageRenderService(isar);
});

/// Service for rendering and caching book pages.
/// This service optimizes rendering performance by caching calculated page metadata.
class PageRenderService {
  final Isar _isar;
  String? _deviceId;

  PageRenderService(this._isar);

  /// Get the Isar database instance
  Isar get isar => _isar;

  /// Clear the cache for a specific book
  Future<int> clearBookCache(int bookId) async {
    int deletedCount = 0;
    await _isar.writeTxn(() async {
      final caches = await _isar.pageCaches
          .where()
          .bookIdEqualToAnyDeviceIdFontSizeKey(bookId)
          .findAll();

      if (caches.isNotEmpty) {
        await _isar.pageCaches.deleteAll(
          caches.map((cache) => cache.id).toList()
        );
        deletedCount = caches.length;
      }
    });
    return deletedCount;
  }

  /// Get or calculate pages for a book with the given parameters.
  /// This method first checks the cache and falls back to calculation if needed.
  Future<List<PageMetadata>> getOrCalculatePages({
    required int bookId,
    required double fontSize,
    required double width,
    required double height,
    required BuildContext context,
  }) async {
    // Get device ID
    final deviceId = await _getDeviceId();

    // Create a key for the font size and dimensions
    final fontSizeKey = '${fontSize.toStringAsFixed(1)}_${width.toStringAsFixed(0)}_${height.toStringAsFixed(0)}';

    // Try to get from cache first
    final cachedPages = await _isar.pageCaches
        .where()
        .bookIdDeviceIdFontSizeKeyEqualTo(bookId, deviceId, fontSizeKey)
        .findFirst();

    if (cachedPages != null) {
      print("✅ [PageRenderService] Found cached pages for book $bookId with font size $fontSizeKey");
      try {
        return PageMetadata.fromJsonString(cachedPages.pageMapJson);
      } catch (e) {
        print("❌ [PageRenderService] Error parsing cached pages: $e");
        // If there's an error parsing the cache, recalculate
      }
    }

    // Calculate pages if not in cache or if there was an error
    print("⏳ [PageRenderService] Calculating pages for book $bookId with font size $fontSizeKey");
    final pages = await _calculatePages(
      bookId: bookId,
      fontSize: fontSize,
      width: width,
      height: height,
      context: context,
    );

    // Save to cache
    if (pages.isNotEmpty) {
      await _isar.writeTxn(() async {
        await _isar.pageCaches.put(PageCache(
          bookId: bookId,
          deviceId: deviceId,
          fontSizeKey: fontSizeKey,
          pageMapJson: PageMetadata.toJsonString(pages),
        ));
      });
      print("✅ [PageRenderService] Saved ${pages.length} pages to cache");
    }

    return pages;
  }

  /// Calculate pages for a book.
  /// This is a computationally expensive operation.
  Future<List<PageMetadata>> _calculatePages({
    required int bookId,
    required double fontSize,
    required double width,
    required double height,
    required BuildContext context,
  }) async {
    final pages = <PageMetadata>[];

    // Get all chapters for the book
    final chapters = await _isar.chapters
        .where()
        .bookIdEqualTo(bookId)
        .sortByOrderIndex()
        .findAll();

    if (chapters.isEmpty) {
      print("⚠️ [PageRenderService] No chapters found for book $bookId");
      return pages;
    }

    // Get all content blocks for the book
    final contentBlocks = await _isar.contentBlocks
        .where()
        .bookIdEqualTo(bookId)
        .sortByBlockIndexInChapter()
        .findAll();

    if (contentBlocks.isEmpty) {
      print("⚠️ [PageRenderService] No content blocks found for book $bookId");
      return pages;
    }

    // Group blocks by chapter
    final blocksByChapter = <int, List<ContentBlock>>{};
    for (final block in contentBlocks) {
      if (block.chapterId != null) {
        blocksByChapter.putIfAbsent(block.chapterId!, () => []).add(block);
      } else if (block.chapterIndex != null) {
        // Fallback to chapterIndex if chapterId is not set
        final chapter = chapters.firstWhere(
          (c) => c.orderIndex == block.chapterIndex,
          orElse: () => chapters.first,
        );
        blocksByChapter.putIfAbsent(chapter.id, () => []).add(block);
      }
    }

    // Calculate pages for each chapter
    int pageIndex = 0;
    for (final chapter in chapters) {
      final blocks = blocksByChapter[chapter.id] ?? [];

      for (final block in blocks) {
        // Skip image blocks for now (they would need special handling)
        if (block.blockType == BlockType.img) {
          // Add a simple page for the image
          pages.add(PageMetadata(
            pageIndex: pageIndex++,
            blockId: block.id,
            offsetInBlock: 0,
            height: 300, // Default height for images
          ));
          continue;
        }

        // For text blocks, we need to calculate how many pages they span
        final text = block.textContent ?? '';
        if (text.isEmpty) continue;

        // Create a text painter to measure the text
        final textStyle = TextStyle(fontSize: fontSize);
        final textSpan = TextSpan(text: text, style: textStyle);
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
          maxLines: null,
        );

        // Layout the text with the given width
        textPainter.layout(maxWidth: width);

        // Calculate how many pages this block spans
        final totalHeight = textPainter.height;
        double offset = 0;

        while (offset < totalHeight) {
          final pageHeight = height;
          pages.add(PageMetadata(
            pageIndex: pageIndex++,
            blockId: block.id,
            offsetInBlock: offset,
            height: pageHeight > (totalHeight - offset) ? (totalHeight - offset) : pageHeight,
          ));

          offset += pageHeight;
        }
      }
    }

    return pages;
  }

  /// Get a unique identifier for the current device.
  Future<String> _getDeviceId() async {
    if (_deviceId != null) return _deviceId!;

    final deviceInfo = DeviceInfoPlugin();

    if (Theme.of(navigatorKey.currentContext!).platform == TargetPlatform.android) {
      final androidInfo = await deviceInfo.androidInfo;
      _deviceId = androidInfo.id;
    } else if (Theme.of(navigatorKey.currentContext!).platform == TargetPlatform.iOS) {
      final iosInfo = await deviceInfo.iosInfo;
      _deviceId = iosInfo.identifierForVendor;
    } else {
      // For web, desktop, etc.
      _deviceId = 'unknown_device';
    }

    return _deviceId!;
  }
}

// Global navigator key for accessing context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
