import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:visualit/core/theme/app_theme.dart';

class GlassSearchBar extends StatelessWidget {
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const GlassSearchBar({
    super.key,
    this.onTap,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(35), // Match bottom nav bar
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(35), // Match bottom nav bar
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(35),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Icon(Icons.search, color: AppTheme.white.withOpacity(0.6)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: IgnorePointer(
                        ignoring:
                            onTap !=
                            null, // Ignore input if it's just a tap button
                        child: TextField(
                          controller: controller,
                          onChanged: onChanged,
                          style: const TextStyle(color: AppTheme.white),
                          decoration: InputDecoration(
                            hintText: 'Search books, authors...',
                            hintStyle: TextStyle(
                              color: AppTheme.white.withOpacity(0.4),
                              fontSize: 15,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
