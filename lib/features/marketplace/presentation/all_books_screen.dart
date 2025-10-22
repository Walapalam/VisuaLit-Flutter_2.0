// lib/features/marketplace/presentation/all_books_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/marketplace/presentation/marketplace_providers.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/features/marketplace/presentation/marketplace_screen.dart'; // For _BookCard and RetryNetworkImage
import 'package:visualit/features/Cart/presentation/CartNotifier.dart';

class AllBooksScreen extends ConsumerStatefulWidget {
  const AllBooksScreen({super.key});

  @override
  ConsumerState<AllBooksScreen> createState() => _AllBooksScreenState();
}

class _AllBooksScreenState extends ConsumerState<AllBooksScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    final state = ref.read(marketplaceProvider);
    if (state.books.isEmpty) {
      ref.read(marketplaceProvider.notifier).loadBooks(reset: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = ref.read(marketplaceProvider);
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      if (!state.isLoading && state.nextUrl != null) {
        ref.read(marketplaceProvider.notifier).loadBooks();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(marketplaceProvider);

    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: 40,
          child: TextField(
            controller: _searchController,
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
                ref.read(marketplaceProvider.notifier).searchBooks(query.trim());
              }
            },
          ),
        ),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: state.isLoading && state.books.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.books.isEmpty
          ? const Center(child: Text('No books found'))
          : RefreshIndicator(
        onRefresh: () async {
          await ref.read(marketplaceProvider.notifier).loadBooks(reset: true);
        },
        child: GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2 / 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: state.books.length + (state.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < state.books.length) {
                return BookCard(book: state.books[index]);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }
        ),
      ),
    );
  }
}

class BookCard extends ConsumerWidget {
  final Map<String, dynamic> book;

  const BookCard({required this.book, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coverUrl = book['formats']['image/jpeg'];

    return GestureDetector(
      onTap: () => _showBookDialog(context, ref, book),
      child: Card(
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: coverUrl != null
                  ? RetryNetworkImage(url: coverUrl, fit: BoxFit.cover)
                  : Container(
                color: Theme.of(context).colorScheme.surface,
                child: const Icon(Icons.book),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                book['title'] ?? 'Unknown',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showBookDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> book) {
  final coverUrl = book['formats']['image/jpeg'];

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (coverUrl != null)
                RetryNetworkImage(url: coverUrl, height: 300, fit: BoxFit.contain),
              const SizedBox(height: 16),
              Text(book['title'] ?? 'Unknown', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                book['authors'] != null && book['authors'].isNotEmpty
                    ? book['authors'][0]['name']
                    : 'Unknown Author',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface,
            ),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // You may need to import cartProvider if you want to add to cart
              ref.read(cartProvider.notifier).addBook(book, context);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
            ),
            child: const Text('Add to Cart'),
          ),
        ],
      );
    },
  );
}
