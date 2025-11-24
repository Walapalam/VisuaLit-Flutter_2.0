import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:visualit/core/theme/app_theme.dart';

class HomeBackground extends StatelessWidget {
  const HomeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Deep dark background or Creative Green Gradient for Light Mode
        Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? null
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE8F5E9), // Very light green
                      Color(0xFFF1F8E9), // Light green-yellow tint
                      Color(0xFFFFFFFF), // White center
                      Color(0xFFE0F2F1), // Light teal tint
                    ],
                    stops: [0.0, 0.3, 0.6, 1.0],
                  ),
            color: isDark ? AppTheme.black : null,
          ),
        ),
        // Top-left subtle green glow
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryGreen.withOpacity(
                isDark ? 0.15 : 0.15,
              ), // Increased opacity for light mode
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(0.2),
                  blurRadius: 100,
                  spreadRadius: 50,
                ),
              ],
            ),
          ),
        ),
        // Bottom-right subtle glow
        Positioned(
          bottom: -50,
          right: -50,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryGreen.withOpacity(isDark ? 0.1 : 0.1),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(0.15),
                  blurRadius: 80,
                  spreadRadius: 40,
                ),
              ],
            ),
          ),
        ),
        // Blur filter to create the atmospheric effect
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
          child: Container(color: Colors.transparent),
        ),
        // Mesh gradient overlay (optional, for texture)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withOpacity(0.02),
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                    ]
                  : [
                      AppTheme.primaryGreen.withOpacity(0.05),
                      Colors.transparent,
                      Colors.white.withOpacity(0.2),
                    ],
            ),
          ),
        ),
      ],
    );
  }
}
