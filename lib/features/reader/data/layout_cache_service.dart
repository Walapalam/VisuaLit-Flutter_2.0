import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// A service for caching book layout information.
/// This service is responsible for storing and retrieving layout information
/// for books based on the book ID, device dimensions, and font settings.
class LayoutCacheService {
  static const String _cacheKeyPrefix = 'layout_cache_';

  /// Generates a unique layout key based on the book ID, device dimensions, and font settings.
  /// This key is used to identify a specific layout configuration.
  static String generateLayoutKey({
    required int bookId,
    required Size deviceDimensions,
    required Map<String, dynamic> fontSettings,
  }) {
    final dimensionsString = '${deviceDimensions.width.toStringAsFixed(0)}x${deviceDimensions.height.toStringAsFixed(0)}';
    final fontSettingsString = json.encode(fontSettings);
    return '$_cacheKeyPrefix${bookId}_${dimensionsString}_$fontSettingsString';
  }

  /// Get the cache directory
  Future<Directory> _getCacheDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/layout_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  /// Saves a page map to the cache.
  /// The page map is a mapping from page index to a list of block indices.
  /// Each entry in the map represents the blocks that should be displayed on a specific page.
  Future<bool> savePageMap({
    required String layoutKey,
    required Map<int, List<int>> pageMap,
  }) async {
    try {
      final cacheDir = await _getCacheDir();
      final file = File('${cacheDir.path}/$layoutKey.json');
      final encodedPageMap = json.encode(pageMap);
      await file.writeAsString(encodedPageMap);
      return true;
    } catch (e) {
      print('LayoutCacheService: Error saving page map: $e');
      return false;
    }
  }

  /// Retrieves a page map from the cache.
  /// Returns null if the page map is not found.
  Future<Map<int, List<int>>?> getPageMap({
    required String layoutKey,
  }) async {
    try {
      final cacheDir = await _getCacheDir();
      final file = File('${cacheDir.path}/$layoutKey.json');

      if (!await file.exists()) {
        return null;
      }

      final encodedPageMap = await file.readAsString();
      final decodedMap = json.decode(encodedPageMap) as Map<String, dynamic>;
      final pageMap = <int, List<int>>{};

      decodedMap.forEach((key, value) {
        final pageIndex = int.parse(key);
        final blockIndices = (value as List).cast<int>();
        pageMap[pageIndex] = blockIndices;
      });

      return pageMap;
    } catch (e) {
      print('LayoutCacheService: Error retrieving page map: $e');
      return null;
    }
  }

  /// Clears the cache for a specific layout key.
  Future<bool> clearCache({
    required String layoutKey,
  }) async {
    try {
      final cacheDir = await _getCacheDir();
      final file = File('${cacheDir.path}/$layoutKey.json');

      if (await file.exists()) {
        await file.delete();
      }

      return true;
    } catch (e) {
      print('LayoutCacheService: Error clearing cache: $e');
      return false;
    }
  }

  /// Clears all layout caches.
  Future<bool> clearAllCaches() async {
    try {
      final cacheDir = await _getCacheDir();
      final files = await cacheDir.list().toList();

      for (final file in files) {
        if (file is File && file.path.endsWith('.json')) {
          await file.delete();
        }
      }

      return true;
    } catch (e) {
      print('LayoutCacheService: Error clearing all caches: $e');
      return false;
    }
  }
}
