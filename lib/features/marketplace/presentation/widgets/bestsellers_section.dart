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
    final bestsellers = ref.watch(marketplaceProvider).bestsellers;

    if (bestsellers.isEmpty) {
      return SizedBox(
        height: context.bookShelfHeight,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 6,
          itemBuilder: (context, index) => const HorizontalBookCardSkeleton(),
        ),
      );
    }

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
}
