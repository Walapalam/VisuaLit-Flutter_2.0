import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/features/library/presentation/library_controller.dart';
import 'package:visualit/features/reader/data/book_data.dart' as db;
import 'package:visualit/shared_widgets/book_card.dart';
import '../../../core/providers/isar_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _showMissingFilesDialog(BuildContext context, List<db.Book> missingBooks, dynamic libraryController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Books Need Re-importing'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Found ${missingBooks.length} book(s) with missing files. These were likely imported before the storage fix and need to be re-imported:',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              ...missingBooks.take(5).map((book) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '• ${book.title ?? 'Unknown Book'}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              )),
              if (missingBooks.length > 5)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '... and ${missingBooks.length - 5} more',
                    style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                ),
              const SizedBox(height: 12),
              const Text(
                'Would you like to remove these books from your library? You can then re-import them to store them permanently.',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final count = await libraryController.deleteAllBooksWithMissingFiles();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Removed $count book(s). You can now re-import them.'),
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            },
            child: const Text('Remove All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isarAsync = ref.watch(isarDBProvider);

    return isarAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Database Error: $err')),
      data: (isar) {
        final libraryState = ref.watch(libraryControllerProvider);
        final libraryController = ref.read(libraryControllerProvider.notifier);

        // Check for books with missing files on first load
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final booksWithMissingFiles = await libraryController.findBooksWithMissingFiles();
          if (booksWithMissingFiles.isNotEmpty && context.mounted) {
            _showMissingFilesDialog(context, booksWithMissingFiles, libraryController);
          }
        });

        final streakHistory = List<bool>.generate(42, (i) => i % 3 != 0);

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.primary,
          body: SafeArea(
            child: libraryState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (books) => CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    floating: true,
                    snap: true,
                    title: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search books, authors, genres...',
                        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.search,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                        ),
                      ),
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        ReadingStreakCard(
                          streakHistory: streakHistory,
                          currentStreak: 5,
                          longestStreak: 12,
                          totalDays: 30,
                        ),
                        const SizedBox(height: 24),
                        _BookShelf(
                          title: 'Your Library',
                          books: books,
                          showViewAll: true,
                          viewAllRoute: '/library',
                        ),
                        if (books.isEmpty)
                          _EmptyLibraryView(
                            onSelectBooks: () => libraryController.pickAndProcessBooks(),
                          ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.folder_open),
                            label: const Text('Add Books from Folder'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              foregroundColor: AppTheme.black,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => libraryController.scanAndProcessBooks(),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyLibraryView extends StatelessWidget {
  final VoidCallback onSelectBooks;

  const _EmptyLibraryView({required this.onSelectBooks});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No books found.\nStart by importing your first book!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Select Your Books'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: AppTheme.black,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onSelectBooks,
            ),
          ],
        ),
      ),
    );
  }
}

class _BookShelf extends StatelessWidget {
  final String title;
  final List<db.Book> books;
  final bool showViewAll;
  final String? viewAllRoute;

  const _BookShelf({
    required this.title,
    required this.books,
    this.showViewAll = false,
    this.viewAllRoute,
  });

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              if (showViewAll)
                TextButton(
                  onPressed: () {
                    if (viewAllRoute != null) context.go(viewAllRoute!);
                  },
                  child: const Text('View All',
                      style: TextStyle(color: AppTheme.primaryGreen)
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: MediaQuery.of(context).size.width * 0.6,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return BookCard(
                imageBytes: book.coverImageBytes != null ?
                Uint8List.fromList(book.coverImageBytes!) : null,
                title: book.title ?? 'No Title',
                author: book.author ?? 'Unknown Author',
                onTap: () {
                  if (book.status == db.ProcessingStatus.ready) {
                    context.goNamed('epubReader', pathParameters: {'bookId': book.id.toString()});
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('${book.title ?? 'Book'} is still processing...'),
                    ));
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class ReadingStreakCard extends StatelessWidget {
  final List<bool> streakHistory;
  final int currentStreak;
  final int longestStreak;
  final int totalDays;

  const ReadingStreakCard({
    super.key,
    required this.streakHistory,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalDays,
  });

  @override
  Widget build(BuildContext context) {
    const int daysPerRow = 7;
    final int numRows = (streakHistory.length / daysPerRow).ceil();
    const double squareSize = 15.0;
    const double spacing = 2.0;

    return Card(
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reading Streak',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: numRows * (squareSize + spacing),
              width: double.infinity,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: daysPerRow,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  childAspectRatio: 1.0,
                ),
                itemCount: streakHistory.length,
                itemBuilder: (context, i) {
                  return Container(
                    width: squareSize,
                    height: squareSize,
                    decoration: BoxDecoration(
                      color: streakHistory[i] ? AppTheme.primaryGreen :
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Divider(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StreakStat(label: 'Current', value: currentStreak),
                _StreakStat(label: 'Longest', value: longestStreak),
                _StreakStat(label: 'Total Days', value: totalDays),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakStat extends StatelessWidget {
  final String label;
  final int value;
  final double fontSize;

  const _StreakStat({
    required this.label,
    required this.value,
    this.fontSize = 14
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
