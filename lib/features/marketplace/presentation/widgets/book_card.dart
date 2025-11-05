import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/Cart/presentation/CartNotifier.dart';
import 'package:visualit/features/marketplace/presentation/widgets/retry_network_image.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'book_dialog.dart';

class BookCard extends ConsumerWidget {
  final Map<String, dynamic> book;

  const BookCard({required this.book, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coverUrl = book['formats']['image/jpeg'];

    return GestureDetector(
      onTap: () => showBookDialog(context, ref, book),
      child: Card(
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: coverUrl != null
                  ? RetryNetworkImage(url: coverUrl, fit: BoxFit.cover)
                  : Container(color: Theme.of(context).colorScheme.surface, child: const Icon(Icons.book)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                book['title'] ?? 'Unknown',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
