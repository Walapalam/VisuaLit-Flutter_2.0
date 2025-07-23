import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides a simple in-memory cache for book page layouts.
///
/// The key is a unique identifier generated from the bookId, screen dimensions,
/// and font settings. The value is the calculated page-to-block map.
class LayoutCacheService {
  final Map<String, Map<int, int>> _cache = {};

  /// Retrieves a cached layout for the given key.
  /// Returns null if no layout is found.
  Map<int, int>? getLayout(String key) {
    print("CACHE: Checking for layout with key: $key");
    if (_cache.containsKey(key)) {
      print("CACHE: HIT! Found layout for key: $key");
      return _cache[key];
    }
    print("CACHE: MISS! No layout found for key: $key");
    return null;
  }

  /// Saves a calculated layout to the cache.
  void saveLayout(String key, Map<int, int> layout) {
    print("CACHE: Saving layout for key: $key");
    _cache[key] = layout;
  }

  /// Clears the entire layout cache.
  /// Useful if global settings change.
  void clearCache() {
    print("CACHE: Clearing all cached layouts.");
    _cache.clear();
  }
}

/// Riverpod provider to make the LayoutCacheService available throughout the app.
final layoutCacheProvider = Provider<LayoutCacheService>((ref) {
  return LayoutCacheService();
});