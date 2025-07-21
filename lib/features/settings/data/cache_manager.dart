import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/data/book_data.dart';

final cacheManagerProvider = Provider<CacheManager>((ref) {
  final isar = ref.watch(isarDBProvider).requireValue;
  return CacheManager(isar);
});

class CacheStats {
  final int totalBooks;
  final int totalSizeInBytes;
  final int readyBooks;
  final int processingBooks;
  final int errorBooks;
  final Map<String, int> bookSizes;

  CacheStats({
    required this.totalBooks,
    required this.totalSizeInBytes,
    required this.readyBooks,
    required this.processingBooks,
    required this.errorBooks,
    required this.bookSizes,
  });

  String get totalSizeFormatted {
    if (totalSizeInBytes < 1024) {
      return '$totalSizeInBytes B';
    } else if (totalSizeInBytes < 1024 * 1024) {
      return '${(totalSizeInBytes / 1024).toStringAsFixed(1)} KB';
    } else if (totalSizeInBytes < 1024 * 1024 * 1024) {
      return '${(totalSizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(totalSizeInBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}

class CacheManager {
  final Isar _isar;

  // Default cache size limit: 500 MB
  static const int defaultCacheSizeLimit = 500 * 1024 * 1024;

  CacheManager(this._isar);

  /// Get statistics about the current cache usage
  Future<CacheStats> getCacheStats() async {
    final books = await _isar.books.where().findAll();

    int totalSizeInBytes = 0;
    int readyBooks = 0;
    int processingBooks = 0;
    int errorBooks = 0;
    Map<String, int> bookSizes = {};

    for (final book in books) {
      final bookSize = book.fileSizeInBytes ?? 0;
      totalSizeInBytes += bookSize;

      // Count books by status
      if (book.status == ProcessingStatus.ready || book.status == ProcessingStatus.partiallyReady) {
        readyBooks++;
      } else if (book.status == ProcessingStatus.processing || book.status == ProcessingStatus.queued) {
        processingBooks++;
      } else if (book.status == ProcessingStatus.error) {
        errorBooks++;
      }

      // Store book sizes by title
      bookSizes[book.title ?? 'Untitled'] = bookSize;
    }

    return CacheStats(
      totalBooks: books.length,
      totalSizeInBytes: totalSizeInBytes,
      readyBooks: readyBooks,
      processingBooks: processingBooks,
      errorBooks: errorBooks,
      bookSizes: bookSizes,
    );
  }

  /// Apply cache eviction rules to keep cache size under the limit
  Future<void> applyCacheEvictionRules({int? cacheSizeLimit}) async {
    final limit = cacheSizeLimit ?? defaultCacheSizeLimit;
    final stats = await getCacheStats();

    // If we're under the limit, no need to evict anything
    if (stats.totalSizeInBytes <= limit) {
      return;
    }

    // Get all books sorted by last accessed time (oldest first)
    final books = await _isar.books
        .where()
        .sortByLastAccessedAt()
        .findAll();

    // Calculate how much space we need to free
    final spaceToFree = stats.totalSizeInBytes - limit;
    int freedSpace = 0;

    // Start removing books until we've freed enough space
    for (final book in books) {
      // Skip books that are currently being processed
      if (book.status == ProcessingStatus.processing || book.status == ProcessingStatus.queued) {
        continue;
      }

      final bookSize = book.fileSizeInBytes ?? 0;

      // Delete the book's content blocks
      await _isar.writeTxn(() async {
        await _isar.contentBlocks.filter().bookIdEqualTo(book.id).deleteAll();
      });

      // Try to delete the original file if it exists
      try {
        final file = File(book.epubFilePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print("Error deleting file: $e");
      }

      // Update the book status to indicate it needs to be reprocessed
      await _isar.writeTxn(() async {
        book.status = ProcessingStatus.queued;
        book.processedChapters = [];
        book.processingProgress = 0.0;
        await _isar.books.put(book);
      });

      freedSpace += bookSize;

      // If we've freed enough space, stop
      if (freedSpace >= spaceToFree) {
        break;
      }
    }
  }

  /// Clear the cache for a specific book
  Future<void> clearBookCache(int bookId) async {
    final book = await _isar.books.get(bookId);
    if (book == null) return;

    // Delete the book's content blocks
    await _isar.writeTxn(() async {
      await _isar.contentBlocks.filter().bookIdEqualTo(bookId).deleteAll();
    });

    // Update the book status
    await _isar.writeTxn(() async {
      book.status = ProcessingStatus.queued;
      book.processedChapters = [];
      book.processingProgress = 0.0;
      await _isar.books.put(book);
    });
  }

  /// Clear the entire cache
  Future<void> clearAllCache() async {
    // Delete all content blocks
    await _isar.writeTxn(() async {
      await _isar.contentBlocks.where().deleteAll();
    });

    // Reset all books to queued status
    final books = await _isar.books.where().findAll();
    await _isar.writeTxn(() async {
      for (final book in books) {
        book.status = ProcessingStatus.queued;
        book.processedChapters = [];
        book.processingProgress = 0.0;
        await _isar.books.put(book);
      }
    });
  }

  /// Calculate the size of a book's content
  Future<int> calculateBookSize(int bookId) async {
    final book = await _isar.books.get(bookId);
    if (book == null) return 0;

    int size = 0;

    // Add size of the original file
    try {
      final file = File(book.epubFilePath);
      if (await file.exists()) {
        size += await file.length();
      }
    } catch (e) {
      print("Error getting file size: $e");
    }

    // Add size of content blocks
    final blocks = await _isar.contentBlocks.filter().bookIdEqualTo(bookId).findAll();
    for (final block in blocks) {
      // Add size of HTML content
      size += block.htmlContent?.length ?? 0;

      // Add size of text content
      size += block.textContent?.length ?? 0;

      // Add size of image bytes
      size += block.imageBytes?.length ?? 0;

      // Add size of tokenized and stemmed text
      for (final token in block.tokenizedText ?? []) {
        final int tokenLength = token.length.toInt();
        size += tokenLength;
      }
      for (final stem in block.stemmedText ?? []) {
        final int stemLength = stem.length.toInt();
        size += stemLength;
      }

      // Add size tracking field
      block.sizeInBytes = ((block.htmlContent?.length ?? 0) +
                          (block.textContent?.length ?? 0) +
                          (block.imageBytes?.length ?? 0)).toInt();
    }

    // Update the book's size in the database
    await _isar.writeTxn(() async {
      book.fileSizeInBytes = size;
      await _isar.books.put(book);

      // Also update the block sizes
      await _isar.contentBlocks.putAll(blocks);
    });

    return size;
  }
}
