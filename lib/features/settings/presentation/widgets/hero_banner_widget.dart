import 'package:flutter/material.dart';
import 'package:visualit/core/theme/app_theme.dart';

class HeroBannerWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color startColor;
  final Color endColor;

  const HeroBannerWidget({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.startColor = AppTheme.primaryGreen,
    this.endColor = AppTheme.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive height
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    // Determine height based on screen width (responsive)
    double bannerHeight = 150; // Default for mobile

    if (screenWidth >= AppTheme.tabletBreakpoint) {
      // Desktop
      bannerHeight = 250;
    } else if (screenWidth >= AppTheme.mobileBreakpoint) {
      // Tablet
      bannerHeight = 200;
    }

    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child!,
          ),
        );
      },
      child: Container(
        height: bannerHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [startColor, endColor],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ) ??
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white70,
                              ) ??
                              const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
