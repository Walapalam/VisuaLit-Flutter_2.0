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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the database provider itself
    final isarAsync = ref.watch(isarDBProvider);

    // Handle the loading and error states of the database before building the rest of the UI
    return isarAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Database Error: $err')),
      data: (isar) {
        // ONLY when the database is ready, do we watch the libraryController
        final libraryState = ref.watch(libraryControllerProvider);
        final libraryController = ref.read(libraryControllerProvider.notifier);

        // Example streak data
        final streakHistory = List<bool>.generate(42, (i) => i % 3 != 0);
        final currentStreak = 5;
        final longestStreak = 12;
        final totalDays = 30;

        return libraryState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (books) {
            return Container(
              color: AppTheme.darkGrey,
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search books, authors, genres...',
                        hintStyle: const TextStyle(color: AppTheme.grey),
                        filled: true,
                        fillColor: AppTheme.black,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.search, color: AppTheme.grey),
                      ),
                      style: const TextStyle(color: AppTheme.white),
                    ),
                  ),
                  ReadingStreakCard(
                    streakHistory: streakHistory,
                    currentStreak: currentStreak,
                    longestStreak: longestStreak,
                    totalDays: totalDays,
                  ),
                  const SizedBox(height: 24),
                  _BookShelf(
                    title: 'Your Library',
                    books: books,
                    showViewAll: true,
                    viewAllRoute: '/library',
                  ),
                  if (books.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'No books found.\nStart by importing your first book!',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppTheme.grey, fontSize: 18),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.upload_file),
                              label: const Text('Select Your Books'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGreen,
                                foregroundColor: AppTheme.black,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => libraryController.pickAndProcessBooks(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Add Books from Folder'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: AppTheme.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => libraryController.scanAndProcessBooks(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ** WIDGET DEFINITIONS ADDED HERE TO FIX THE ERROR **

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
    final double shelfHeight = MediaQuery.of(context).size.width * 0.6;

    if (books.isEmpty) {
      return const SizedBox.shrink();
    }

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
                style: const TextStyle(color: AppTheme.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              if (showViewAll)
                TextButton(
                  onPressed: () {
                    if (viewAllRoute != null) {
                      context.go(viewAllRoute!);
                    }
                  },
                  child: const Text('View All', style: TextStyle(color: AppTheme.primaryGreen)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: shelfHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return BookCard(
                imageBytes: book.coverImageBytes != null ? Uint8List.fromList(book.coverImageBytes!) : null,
                title: book.title ?? 'No Title',
                author: book.author ?? 'Unknown Author',
                onTap: () {
                  if (book.status == db.ProcessingStatus.ready) {
                    context.goNamed('bookReader', pathParameters: {'bookId': book.id.toString()});
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
      color: AppTheme.black,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reading Streak',
              style: TextStyle(
                color: Colors.white,
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
                      color: streakHistory[i] ? AppTheme.primaryGreen : Colors.grey[900],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            const Divider(color: AppTheme.darkGrey),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StreakStat(label: 'Current', value: currentStreak, fontSize: 14),
                _StreakStat(label: 'Longest', value: longestStreak, fontSize: 14),
                _StreakStat(label: 'Total Days', value: totalDays, fontSize: 14),
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

  const _StreakStat({required this.label, required this.value, this.fontSize = 20});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value', style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold, fontSize: fontSize)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppTheme.grey, fontSize: 10)),
      ],
    );
  }
}