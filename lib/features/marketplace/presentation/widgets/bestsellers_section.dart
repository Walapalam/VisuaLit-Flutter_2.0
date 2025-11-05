import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/utils/responsive_helper.dart';
import 'package:visualit/core/theme/theme_extensions.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/features/marketplace/presentation/marketplace_notifier.dart';
import 'package:visualit/features/marketplace/presentation/marketplace_providers.dart';
import 'package:visualit/features/marketplace/presentation/widgets/horizontal_book_card.dart';
import 'package:visualit/features/marketplace/presentation/widgets/horizontal_book_card_skeleton.dart';

class BestsellersSection extends ConsumerWidget {
  const BestsellersSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(marketplaceProvider);
    final bestsellers = state.bestsellers;
    final loaded = state.loadedCategories.contains('bestsellers');

    // If bestsellers list is present and loaded, show the row
    if (loaded && bestsellers.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.isMobile ? AppSpacing.md : AppSpacing.lg),
            child: Text('Bestsellers', style: Theme.of(context).textTheme.headlineMedium),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: context.bookShelfHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: context.isMobile ? AppSpacing.md : AppSpacing.lg),
              itemCount: bestsellers.length,
              itemBuilder: (context, index) => HorizontalBookCard(book: bestsellers[index]),
            ),
          ),
        ],
      );
    }

    // Not loaded yet: show skeleton with a loading overlay if initial loading is happening
    final showOverlay = state.isInitialLoading || state.isLoadingFromCache || (!loaded && bestsellers.isEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.isMobile ? AppSpacing.md : AppSpacing.lg),
          child: Text('Bestsellers', style: Theme.of(context).textTheme.headlineMedium),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: context.bookShelfHeight,
          child: Stack(
            children: [
              ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: context.isMobile ? AppSpacing.md : AppSpacing.lg),
                itemCount: 6,
                itemBuilder: (context, index) => const HorizontalBookCardSkeleton(),
              ),
              if (showOverlay)
                Positioned(
                  left: context.isMobile ? AppSpacing.md : AppSpacing.lg,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                        SizedBox(width: 8),
                        Text('Loading...', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
