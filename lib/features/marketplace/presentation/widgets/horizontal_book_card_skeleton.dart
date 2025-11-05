import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:visualit/core/theme/app_theme.dart';

class HorizontalBookCardSkeleton extends StatelessWidget {
  const HorizontalBookCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.darkGrey,
      highlightColor: AppTheme.black,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(color: AppTheme.darkGrey),
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Container(height: 12, color: AppTheme.darkGrey),
            ),
          ],
        ),
      ),
    );
  }
}
