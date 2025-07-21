import 'package:flutter/material.dart';
import 'package:visualit/features/reader/data/page_cache.dart';

/// Interface for page rendering service.
/// 
/// This interface defines the contract for services that render and cache
/// book pages for display in the reader.
abstract class IPageRenderService {
  /// Gets or calculates pages for a book with the given parameters.
  /// 
  /// This method should first check the cache and fall back to calculation if needed.
  /// 
  /// [bookId] is the ID of the book to render pages for.
  /// [fontSize] is the font size to use for rendering.
  /// [width] is the width of the rendering area.
  /// [height] is the height of the rendering area.
  /// [context] is the build context for accessing theme and other information.
  Future<List<PageMetadata>> getOrCalculatePages({
    required int bookId,
    required double fontSize,
    required double width,
    required double height,
    required BuildContext context,
  });
  
  /// Clears the page cache for a specific book.
  /// 
  /// This method should be called when book content changes or when
  /// the user explicitly requests a refresh.
  /// 
  /// [bookId] is the ID of the book to clear the cache for.
  Future<void> clearCache(int bookId);
}