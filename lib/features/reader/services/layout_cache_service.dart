import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:visualit/features/reader/data/layout_cache.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';

class LayoutCacheService {
  final Isar _isar;

  LayoutCacheService(this._isar);

  /// Generates a unique layout key based on bookId, device dimensions, and font settings
  String generateLayoutKey(int bookId, Size deviceSize, ReadingPreferences prefs) {
    return '$bookId-${deviceSize.width.toInt()}-${deviceSize.height.toInt()}-'
        '${prefs.fontSize.toInt()}-${prefs.fontFamily}-${prefs.lineSpacing.toStringAsFixed(1)}';
  }

  /// Checks if a layout exists for the given key
  Future<bool> hasLayout(String layoutKey) async {
    final cache = await _isar.layoutCaches.filter().layoutKeyEqualTo(layoutKey).findFirst();
    return cache != null;
  }

  /// Gets the layout for the given key
  Future<Map<int, int>?> getLayout(String layoutKey) async {
    final cache = await _isar.layoutCaches.filter().layoutKeyEqualTo(layoutKey).findFirst();
    if (cache == null) return null;

    try {
      final Map<String, dynamic> jsonMap = jsonDecode(cache.pageToBlockMap);
      return jsonMap.map((key, value) => MapEntry(int.parse(key), value as int));
    } catch (e) {
      print('Error decoding layout cache: $e');
      return null;
    }
  }

  /// Saves a layout for the given key
  Future<void> saveLayout(String layoutKey, int bookId, Map<int, int> pageToBlockMap) async {
    final jsonMap = pageToBlockMap.map((key, value) => MapEntry(key.toString(), value));
    final jsonString = jsonEncode(jsonMap);

    final cache = LayoutCache()
      ..layoutKey = layoutKey
      ..bookId = bookId
      ..pageToBlockMap = jsonString
      ..timestamp = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.layoutCaches.put(cache);
    });
  }

  /// Clears the layout cache for a specific book
  Future<void> clearLayoutsForBook(int bookId) async {
    await _isar.writeTxn(() async {
      await _isar.layoutCaches.filter().bookIdEqualTo(bookId).deleteAll();
    });
  }

  /// Clears all layout caches
  Future<void> clearAllLayouts() async {
    await _isar.writeTxn(() async {
      await _isar.layoutCaches.clear();
    });
  }
}
