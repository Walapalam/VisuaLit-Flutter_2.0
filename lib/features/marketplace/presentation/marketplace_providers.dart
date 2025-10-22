import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'marketplace_notifier.dart';

final marketplaceProvider = StateNotifierProvider<MarketplaceNotifier, MarketplaceState>(
      (ref) {
    final isar = ref.watch(isarDBProvider).valueOrNull;
    return MarketplaceNotifier(isar);
  },
);