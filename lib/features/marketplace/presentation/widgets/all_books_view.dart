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
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
        Expanded(
          child: _buildContent(state),
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

    return GridView.builder(
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
    );
  }
}
