import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/reader/data/layout_cache_service.dart';

/// Provider for the LayoutCacheService
final layoutCacheServiceProvider = Provider<LayoutCacheService>((ref) {
  return LayoutCacheService();
});