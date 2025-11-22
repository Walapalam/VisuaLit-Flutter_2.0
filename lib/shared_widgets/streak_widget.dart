import 'package:flutter/material.dart';
import 'package:visualit/core/theme/app_theme.dart';

class StreakWidget extends StatelessWidget {
  final int streakDays;

  const StreakWidget({super.key, required this.streakDays});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'x$streakDays',
          style: const TextStyle(
            color: AppTheme.primaryGreen,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        // Fire emoji superscripted like mathematical notation
        Transform.translate(
          offset: const Offset(2, -6),
          child: const Text('🔥', style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }
}
