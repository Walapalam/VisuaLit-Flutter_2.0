import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:visualit/features/Cart/presentation/CartNotifier.dart';
import 'package:visualit/core/utils/responsive_helper.dart';
import 'package:visualit/core/theme/theme_extensions.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/features/marketplace/presentation/marketplace_notifier.dart';
import 'marketplace_providers.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      ref.read(marketplaceProvider.notifier).loadBooks();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(marketplaceProvider);
    final notifier = ref.read(marketplaceProvider.notifier);
    final cartBooks = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: CustomScrollView(
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
            if (state.searchQuery.isEmpty)
              SliverToBoxAdapter(child: _HeroBanner()),

            // Bestsellers Section (if not searching)
            if (state.searchQuery.isEmpty)
              SliverToBoxAdapter(child: _BestsellersSection()),

            // Categories Section (if not searching)
            if (state.searchQuery.isEmpty)
              SliverToBoxAdapter(child: _CategoriesSection()),

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
                        (context, index) => _BookCard(book: state.books[index]),
                    childCount: state.books.length,
                  ),
                ),
              ),

            // Loading Indicator
            if (state.isLoading)
              const SliverToBoxAdapter(
                child: Center(child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                )),
              ),
          ],
        ),
      ),
    );
  }
}

// Hero Banner Widget
class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(context.isMobile ? AppSpacing.md : AppSpacing.lg),
      height: context.isMobile ? 160 : 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryGreen, Colors.teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Discover Free Books',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thousands of classics from Project Gutenberg',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Bestsellers Section
class _BestsellersSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<dynamic>>(
      future: ref.read(marketplaceProvider.notifier).getBestsellers(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();

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
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) => _HorizontalBookCard(book: snapshot.data![index]),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Categories Section
class _CategoriesSection extends ConsumerWidget {
  final List<Map<String, String>> categories = [
    {'name': 'Fiction', 'subject': 'fiction'},
    {'name': 'Science', 'subject': 'science'},
    {'name': 'History', 'subject': 'history'},
    {'name': 'Philosophy', 'subject': 'philosophy'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...categories.map((category) => _CategoryRow(
          title: category['name']!,
          subject: category['subject']!,
        )),
      ],
    );
  }
}

// Category Row Widget
class _CategoryRow extends ConsumerWidget {
  final String title;
  final String subject;

  const _CategoryRow({required this.title, required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<dynamic>>(
      future: ref.read(marketplaceProvider.notifier).getBooksBySubject(subject),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.isMobile ? AppSpacing.md : AppSpacing.lg, vertical: AppSpacing.md),
              child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
            ),
            SizedBox(
              height: context.bookShelfHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: context.isMobile ? AppSpacing.md : AppSpacing.lg),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) => _HorizontalBookCard(book: snapshot.data![index]),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Horizontal Book Card (for shelves)
class _HorizontalBookCard extends ConsumerWidget {
  final Map<String, dynamic> book;

  const _HorizontalBookCard({required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coverUrl = book['formats']['image/jpeg'];

    return GestureDetector(
      onTap: () => _showBookDialog(context, ref, book),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: coverUrl != null
                    ? RetryNetworkImage(url: coverUrl, fit: BoxFit.cover, width: double.infinity)
                    : Container(color: Theme.of(context).colorScheme.surface, child: const Icon(Icons.book, size: 40)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book['title'] ?? 'Unknown',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// Grid Book Card
class _BookCard extends ConsumerWidget {
  final Map<String, dynamic> book;

  const _BookCard({required this.book});

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
                  : Container(color: Theme.of(context).colorScheme.surface, child: const Icon(Icons.book)),
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

// Book Detail Dialog
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


// Retry Network Image Widget
class RetryNetworkImage extends StatefulWidget {
  final String url;
  final int maxRetries;
  final BoxFit fit;
  final double? height;
  final double? width;

  const RetryNetworkImage({
    required this.url,
    this.maxRetries = 2,
    this.fit = BoxFit.cover,
    this.height,
    this.width,
    super.key,
  });

  @override
  State<RetryNetworkImage> createState() => _RetryNetworkImageState();
}

class _RetryNetworkImageState extends State<RetryNetworkImage> {
  int _retryCount = 0;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      widget.url,
      fit: widget.fit,
      height: widget.height,
      width: widget.width,
      errorBuilder: (context, error, stackTrace) {
        if (_retryCount < widget.maxRetries) {
          _retryCount++;
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) setState(() {});
          });
          return const SizedBox.shrink();
        }
        return Container(
          color: Theme.of(context).colorScheme.surface,
          height: widget.height,
          width: widget.width,
          child: const Center(child: Icon(Icons.broken_image, size: 40)),
        );
      },
    );
  }
}