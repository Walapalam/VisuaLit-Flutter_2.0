import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/features/Cart/presentation/CartNotifier.dart';
import 'package:visualit/core/theme/theme_extensions.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/features/home/presentation/widgets/home_background.dart';
import 'package:visualit/features/marketplace/presentation/widgets/hero_carousel.dart';
import 'package:visualit/shared_widgets/custom_overlapped_carousel.dart';
import 'marketplace_providers.dart';

import 'widgets/all_books_view.dart';
import 'widgets/bestsellers_section.dart';
import 'widgets/marketplace_card.dart';
import 'widgets/categories_section.dart';
import 'widgets/book_dialog.dart';
import 'widgets/welcome_carousel_card.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  bool showAllBooks = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final state = ref.read(marketplaceProvider);
      if (!state.isLoading && state.nextUrl != null) {
        ref.read(marketplaceProvider.notifier).loadBooks();
      }
    }
  }

  void _showAllBooks() {
    setState(() {
      showAllBooks = true;
      ref.read(marketplaceProvider.notifier).searchBooks('');
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    ref.read(marketplaceProvider.notifier).clearSearch();
    // Ensure we go back to main view if we were in search results
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Widget _buildCarousel(List<dynamic> books) {
    if (books.isEmpty) return const SizedBox.shrink();

    // Take top 10 for carousel
    final carouselBooks = books.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'New & Trending',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              TextButton(onPressed: _showAllBooks, child: Text('View All')),
            ],
          ),
        ),
        CustomOverlappedCarousel(
          height: 280,
          centerItemWidth: 180,
          items: carouselBooks.asMap().entries.map((entry) {
            final index = entry.key;
            final book = entry.value;
            return CustomOverlappedCarouselItem(
              index: index,
              builder: (context, isFocused) {
                return MarketplaceCard(book: book);
              },
            );
          }).toList(),
          onClicked: (index) {
            showBookDialog(context, ref, carouselBooks[index]);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(marketplaceProvider);
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
        : Stack(
            children: [
              // Background
              const HomeBackground(),

              // Content
              SafeArea(
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    // Search Bar (Scrollable, not pinned)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          textInputAction: TextInputAction.search,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search books...',
                            hintStyle: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.5),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.1),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            prefixIcon:
                                state.isLoading && state.searchQuery.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                  )
                                : IconButton(
                                    icon: Icon(
                                      Icons.search,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                    onPressed: () {
                                      _searchFocusNode.unfocus();
                                      if (_searchController.text
                                          .trim()
                                          .isNotEmpty) {
                                        ref
                                            .read(marketplaceProvider.notifier)
                                            .searchBooks(
                                              _searchController.text.trim(),
                                            );
                                      }
                                    },
                                  ),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_searchController.text.isNotEmpty)
                                  IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                    onPressed: _clearSearch,
                                  ),
                                Stack(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.shopping_cart,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                      onPressed: () {
                                        context.go('/marketplace/cart');
                                      },
                                    ),
                                    if (state.isOffline)
                                      const Positioned(
                                        left: 8,
                                        top: 8,
                                        child: Icon(
                                          Icons.wifi_off,
                                          color: Colors.grey,
                                          size: 20,
                                        ),
                                      ),
                                    if (cartBooks.isNotEmpty)
                                      Positioned(
                                        right: 8,
                                        top: 8,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                            shape: BoxShape.circle,
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 18,
                                            minHeight: 18,
                                          ),
                                          child: Text(
                                            '${cartBooks.length}',
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSecondary,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          onSubmitted: (query) {
                            _searchFocusNode.unfocus();
                            if (query.trim().isNotEmpty) {
                              ref
                                  .read(marketplaceProvider.notifier)
                                  .searchBooks(query.trim());
                            }
                          },
                          onTap: () {
                            _searchFocusNode.requestFocus();
                          },
                        ),
                      ),
                    ),

                    // Offline / Error States
                    if (state.isOffline && state.books.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.wifi_off,
                                size: 50,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.54),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'You are offline.',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                'Connect to the internet to discover new books.',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () => ref
                                    .read(marketplaceProvider.notifier)
                                    .retryInitialLoad(),
                                child: Text('Retry'),
                              ),
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
                              Icon(
                                Icons.error_outline,
                                size: 50,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                state.errorMessage!,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () => ref
                                    .read(marketplaceProvider.notifier)
                                    .retryInitialLoad(),
                                child: Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Main Content (Hero + Carousel + Sections)
                    if (state.searchQuery.isEmpty) ...[
                      // Hero Carousel - Show Bestsellers
                      if (state.bestsellers.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 20.0,
                              bottom: 10.0,
                            ),
                            child: HeroCarousel(
                              leadingWidget: const WelcomeCarouselCard(),
                              books: state.bestsellers
                                  .where((book) {
                                    // Only show books with cover images
                                    final formats =
                                        book['formats']
                                            as Map<String, dynamic>?;
                                    return formats != null &&
                                        (formats['image/jpeg'] != null ||
                                            formats.containsKey('image/jpeg'));
                                  })
                                  .take(5)
                                  .toList(),
                            ),
                          ),
                        ),

                      // New & Trending (Overlapped Carousel) - Filter books without covers
                      if (state.recentBooks.isNotEmpty)
                        SliverToBoxAdapter(
                          child: _buildCarousel(
                            state.recentBooks.where((book) {
                              // Only show books with cover images
                              final formats =
                                  book['formats'] as Map<String, dynamic>?;
                              return formats != null &&
                                  (formats['image/jpeg'] != null ||
                                      formats.containsKey('image/jpeg'));
                            }).toList(),
                          ),
                        ),

                      // Bestsellers List (Horizontal)
                      const SliverToBoxAdapter(child: BestsellersSection()),

                      // Categories
                      SliverToBoxAdapter(child: CategoriesSection()),
                    ],

                    // Search Results Grid
                    if (state.searchQuery.isNotEmpty)
                      SliverPadding(
                        padding: EdgeInsets.all(
                          context.isMobile ? AppSpacing.md : AppSpacing.lg,
                        ),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: context.gridColumns,
                                childAspectRatio: 0.66, // Standard book ratio
                                crossAxisSpacing: AppSpacing.md,
                                mainAxisSpacing: AppSpacing.md,
                              ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index < state.books.length) {
                                return MarketplaceCard(
                                  book: state.books[index],
                                );
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            },
                            childCount: state.isLoading
                                ? state.books.length + 1
                                : state.books.length,
                          ),
                        ),
                      ),

                    // Loading Indicator (for pagination)
                    if (state.isLoading && state.searchQuery.isNotEmpty)
                      const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: bodyContent,
    );
  }
}
