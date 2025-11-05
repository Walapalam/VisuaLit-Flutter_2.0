import 'package:flutter/material.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/core/utils/responsive_helper.dart';

class HeroBanner extends StatelessWidget {
  final VoidCallback onSeeAllBooks;
  const HeroBanner({required this.onSeeAllBooks, super.key});

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
