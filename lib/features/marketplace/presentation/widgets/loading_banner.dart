import 'package:flutter/material.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/core/theme/theme_extensions.dart';

class LoadingBanner extends StatelessWidget {
  final int loaded;
  final int total;
  final bool fromCache;
  final VoidCallback? onRetry;

  const LoadingBanner({
    required this.loaded,
    required this.total,
    this.fromCache = false,
    this.onRetry,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final percent = total > 0 ? (loaded / total) : 0.0;

    return Container(
      margin: EdgeInsets.all(context.isMobile ? AppSpacing.md : AppSpacing.lg),
      height: context.isMobile ? 140 : 180,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryGreen, Colors.teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            fromCache ? 'Loading cached shelves' : 'Loading books',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            '$loaded of $total shelves ready',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: percent,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (onRetry != null)
                ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white24, foregroundColor: Colors.white),
                  child: const Text('Retry'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

