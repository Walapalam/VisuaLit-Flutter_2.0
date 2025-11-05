import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/features/Cart/presentation/CartNotifier.dart';
import 'package:visualit/core/utils/responsive_helper.dart';
import 'package:visualit/core/theme/theme_extensions.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/features/marketplace/presentation/marketplace_notifier.dart';
import 'marketplace_providers.dart';

import 'widgets/all_books_view.dart';
import 'widgets/bestsellers_section.dart';
import 'widgets/book_card.dart';
import 'widgets/categories_section.dart';
import 'widgets/hero_banner.dart';
import 'widgets/horizontal_book_card_skeleton.dart';
import 'widgets/loading_overlay.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool showAllBooks = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      final state = ref.read(marketplaceProvider);
      if (!state.isLoading && state.nextUrl != null) {
        ref.read(marketplaceProvider.notifier).loadBooks();
      }
    }
  }

  void _showAllBooks() {
    setState(() {
      showAllBooks = true;
      // Optionally reset search
      ref.read(marketplaceProvider.notifier).searchBooks('');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildSkeletonLoader() {
    return Column(
      children: [
        SizedBox(
          height: context.bookShelfHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            itemBuilder: (context, index) => const HorizontalBookCardSkeleton(),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: context.bookShelfHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            itemBuilder: (context, index) => const HorizontalBookCardSkeleton(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(marketplaceProvider);
    final notifier = ref.read(marketplaceProvider.notifier);
    final cartBooks = ref.watch(cartProvider);

    // Compose the main content separately to avoid complex inline ternary nesting
    final Widget bodyContent = showAllBooks
        ? AllBooksView(
            searchController: _searchController,
            scrollController: _scrollController,
            ref: ref,
            cartBooks: cartBooks,
            onBack: () {
              setState(() {
                showAllBooks = false;
              });
            },
          )
        : CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Search Bar
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                title: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search books...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    suffixIcon: Stack(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.shopping_cart,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          onPressed: () {
                            context.goNamed('cart');
                          },
                        ),
                        if (state.isOffline)
                          const Positioned(
                            left: 8,
                            top: 8,
                            child: Icon(Icons.wifi_off, color: Colors.grey, size: 20),
                          ),
                        if (cartBooks.isNotEmpty)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '${cartBooks.length}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  onSubmitted: (query) {
                    if (query.trim().isNotEmpty) {
                      ref.read(marketplaceProvider.notifier).searchBooks(query.trim());
                    }
                  },
                ),
              ),

              // Hero Banner (if not searching)
              if (state.searchQuery.isEmpty) SliverToBoxAdapter(child: HeroBanner(onSeeAllBooks: _showAllBooks)),

              if (state.isInitialLoading)
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildSkeletonLoader(),
                    ],
                  ),
                ),

              if (state.isOffline && state.books.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off, size: 50),
                        const SizedBox(height: 10),
                        const Text('You are offline.'),
                        const Text('Connect to the internet to discover new books.'),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => ref.read(marketplaceProvider.notifier).retryInitialLoad(),
                          child: const Text('Retry'),
                        )
                      ],
                    ),
                  ),
                ),

              if (state.errorMessage != null)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 50, color: Colors.red),
                        const SizedBox(height: 10),
                        Text(state.errorMessage!),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => ref.read(marketplaceProvider.notifier).retryInitialLoad(),
                          child: const Text('Retry'),
                        )
                      ],
                    ),
                  ),
                ),

              // Bestsellers Section (if not searching)
              if (state.searchQuery.isEmpty && !state.isInitialLoading)
                const SliverToBoxAdapter(child: BestsellersSection()),

              // Categories Section (if not searching)
              if (state.searchQuery.isEmpty && !state.isInitialLoading)
                SliverToBoxAdapter(child: CategoriesSection()),

              // Search Results Grid (if searching)
              if (state.searchQuery.isNotEmpty)
                SliverPadding(
                  padding: EdgeInsets.all(context.isMobile ? AppSpacing.md : AppSpacing.lg),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: context.gridColumns,
                      childAspectRatio: context.cardAspectRatio,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index < state.books.length) {
                          return BookCard(book: state.books[index]);
                        } else {
                          // Show loading indicator at the end
                          return const Center(child: CircularProgressIndicator());
                        }
                      },
                      childCount: state.isLoading ? state.books.length + 1 : state.books.length,
                    ),
                  ),
                ),

              // Loading Indicator
              if (state.isLoading)
                SliverToBoxAdapter(
                  child: Center(child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: const CircularProgressIndicator(),
                  )),
                ),
            ],
          );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: LoadingOverlay(
          isLoading: state.isInitialLoading,
          child: bodyContent,
        ),
      ),
    );
  }
}
