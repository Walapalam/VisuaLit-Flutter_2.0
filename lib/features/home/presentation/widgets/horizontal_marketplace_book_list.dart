import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/shared_widgets/book_card.dart';

class HorizontalMarketplaceBookList extends StatelessWidget {
  final List<dynamic> books;

  const HorizontalMarketplaceBookList({super.key, required this.books});

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return Container(
        height: 150,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'No books available',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 240, // Height for BookCard + Text
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          final coverUrl = book['formats']?['image/jpeg'] as String?;
          final title = book['title'] as String? ?? 'No Title';
          final author = book['authors']?.isNotEmpty == true
              ? book['authors'][0]['name'] as String? ?? 'Unknown'
              : 'Unknown';

          return BookCard(
            imageBytes: null, // Marketplace books use URLs, not bytes
            title: title,
            author: author,
            coverUrl: coverUrl, // Pass URL for network image
            onTap: () {
              // Navigate to marketplace detail or download
              context.push('/marketplace');
            },
          );
        },
      ),
    );
  }
}
