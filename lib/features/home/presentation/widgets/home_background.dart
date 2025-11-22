import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:visualit/core/theme/app_theme.dart';

class HomeBackground extends StatelessWidget {
  const HomeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Deep dark background
        Container(color: AppTheme.black),
        // Top-left subtle green glow
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryGreen.withOpacity(0.15),
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
              color: AppTheme.primaryGreen.withOpacity(0.1),
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
              colors: [
                Colors.white.withOpacity(0.02),
                Colors.transparent,
                Colors.black.withOpacity(0.4),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
