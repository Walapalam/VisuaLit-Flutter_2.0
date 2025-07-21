import 'package:flutter/material.dart';
import 'package:visualit/core/services/interfaces/i_logger_service.dart';
import 'package:visualit/features/reader/application/interfaces/i_page_render_service.dart';
import 'package:visualit/features/reader/application/page_render_service.dart';
import 'package:visualit/features/reader/data/page_cache.dart';


/// Enhanced implementation of the IPageRenderService interface.
///
/// This service wraps the original PageRenderService and adds additional
/// functionality required by the IPageRenderService interface.
class EnhancedPageRenderService implements IPageRenderService {
  final PageRenderService _originalService;
  final ILoggerService _logger;

  EnhancedPageRenderService(this._originalService, this._logger);

  @override
  Future<List<PageMetadata>> getOrCalculatePages({
    required int bookId,
    required double fontSize,
    required double width,
    required double height,
    required BuildContext context,
  }) async {
    _logger.info(
      'Getting or calculating pages for book $bookId with font size $fontSize',
      tag: 'PageRenderService'
    );

    try {
      final pages = await _originalService.getOrCalculatePages(
        bookId: bookId,
        fontSize: fontSize,
        width: width,
        height: height,
        context: context,
      );

      _logger.info(
        'Retrieved ${pages.length} pages for book $bookId',
        tag: 'PageRenderService'
      );

      return pages;
    } catch (e, stackTrace) {
      _logger.error(
        'Error getting or calculating pages: $e',
        tag: 'PageRenderService',
        stackTrace: stackTrace
      );
      rethrow;
    }
  }

  @override
  Future<void> clearCache(int bookId) async {
    _logger.info('Clearing cache for book $bookId', tag: 'PageRenderService');

    try {
      // Use the new method in the original service
      final deletedCount = await _originalService.clearBookCache(bookId);

      if (deletedCount > 0) {
        _logger.info('Deleted $deletedCount cache entries', tag: 'PageRenderService');
      } else {
        _logger.info('No cache entries found to delete', tag: 'PageRenderService');
      }
    } catch (e, stackTrace) {
      _logger.error(
        'Error clearing cache: $e',
        tag: 'PageRenderService',
        stackTrace: stackTrace
      );
      rethrow;
    }
  }
}
