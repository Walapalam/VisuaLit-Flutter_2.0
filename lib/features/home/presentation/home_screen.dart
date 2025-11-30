import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/features/library/presentation/library_controller.dart';
import 'package:visualit/shared_widgets/expandable_import_button.dart';
import 'package:visualit/features/marketplace/presentation/marketplace_providers.dart';
import '../../../core/providers/isar_provider.dart';
import 'widgets/home_background.dart';
import 'widgets/glass_search_bar.dart';
import 'widgets/currently_reading_carousel.dart';
import 'widgets/section_header.dart';
import 'widgets/empty_library_view.dart';
import 'package:visualit/core/services/toast_service.dart';
import 'widgets/horizontal_book_list.dart';
import 'widgets/horizontal_marketplace_book_list.dart';
import 'widgets/home_greeting_header.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isarAsync = ref.watch(isarDBProvider);

    return isarAsync.when(
      loading: () => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Text(
            'Database Error: $err',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),
      data: (isar) {
        final libraryState = ref.watch(libraryControllerProvider);
        final libraryController = ref.read(libraryControllerProvider.notifier);

        return Scaffold(
          backgroundColor: Theme.of(
            context,
          ).scaffoldBackgroundColor, // Fallback
          body: Stack(
            children: [
              // 1. Background
              const HomeBackground(),

              // 2. Content
              SafeArea(
                child: libraryState.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(
                    child: Text(
                      'Error: $err',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                  data: (books) {
                    // Filter for "Currently Reading" - for now, just take the first 5 books
                    // In a real app, filter by status or lastReadTimestamp
                    final recentBooks = books.take(5).toList();

                    return CustomScrollView(
                      slivers: [
                        // Custom App Bar / Header Area
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Consumer(
                                  builder: (context, ref, child) {
                                    return const HomeGreetingHeader();
                                  },
                                ),
                                const SizedBox(height: 24),

                                // Search Bar
                                GlassSearchBar(
                                  onTap: () {
                                    // TODO: Implement search navigation or logic
                                    ToastService.show(
                                      context,
                                      'Search coming soon',
                                      type: ToastType.info,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (books.isEmpty) ...[
                          // EMPTY STATE LAYOUT
                          // 1. Marketplace (Moved to top)
                          SliverToBoxAdapter(
                            child: Consumer(
                              builder: (context, ref, child) {
                                final marketplaceState = ref.watch(
                                  marketplaceProvider,
                                );

                                // Combine all marketplace books
                                final allMarketplaceBooks = <dynamic>[
                                  ...marketplaceState.bestsellers,
                                  ...marketplaceState.categorizedBooks.values
                                      .expand((list) => list),
                                ];

                                // Get 10 random books
                                final random = allMarketplaceBooks.toList()
                                  ..shuffle();
                                final randomBooks = random.take(10).toList();

                                return Column(
                                  children: [
                                    const SizedBox(height: 24),
                                    SectionHeader(
                                      title: 'Discover Books',
                                      onActionTap: () =>
                                          context.go('/marketplace'),
                                    ),
                                    HorizontalMarketplaceBookList(
                                      books: randomBooks,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),

                          // 2. Motivational Empty State
                          const SliverToBoxAdapter(child: EmptyLibraryView()),
                        ] else ...[
                          // NORMAL LAYOUT
                          // Currently Reading Section
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 20),
                                CurrentlyReadingCarousel(books: recentBooks),
                              ],
                            ),
                          ),

                          // My Books Section
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                const SizedBox(height: 32),
                                SectionHeader(
                                  title: 'My Books',
                                  onActionTap: () => context.go('/library'),
                                ),
                                HorizontalBookList(books: books),
                              ],
                            ),
                          ),

                          // Marketplace Section - Show 10 random books
                          SliverToBoxAdapter(
                            child: Consumer(
                              builder: (context, ref, child) {
                                final marketplaceState = ref.watch(
                                  marketplaceProvider,
                                );

                                // Combine all marketplace books
                                final allMarketplaceBooks = <dynamic>[
                                  ...marketplaceState.bestsellers,
                                  ...marketplaceState.categorizedBooks.values
                                      .expand((list) => list),
                                ];

                                // Get 10 random books
                                final random = allMarketplaceBooks.toList()
                                  ..shuffle();
                                final randomBooks = random.take(10).toList();

                                return Column(
                                  children: [
                                    const SizedBox(height: 24),
                                    SectionHeader(
                                      title: 'Marketplace',
                                      onActionTap: () =>
                                          context.go('/marketplace'),
                                    ),
                                    HorizontalMarketplaceBookList(
                                      books: randomBooks,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],

                        // Add Books Button - Expandable (Always visible)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: ExpandableImportButton(
                              onImportBook: () =>
                                  libraryController.pickAndProcessBooks(),
                              onImportFolder: () =>
                                  libraryController.scanAndProcessBooks(),
                            ),
                          ),
                        ),

                        // Bottom padding
                        const SliverToBoxAdapter(child: SizedBox(height: 140)),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
