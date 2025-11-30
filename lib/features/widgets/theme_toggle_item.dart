import 'package:flutter/material.dart';
import 'package:visualit/core/theme/app_theme.dart';

class ThemeToggleItem extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggle;

  const ThemeToggleItem({
    super.key,
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onBackground;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                  color: AppTheme.primaryGreen,
                  size: 22,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    isDark ? 'Dark Mode' : 'Light Mode',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Switch(
                  value: !isDark,
                  onChanged: (value) => onToggle(),
                  activeColor: AppTheme.primaryGreen,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
