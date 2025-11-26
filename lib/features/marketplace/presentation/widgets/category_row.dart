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
    final state = ref.watch(marketplaceProvider);
    final books = (state.categorizedBooks[subject] ?? []).where((book) {
      final formats = book['formats'] as Map<String, dynamic>?;
      return formats != null &&
          (formats['image/jpeg'] != null ||
              formats.containsKey('image/jpeg')) &&
          (formats['application/epub+zip'] != null ||
              formats.containsKey('application/epub+zip'));
    }).toList();
    final loaded = state.loadedCategories.contains(subject);

    // If category loaded and has books, show the actual row
    if (loaded && books.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.isMobile ? AppSpacing.md : AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          SizedBox(
            height: context.bookShelfHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: context.isMobile ? AppSpacing.md : AppSpacing.lg,
              ),
              itemCount: books.length,
              itemBuilder: (context, index) =>
                  HorizontalBookCard(book: books[index]),
            ),
          ),
        ],
      );
    }

    // Not loaded: show skeleton with overlay
    final showOverlay =
        state.isInitialLoading ||
        state.isLoadingFromCache ||
        (!loaded && books.isEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.isMobile ? AppSpacing.md : AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
        ),
        SizedBox(
          height: context.bookShelfHeight,
          child: Stack(
            children: [
              ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                  horizontal: context.isMobile ? AppSpacing.md : AppSpacing.lg,
                ),
                itemCount: 6,
                itemBuilder: (context, index) =>
                    const HorizontalBookCardSkeleton(),
              ),
              if (showOverlay)
                Positioned(
                  left: context.isMobile ? AppSpacing.md : AppSpacing.lg,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Loading...',
                          style: TextStyle(color: Colors.white),
                        ),
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
