import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/features/library/presentation/library_controller.dart';
import '../../../core/providers/isar_provider.dart';
import 'widgets/reading_streak_card.dart';
import 'widgets/book_shelf.dart';
import 'widgets/empty_library_view.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isarAsync = ref.watch(isarDBProvider);

    return isarAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Database Error: $err')),
      data: (isar) {
        final libraryState = ref.watch(libraryControllerProvider);
        final libraryController = ref.read(libraryControllerProvider.notifier);

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
                        BookShelf(
                          title: 'Your Library',
                          books: books,
                          showViewAll: true,
                          viewAllRoute: '/library',
                        ),
                        if (books.isEmpty)
                          EmptyLibraryView(
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
