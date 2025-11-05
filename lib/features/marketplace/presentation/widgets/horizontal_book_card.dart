import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/Cart/presentation/CartNotifier.dart';
import 'package:visualit/features/marketplace/presentation/widgets/retry_network_image.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'book_dialog.dart';

class HorizontalBookCard extends ConsumerWidget {
  final Map<String, dynamic> book;

  const HorizontalBookCard({required this.book, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coverUrl = book['formats']['image/jpeg'];

    return GestureDetector(
      onTap: () => showBookDialog(context, ref, book),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: coverUrl != null
                    ? RetryNetworkImage(url: coverUrl, fit: BoxFit.cover, width: double.infinity)
                    : Container(color: Theme.of(context).colorScheme.surface, child: const Icon(Icons.book, size: 40)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book['title'] ?? 'Unknown',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
