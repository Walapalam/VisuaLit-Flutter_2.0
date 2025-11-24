import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:visualit/features/library/presentation/library_controller.dart';
import 'package:visualit/features/library/presentation/widgets/book_details_sheet.dart';
import 'package:shimmer/shimmer.dart';
import 'package:visualit/core/theme/app_theme.dart';

import '../../reader/data/book_data.dart';

// State provider for view mode
final libraryViewModeProvider = StateProvider<LibraryViewMode>(
  (ref) => LibraryViewMode.grid,
);

enum LibraryViewMode { grid, list }

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryState = ref.watch(libraryControllerProvider);
    final libraryController = ref.read(libraryControllerProvider.notifier);
    final viewMode = ref.watch(libraryViewModeProvider);

    return Scaffold(
      backgroundColor: AppTheme.black,
      body: libraryState.when(
        loading: () => _buildLoadingState(context, viewMode),
        error: (err, stack) => _buildErrorState(err.toString()),
        data: (books) {
          if (books.isEmpty) {
            return _buildEmptyState(libraryController);
          }
          return _buildLibraryContent(
            context,
            books,
            libraryController,
            ref,
            viewMode,
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, LibraryViewMode viewMode) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.8, // limit height to avoid covering app bar
      builder: (context, scrollController) {
        return SafeArea(
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              _buildHeader(context, 0, null),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              if (viewMode == LibraryViewMode.grid)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 160,
                          childAspectRatio: 0.66, // Standard 2:3 ratio
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 16,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const LibraryBookCardSkeleton(),
                      childCount: 9,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const LibraryListCardSkeleton(),
                      childCount: 6,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          const Text(
            'Error loading library',
            style: TextStyle(
              color: AppTheme.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              color: AppTheme.white.withOpacity(0.6),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(LibraryController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 80,
            color: AppTheme.primaryGreen.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your library is empty',
            style: TextStyle(
              color: AppTheme.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add books to get started',
            style: TextStyle(
              color: AppTheme.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => controller.pickAndProcessBooks(),
            icon: const Icon(Icons.add, color: AppTheme.black),
            label: const Text(
              'Add Books',
              style: TextStyle(
                color: AppTheme.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int bookCount, WidgetRef? ref) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title and count
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Library',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (bookCount > 0)
                  Text(
                    '$bookCount ${bookCount == 1 ? 'book' : 'books'}',
                    style: TextStyle(
                      color: AppTheme.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
              ],
            ),

            // View toggle
            if (ref != null) Row(children: [_buildViewToggle(ref)]),
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggle(WidgetRef ref) {
    final viewMode = ref.watch(libraryViewModeProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          _buildToggleButton(
            icon: Icons.grid_view_rounded,
            isSelected: viewMode == LibraryViewMode.grid,
            onTap: () => ref.read(libraryViewModeProvider.notifier).state =
                LibraryViewMode.grid,
          ),
          _buildToggleButton(
            icon: Icons.view_list_rounded,
            isSelected: viewMode == LibraryViewMode.list,
            onTap: () => ref.read(libraryViewModeProvider.notifier).state =
                LibraryViewMode.list,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryGreen.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected
              ? AppTheme.primaryGreen
              : AppTheme.white.withOpacity(0.5),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildLibraryContent(
    BuildContext context,
    List<Book> books,
    LibraryController controller,
    WidgetRef ref,
    LibraryViewMode viewMode,
  ) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          _buildHeader(context, books.length, ref),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Books Grid or List
          if (viewMode == LibraryViewMode.grid)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 160, // Wider cards (2 columns on phone)
                  childAspectRatio: 0.66, // Standard 2:3 ratio
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final book = books[index];
                  return _buildBookCard(context, book, controller);
                }, childCount: books.length),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final book = books[index];
                  return _buildListCard(context, book, controller);
                }, childCount: books.length),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildBookCard(
    BuildContext context,
    Book book,
    LibraryController controller,
  ) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black54,
        useRootNavigator: true,
        builder: (_) => BookDetailsSheet(book: book, controller: controller),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Cover Image
              Container(
                color: Colors.grey[900],
                child: book.coverImageBytes != null
                    ? Image.memory(
                        Uint8List.fromList(book.coverImageBytes!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholder();
                        },
                      )
                    : _buildPlaceholder(),
              ),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.95),
                    ],
                    stops: const [0.0, 0.5, 0.8, 1.0],
                  ),
                ),
              ),

              // Content
              Positioned(
                bottom: 12,
                left: 10,
                right: 10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      book.title ?? 'Loading...',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                      ),
                    ),
                    if (book.author != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        book.author!,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.white.withOpacity(0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          shadows: const [
                            Shadow(color: Colors.black, blurRadius: 4),
                          ],
                        ),
                      ),
                    ],
                    // Progress Indicator for partial ready
                    if (book.status == ProcessingStatus.partiallyReady)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: book.processingProgress,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryGreen,
                            ),
                            minHeight: 3,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Status Indicators
              if (book.status == ProcessingStatus.error)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: book.failedPermanently ? Colors.black : Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      book.failedPermanently
                          ? Icons.block
                          : Icons.error_outline,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),

              // Processing Overlay
              if (book.status == ProcessingStatus.processing)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryGreen,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListCard(
    BuildContext context,
    Book book,
    LibraryController controller,
  ) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black54,
        useRootNavigator: true,
        builder: (_) => BookDetailsSheet(book: book, controller: controller),
      ),
      onLongPress: () {
        context.pushNamed(
          'bookReader',
          pathParameters: {'bookId': book.id.toString()},
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
        ),
        child: Row(
          children: [
            // Book Cover
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 60,
                height: 90, // 2:3 aspect ratio (width:height)
                color: Colors.grey[900],
                child: book.coverImageBytes != null
                    ? Image.memory(
                        Uint8List.fromList(book.coverImageBytes!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholder();
                        },
                      )
                    : _buildPlaceholder(),
              ),
            ),

            const SizedBox(width: 12),

            // Book Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title ?? 'Loading...',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author ?? 'Unknown Author',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.white.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                  if (book.status == ProcessingStatus.partiallyReady) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: book.processingProgress,
                        backgroundColor: Colors.grey[800],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryGreen,
                        ),
                        minHeight: 3,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Status/Action
            if (book.status == ProcessingStatus.processing)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppTheme.primaryGreen,
                  strokeWidth: 2,
                ),
              )
            else if (book.status == ProcessingStatus.error)
              Icon(
                book.failedPermanently ? Icons.block : Icons.error_outline,
                color: book.failedPermanently ? Colors.black : Colors.red,
                size: 20,
              )
            else
              Icon(
                Icons.chevron_right,
                color: AppTheme.white.withOpacity(0.3),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[900],
      child: Center(child: Icon(Icons.book, size: 40, color: Colors.grey[700])),
    );
  }
}

class LibraryBookCardSkeleton extends StatelessWidget {
  const LibraryBookCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(color: Colors.grey[900]),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 12,
              width: double.infinity,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(height: 12, width: 60, color: Colors.grey[900]),
          ),
        ],
      ),
    );
  }
}

class LibraryListCardSkeleton extends StatelessWidget {
  const LibraryListCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(width: 60, height: 85, color: Colors.grey[900]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      height: 14,
                      width: double.infinity,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      height: 12,
                      width: 100,
                      color: Colors.grey[900],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
