import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/utils/responsive_helper.dart';
import 'package:visualit/core/theme/theme_extensions.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/features/marketplace/presentation/marketplace_notifier.dart';
import 'package:visualit/features/marketplace/presentation/marketplace_providers.dart';
import 'package:visualit/features/marketplace/presentation/widgets/horizontal_book_card.dart';
import 'package:visualit/features/marketplace/presentation/widgets/horizontal_book_card_skeleton.dart';

class CategoryRow extends ConsumerWidget {
  final String title;
  final String subject;

  const CategoryRow({required this.title, required this.subject, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(marketplaceProvider).categorizedBooks[subject] ?? [];

    if (books.isEmpty) {
      return SizedBox(
        height: ResponsiveHelper.getBookShelfHeight(context),
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
          padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isMobile(context) ? AppSpacing.md : AppSpacing.lg, vertical: AppSpacing.md),
          child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
        ),
        SizedBox(
          height: ResponsiveHelper.getBookShelfHeight(context),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isMobile(context) ? AppSpacing.md : AppSpacing.lg),
            itemCount: books.length,
            itemBuilder: (context, index) => HorizontalBookCard(book: books[index]),
          ),
        ),
      ],
    );
  }
}
