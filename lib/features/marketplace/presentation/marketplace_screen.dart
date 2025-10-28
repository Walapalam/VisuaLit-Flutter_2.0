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
import 'package:shimmer/shimmer.dart';

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(marketplaceProvider);
    final notifier = ref.read(marketplaceProvider.notifier);
    final cartBooks = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: showAllBooks
            ? _AllBooksView(
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
              SliverToBoxAdapter(child: _HeroBanner(onSeeAllBooks: _showAllBooks)),

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
                        (context, index) {
                      if (index < state.books.length) {
                        return _BookCard(book: state.books[index]);
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
  final VoidCallback onSeeAllBooks;
  const _HeroBanner({required this.onSeeAllBooks});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15, right: 15, bottom: 5, left: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discover Free Books',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Thousands of classics from Project Gutenberg',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15, left: 15),
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 25),
                onPressed: onSeeAllBooks,
                tooltip: 'See all books',
              ),
            ),
          )
        ],
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
        if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: context.bookShelfHeight,
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
        if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: context.bookShelfHeight,
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
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return Shimmer.fromColors(
          baseColor: AppTheme.darkGrey,
          highlightColor: AppTheme.black,
          child: Container(
            height: widget.height,
            width: widget.width,
            color: AppTheme.darkGrey,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        if (_retryCount < widget.maxRetries) {
          _retryCount++;
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) setState(() {});
          });
          return Shimmer.fromColors(
            baseColor: AppTheme.darkGrey,
            highlightColor: AppTheme.black,
            child: Container(
              height: widget.height,
              width: widget.width,
              color: AppTheme.darkGrey,
            ),
          );
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

class _AllBooksView extends StatefulWidget {
  final TextEditingController searchController;
  final ScrollController scrollController;
  final WidgetRef ref;
  final List cartBooks;
  final VoidCallback onBack;

  const _AllBooksView({
    required this.searchController,
    required this.scrollController,
    required this.ref,
    required this.cartBooks,
    required this.onBack,
    Key? key,
  }) : super(key: key);

  @override
  State<_AllBooksView> createState() => _AllBooksViewState();
}

class _AllBooksViewState extends State<_AllBooksView> {
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
          child: state.isLoading
              ? GridView.builder(
            itemCount: 8,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (context, index) => const BookCardSkeleton(),
          )
              : GridView.builder(
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
              return _BookCard(book: state.books[index]);
            },
          ),
        )
      ],
    );
  }
}

class BookCardSkeleton extends StatelessWidget {
  const BookCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.darkGrey,
      highlightColor: AppTheme.black,
      child: Card(
        elevation: 4,
        color: AppTheme.darkGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                child: Container(
                  color: AppTheme.darkGrey,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  height: 16,
                  color: AppTheme.darkGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HorizontalBookCardSkeleton extends StatelessWidget {
  const HorizontalBookCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.darkGrey,
      highlightColor: AppTheme.black,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(color: AppTheme.darkGrey),
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(height: 12, color: AppTheme.darkGrey),
            ),
          ],
        ),
      ),
    );
  }
}
