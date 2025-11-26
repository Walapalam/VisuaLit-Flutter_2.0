import 'package:flutter/material.dart';
import 'package:visualit/core/theme/app_theme.dart';

class WelcomeCarouselCard extends StatelessWidget {
  const WelcomeCarouselCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppTheme.primaryGreen.withOpacity(0.2),
                  Colors.black.withOpacity(0.8),
                ]
              : [AppTheme.primaryGreen.withOpacity(0.1), Colors.white],
        ),
        border: Border.all(
          color: AppTheme.primaryGreen.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.5)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Pattern (Optional)
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.storefront_rounded,
              size: 150,
              color: AppTheme.primaryGreen.withOpacity(0.1),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.waving_hand_rounded,
                    color: AppTheme.primaryGreen,
                    size: 24,
                  ),
                ),
                const Spacer(),
                Text(
                  'Welcome to\nMarketplace',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Discover your next\ngreat read.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
