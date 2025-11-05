// lib/features/marketplace/presentation/all_books_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/marketplace/presentation/marketplace_providers.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/features/marketplace/presentation/widgets/book_card.dart';
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
