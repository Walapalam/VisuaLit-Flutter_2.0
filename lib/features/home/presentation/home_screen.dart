import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/features/library/presentation/library_controller.dart';
import 'package:visualit/features/reader/data/book_data.dart' as db;
import 'package:visualit/shared_widgets/book_card.dart';
import 'package:visualit/shared_widgets/expandable_import_button.dart';
import 'package:visualit/shared_widgets/streak_widget.dart';
import 'package:visualit/features/marketplace/presentation/marketplace_providers.dart';
import 'package:visualit/features/auth/presentation/auth_controller.dart';
import '../../../core/providers/isar_provider.dart';
import 'widgets/home_background.dart';
import 'widgets/glass_search_bar.dart';
import 'widgets/currently_reading_carousel.dart';
import 'widgets/section_header.dart';
import 'widgets/empty_library_view.dart';
import 'package:visualit/core/services/toast_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isarAsync = ref.watch(isarDBProvider);

    return isarAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppTheme.black,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        backgroundColor: AppTheme.black,
        body: Center(
          child: Text(
            'Database Error: $err',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      data: (isar) {
        final libraryState = ref.watch(libraryControllerProvider);
        final libraryController = ref.read(libraryControllerProvider.notifier);

        return Scaffold(
          backgroundColor: AppTheme.black, // Fallback
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
                      style: const TextStyle(color: Colors.white),
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
                                    final authState = ref.watch(
                                      authControllerProvider,
                                    );
                                    final user = authState.user;
                                    final firstName =
                                        user?.displayName?.split(' ').first ??
                                        'Reader';

                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Good Evening,',
                                              style: TextStyle(
                                                color: AppTheme.white
                                                    .withOpacity(0.7),
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              firstName,
                                              style: const TextStyle(
                                                color: AppTheme.white,
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Streak Widget instead of profile icon
                                        const StreakWidget(), // TODO: Get actual streak from user data
                                      ],
                                    );
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
                                    _HorizontalMarketplaceBookList(
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
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                  ),
                                  child: Text(
                                    'Continue Reading',
                                    textAlign: TextAlign.center, // Centered
                                    style: TextStyle(
                                      color: AppTheme.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
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
                                _HorizontalBookList(books: books),
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
                                    _HorizontalMarketplaceBookList(
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
                        const SliverToBoxAdapter(child: SizedBox(height: 100)),
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

class _HorizontalBookList extends StatelessWidget {
  final List<db.Book> books;

  const _HorizontalBookList({required this.books});

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return Container(
        height: 150,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'No books available',
            style: TextStyle(color: Colors.white.withOpacity(0.4)),
          ),
        ),
      );
    }

    return SizedBox(
      height: 240, // Height for BookCard + Text
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return BookCard(
            imageBytes: book.coverImageBytes != null
                ? Uint8List.fromList(book.coverImageBytes!)
                : null,
            title: book.title ?? 'No Title',
            author: book.author ?? 'Unknown',
            onTap: () {
              if (book.status == db.ProcessingStatus.ready) {
                context.pushNamed(
                  'epubReader',
                  pathParameters: {'bookId': book.id.toString()},
                );
              } else {
                ToastService.show(
                  context,
                  '${book.title ?? 'Book'} is still processing...',
                  type: ToastType.info,
                );
              }
            },
          );
        },
      ),
    );
  }
}

// Widget for displaying marketplace books (different structure from local books)
class _HorizontalMarketplaceBookList extends StatelessWidget {
  final List<dynamic> books;

  const _HorizontalMarketplaceBookList({required this.books});

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return Container(
        height: 150,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'No books available',
            style: TextStyle(color: Colors.white.withOpacity(0.4)),
          ),
        ),
      );
    }

    return SizedBox(
      height: 240, // Height for BookCard + Text
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          final coverUrl = book['formats']?['image/jpeg'] as String?;
          final title = book['title'] as String? ?? 'No Title';
          final author = book['authors']?.isNotEmpty == true
              ? book['authors'][0]['name'] as String? ?? 'Unknown'
              : 'Unknown';

          return BookCard(
            imageBytes: null, // Marketplace books use URLs, not bytes
            title: title,
            author: author,
            coverUrl: coverUrl, // Pass URL for network image
            onTap: () {
              // Navigate to marketplace detail or download
              context.push('/marketplace');
            },
          );
        },
      ),
    );
  }
}
