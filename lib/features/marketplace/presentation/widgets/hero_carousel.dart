import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/features/marketplace/presentation/widgets/book_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HeroCarousel extends ConsumerWidget {
  final List<dynamic> books;

  const HeroCarousel({super.key, required this.books});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (books.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 220,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.9),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          final coverUrl = book['formats']['image/jpeg'];
          final title = book['title'] ?? 'Unknown Title';
          final author = book['authors']?.isNotEmpty == true
              ? book['authors'][0]['name']
              : 'Unknown Author';

          return GestureDetector(
            onTap: () => showBookDialog(context, ref, book),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              child: ClipRRect(
                // Clip for the blur effect
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // 1. Glass Effect Background
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(
                            0.05,
                          ), // Very subtle fill
                          borderRadius: BorderRadius.circular(
                            24,
                          ), // This borderRadius is redundant if ClipRRect handles it, but good for consistency
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    // Decorative background elements
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    // 2. Content
                    Row(
                      children: [
                        // Text Content
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreen.withOpacity(
                                      0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppTheme.primaryGreen.withOpacity(
                                        0.3,
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    'FEATURED',
                                    style: TextStyle(
                                      color: AppTheme.primaryGreen,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  title,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color:
                                        Colors.white, // White text for dark bg
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    height: 1.1,
                                    fontFamily: 'Serif',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  author,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Book Cover
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Container(
                              height: 160,
                              width: 110,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: coverUrl != null
                                    ? Image.network(
                                        coverUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: Colors.grey[800],
                                          child: const Icon(
                                            Icons.book,
                                            color: Colors.white54,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        color: Colors.grey[800],
                                        child: const Icon(
                                          Icons.book,
                                          color: Colors.white54,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
