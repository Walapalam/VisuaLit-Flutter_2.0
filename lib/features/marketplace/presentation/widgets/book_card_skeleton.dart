import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:visualit/core/theme/app_theme.dart';

class BookCardSkeleton extends StatelessWidget {
  const BookCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.darkGrey,
      highlightColor: AppTheme.black,
      child: Card(
        elevation: 4,
        color: AppTheme.darkGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: Container(
                  color: AppTheme.darkGrey,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  height: 16,
                  color: AppTheme.darkGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
