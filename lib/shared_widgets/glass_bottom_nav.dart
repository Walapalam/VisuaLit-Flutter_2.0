import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:visualit/core/theme/app_theme.dart';

class GlassBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const GlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
      height: 70, // Fixed height for the bar
      decoration: BoxDecoration(
        // Semi-transparent with slight tint to avoid pure transparency artifacts
        color: isDark
            ? const Color(0xFF1A1A1A).withOpacity(0.7)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(35), // Pill shape
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.white.withOpacity(0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10,
            sigmaY: 10,
          ), // Frosted glass effect
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                context,
                0,
                Icons.home_outlined,
                Icons.home,
                'Home',
                isDark,
              ),
              _buildNavItem(
                context,
                1,
                Icons.book_outlined,
                Icons.book,
                'Library',
                isDark,
              ),
              _buildNavItem(
                context,
                2,
                Icons.headphones_outlined,
                Icons.headphones,
                'Audio',
                isDark,
              ),
              _buildNavItem(
                context,
                3,
                Icons.storefront_outlined,
                Icons.storefront,
                'Market',
                isDark,
              ),
              _buildNavItem(
                context,
                4,
                Icons.settings_outlined,
                Icons.settings,
                'Settings',
                isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
    bool isDark,
  ) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark
                          ? AppTheme.primaryGreen.withOpacity(0.2)
                          : AppTheme.primaryGreen)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected
                    ? (isDark ? AppTheme.primaryGreen : Colors.white)
                    : (isDark
                          ? Colors.white.withOpacity(0.6)
                          : Colors.black.withOpacity(0.5)),
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
