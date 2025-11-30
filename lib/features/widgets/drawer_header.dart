import 'package:flutter/material.dart';
import 'package:visualit/core/theme/app_theme.dart';

class AppDrawerHeader extends StatelessWidget {
  final String displayName;
  final String email;

  const AppDrawerHeader({
    super.key,
    required this.displayName,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onBackground;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        children: [
          // Profile Avatar - Smaller
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryGreen,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'G',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.black, // Always black on green
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // User Name
          Text(
            displayName,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          // Email
          Text(
            email,
            style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
