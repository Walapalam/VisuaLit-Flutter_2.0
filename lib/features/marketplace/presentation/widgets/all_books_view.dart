import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/features/marketplace/presentation/marketplace_notifier.dart';
import 'package:visualit/features/marketplace/presentation/marketplace_providers.dart';
import 'package:visualit/features/marketplace/presentation/widgets/book_card.dart';
import 'package:visualit/features/marketplace/presentation/widgets/book_card_skeleton.dart';

class AllBooksView extends StatefulWidget {
  final TextEditingController searchController;
  final ScrollController scrollController;
  final WidgetRef ref;
  final List cartBooks;
  final VoidCallback onBack;

  const AllBooksView({
    required this.searchController,
    required this.scrollController,
    required this.ref,
    required this.cartBooks,
    required this.onBack,
    Key? key,
  }) : super(key: key);

  @override
  State<AllBooksView> createState() => _AllBooksViewState();
}

class _AllBooksViewState extends State<AllBooksView> {
  int columns = 3;
  String sortOption = 'Default';

  // Scroll indicator state
  double _indicatorPercent = 0.0; // 0..1 across scroll extent
  double _lastPixels = 0.0;
  bool _scrollingDown = true;
  bool _isIndicatorVisible = false;
  Timer? _hideIndicatorTimer;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _hideIndicatorTimer?.cancel();
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    final sc = widget.scrollController;
    if (!sc.hasClients) return;
    final pos = sc.position;
    final pixels = pos.pixels;
    final max = pos.maxScrollExtent;

    setState(() {
      _indicatorPercent = max > 0 ? (pixels / max).clamp(0.0, 1.0) : 0.0;
      _scrollingDown = pixels >= _lastPixels;
      _isIndicatorVisible = true;
    });

    _lastPixels = pixels;

    _hideIndicatorTimer?.cancel();
    _hideIndicatorTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() => _isIndicatorVisible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.ref.watch(marketplaceProvider);

    return Column(
      children: [
        AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back to Marketplace',
            onPressed: () {
              setState(() {
                columns = 3;
                sortOption = 'Default';
              });
              widget.searchController.clear();
              widget.ref.read(marketplaceProvider.notifier).searchBooks('');
              widget.onBack();
            },
          ),
          title: SizedBox(
            height: 40,
            child: TextField(
              controller: widget.searchController,
              decoration: InputDecoration(
                hintText: 'Search books...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                ),
              ),
              onSubmitted: (query) {
                if (query.trim().isNotEmpty) {
                  widget.ref.read(marketplaceProvider.notifier).searchBooks(query.trim());
                }
              },
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          actions: [
            if (state.isOffline)
              const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(Icons.wifi_off, color: Colors.white),
              ),
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () => context.goNamed('cart'),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.sort, size: 20),
              const SizedBox(width: 4),
              DropdownButton<String>(
                value: sortOption,
                items: [
                  'Default',
                  'Title',
                  'Author',
                  'Newest',
                  'Popular',
                ].map((option) => DropdownMenuItem(
                  value: option,
                  child: Text(option),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    sortOption = value!;
                  });
                },
                hint: const Text('Sort by'),
              ),
              const SizedBox(width: 24),
              const Icon(Icons.grid_view, size: 20),
              const SizedBox(width: 4),
              DropdownButton<int>(
                value: columns,
                items: [2, 3, 4].map((col) => DropdownMenuItem(
                  value: col,
                  child: Text('$col per row'),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    columns = value!;
                  });
                },
                hint: const Text('Columns'),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.clear, color: Colors.red),
                tooltip: 'Clear filters',
                onPressed: () {
                  setState(() {
                    columns = 3;
                    sortOption = 'Default';
                  });
                  widget.searchController.clear();
                  widget.ref.read(marketplaceProvider.notifier).searchBooks('');
                },
              ),
            ],
          ),
        ),
        // Content area with overlayed scroll indicator
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final height = constraints.maxHeight;
              // Compute top position for indicator with a small margin
              final topPos = 8.0 + (_indicatorPercent * (height - 88.0));

              Widget content = _buildContent(state);

              return Stack(
                children: [
                  Positioned.fill(child: content),

                  // Scroll-following indicator (visible while user scrolls or while loading)
                  if ((_isIndicatorVisible || state.isLoading) && widget.scrollController.hasClients)
                    Positioned(
                      right: 12,
                      top: topPos,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 250),
                        opacity: (_isIndicatorVisible || state.isLoading) ? 1.0 : 0.0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onSurface.withAlpha(20), // ~0.08 * 255
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(38), // ~0.15 * 255
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: state.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(
                                  _scrollingDown ? Icons.arrow_downward : Icons.arrow_upward,
                                  size: 18,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContent(MarketplaceState state) {
    if (state.isInitialLoading) {
      return GridView.builder(
        itemCount: 8,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (context, index) => const BookCardSkeleton(),
      );
    }

    if (state.isOffline && state.books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 50),
            const SizedBox(height: 10),
            const Text('You are offline.'),
            const Text('Connect to the internet to discover new books.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => widget.ref.read(marketplaceProvider.notifier).loadBooks(reset: true),
              child: const Text('Retry'),
            )
          ],
        ),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),
            const SizedBox(height: 10),
            Text(state.errorMessage!),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => widget.ref.read(marketplaceProvider.notifier).loadBooks(reset: true),
              child: const Text('Retry'),
            )
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        // If user scrolled near the end, attempt to load more (the notifier will handle locking)
        if (scrollNotification.metrics.pixels >= scrollNotification.metrics.maxScrollExtent * 0.8) {
          final stateLocal = widget.ref.read(marketplaceProvider);
          if (!stateLocal.isLoading && stateLocal.nextUrl != null) {
            widget.ref.read(marketplaceProvider.notifier).loadBooks();
          }
        }
        return false;
      },
      child: GridView.builder(
        controller: widget.scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: state.books.length,
        itemBuilder: (context, index) {
          return BookCard(book: state.books[index]);
        },
      ),
    );
  }
}
