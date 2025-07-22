import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/services/layout_cache_service.dart';

/// Provider for the LayoutCacheService
final layoutCacheServiceProvider = Provider<LayoutCacheService>((ref) {
  final isar = ref.watch(isarDBProvider).value!;
  return LayoutCacheService(isar);
});