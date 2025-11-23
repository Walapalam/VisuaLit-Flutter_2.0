import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/shared_widgets/custom_overlapped_carousel.dart';

class CurrentlyReadingCarousel extends StatelessWidget {
  final List<Book> books;

  const CurrentlyReadingCarousel({super.key, required this.books});

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return _buildEmptyState();
    }

    var screenWidth = MediaQuery.of(context).size.width;

    // Requirements:
    // Width: book cover width (portrait aspect ratio)
    // Height: full book cover height to show it's a book, not a square

    // Book covers are typically 2:3 aspect ratio (width:height)
    final double cardWidth =
        screenWidth * 0.40; // Slightly narrower for portrait
    final double carouselHeight = cardWidth * 1.5; // 2:3 aspect ratio

    // Single book case: Show static card without carousel
    if (books.length == 1) {
      return Center(
        child: SizedBox(
          width: cardWidth,
          height: carouselHeight,
          child: _buildBookCardContent(context, books.first, true),
        ),
      );
    }

    return Center(
      child: CustomOverlappedCarousel(
        items: List.generate(books.length, (index) {
          return _buildBookCard(context, books[index], index);
        }),
        centerItemWidth: cardWidth,
        height: carouselHeight,
        initialIndex: books.length > 1
            ? (books.length / 2).floor()
            : 0, // Start at middle
        onClicked: (index) {
          final book = books[index];
          context.pushNamed(
            'epubReader',
            pathParameters: {'bookId': book.id.toString()},
          );
        },
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, Book book, int index) {
    return CustomOverlappedCarouselItem(
      index: index,
      builder: (context, isFocused) {
        return _buildBookCardContent(context, book, isFocused);
      },
    );
  }

  Widget _buildBookCardContent(
    BuildContext context,
    Book book,
    bool isFocused,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Book Cover
            if (book.coverImageBytes != null)
              Image.memory(
                Uint8List.fromList(book.coverImageBytes!),
                fit: BoxFit.cover,
              )
            else
              Container(
                color: AppTheme.darkGrey,
                child: Center(
                  child: Icon(
                    Icons.book,
                    size: 80,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
              ),

            // Gradient Overlay - stronger at bottom for text visibility
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.95),
                  ],
                  stops: const [0.0, 0.6, 0.85, 1.0],
                ),
              ),
            ),

            // Content
            Positioned(
              bottom: 16,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    book.title ?? 'Untitled',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14, // Reduced from 16
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author ?? 'Unknown Author',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11, // Reduced from 12
                      fontWeight: FontWeight.w500,
                      shadows: const [
                        Shadow(color: Colors.black, blurRadius: 4),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Animated Continue Button - only show when focused
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: isFocused ? 35 : 0, // Increased from 40 to 50
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: isFocused ? 1.0 : 0.0,
                      child: isFocused
                          ? Padding(
                              padding: const EdgeInsets.only(
                                top: 3,
                              ), // Reduced from 10
                              child: GestureDetector(
                                onTap: () {
                                  context.pushNamed(
                                    'epubReader',
                                    pathParameters: {
                                      'bookId': book.id.toString(),
                                    },
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF1A1A1A,
                                    ), // Match bottom nav
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: AppTheme.primaryGreen.withOpacity(
                                        0.3,
                                      ),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    'Continue',
                                    style: TextStyle(
                                      color: AppTheme.primaryGreen,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
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

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.library_books_outlined,
              size: 48,
              color: AppTheme.primaryGreen.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No books in progress',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
