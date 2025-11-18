import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/marketplace/data/marketplace_repository.dart';
import 'marketplace_notifier.dart';

final marketplaceRepositoryProvider = Provider((ref) => MarketplaceRepository());

final marketplaceProvider = StateNotifierProvider<MarketplaceNotifier, MarketplaceState>(
      (ref) {
    final isar = ref.watch(isarDBProvider).valueOrNull;
    final repository = ref.watch(marketplaceRepositoryProvider);
    return MarketplaceNotifier(isar, repository);
  },
);