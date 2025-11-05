import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/Cart/presentation/CartNotifier.dart';
import 'package:visualit/features/marketplace/presentation/widgets/retry_network_image.dart';
import 'package:visualit/core/theme/app_theme.dart';

void showBookDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> book) {
  final coverUrl = book['formats']['image/jpeg'];

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (coverUrl != null)
                RetryNetworkImage(url: coverUrl, height: 300, fit: BoxFit.contain),
              const SizedBox(height: 16),
              Text(book['title'] ?? 'Unknown', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                book['authors'] != null && book['authors'].isNotEmpty
                    ? book['authors'][0]['name']
                    : 'Unknown Author',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface,
            ),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(cartProvider.notifier).addBook(book, context);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
            ),
            child: const Text('Add to Cart'),
          ),
        ],
      );
    },
  );
}
