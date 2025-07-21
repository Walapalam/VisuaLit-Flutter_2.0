import 'package:flutter/material.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';
import 'package:visualit/features/reader/data/page_cache.dart';
import 'package:isar/isar.dart';
import 'dart:convert';

/// Service for managing layout caching to ensure stable pagination
/// across device rotations and reading preference changes.
class LayoutCacheService {
  final Isar _isar;
  
  LayoutCacheService(this._isar);
  
  /// Generates a unique key for the current layout configuration
  /// This key is used to identify cached layouts
  String generateLayoutKey(ReadingPreferences settings, Size screenSize) {
    return '${settings.fontSize}_${settings.lineSpacing}_${settings.fontFamily}_'
           '${settings.pageTurnStyle.name}_${screenSize.width.toStringAsFixed(1)}_'
           '${screenSize.height.toStringAsFixed(1)}';
  }
  
  /// Stores page layout information in the cache
  Future<void> cachePageLayout({
    required int bookId,
    required String deviceId,
    required String layoutKey,
    required Map<int, int> pageToBlockMap,
    required int totalPages,
  }) async {
    // Convert the page-to-block map to a list of PageMetadata
    final List<PageMetadata> pageMetadataList = [];
    
    for (final entry in pageToBlockMap.entries) {
      pageMetadataList.add(PageMetadata(
        pageIndex: entry.key,
        blockId: entry.value,
        offsetInBlock: 0.0, // Not used in this implementation
        height: 0.0, // Not used in this implementation
      ));
    }
    
    // Serialize the page metadata
    final pageMapJson = PageMetadata.toJsonString(pageMetadataList);
    
    // Create or update the cache entry
    final pageCache = PageCache(
      bookId: bookId,
      deviceId: deviceId,
      fontSizeKey: layoutKey, // Using fontSizeKey for the layout key
      pageMapJson: pageMapJson,
    );
    
    // Save to database
    await _isar.writeTxn(() async {
      await _isar.pageCaches.put(pageCache);
    });
  }
  
  /// Retrieves cached page layout information
  Future<Map<int, int>?> getCachedPageLayout({
    required int bookId,
    required String deviceId,
    required String layoutKey,
  }) async {
    // Query for the cache entry
    final cacheEntry = await _isar.pageCaches
        .filter()
        .bookIdEqualTo(bookId)
        .and()
        .deviceIdEqualTo(deviceId)
        .and()
        .fontSizeKeyEqualTo(layoutKey)
        .findFirst();
    
    if (cacheEntry == null) {
      return null;
    }
    
    try {
      // Deserialize the page metadata
      final pageMetadataList = PageMetadata.fromJsonString(cacheEntry.pageMapJson);
      
      // Convert back to page-to-block map
      final Map<int, int> pageToBlockMap = {};
      for (final metadata in pageMetadataList) {
        pageToBlockMap[metadata.pageIndex] = metadata.blockId;
      }
      
      return pageToBlockMap;
    } catch (e) {
      print('Error deserializing cached page layout: $e');
      return null;
    }
  }
  
  /// Clears all cached layouts for a specific book
  Future<void> clearCachedLayouts(int bookId) async {
    await _isar.writeTxn(() async {
      await _isar.pageCaches.filter().bookIdEqualTo(bookId).deleteAll();
    });
  }
}

/// Extension class to store additional layout information
class PageLayoutCache {
  final String layoutKey;
  final Map<int, int> pageToBlockMap;
  final int totalPages;
  final DateTime generatedAt;
  
  PageLayoutCache({
    required this.layoutKey,
    required this.pageToBlockMap,
    required this.totalPages,
    DateTime? generatedAt,
  }) : generatedAt = generatedAt ?? DateTime.now();
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'layoutKey': layoutKey,
      'pageToBlockMap': pageToBlockMap.map((k, v) => MapEntry(k.toString(), v)),
      'totalPages': totalPages,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
  
  /// Create from JSON
  factory PageLayoutCache.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> pageMapJson = json['pageToBlockMap'];
    final Map<int, int> pageMap = {};
    
    pageMapJson.forEach((key, value) {
      pageMap[int.parse(key)] = value as int;
    });
    
    return PageLayoutCache(
      layoutKey: json['layoutKey'],
      pageToBlockMap: pageMap,
      totalPages: json['totalPages'],
      generatedAt: DateTime.parse(json['generatedAt']),
    );
  }
}