// lib/features/home/presentation/widgets/book_shelf.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/features/reader/data/book_data.dart' as db;
import 'package:visualit/shared_widgets/book_card.dart';

class BookShelf extends StatelessWidget {
  final String title;
  final List<db.Book> books;
  final bool showViewAll;
  final String? viewAllRoute;

  const BookShelf({
    super.key,
    required this.title,
    required this.books,
    this.showViewAll = false,
    this.viewAllRoute,
  });

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              if (showViewAll)
                TextButton(
                  onPressed: () {
                    if (viewAllRoute != null) context.go(viewAllRoute!);
                  },
                  child: const Text('View All',
                      style: TextStyle(color: AppTheme.primaryGreen)
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: MediaQuery.of(context).size.width * 0.6,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return BookCard(
                imageBytes: book.coverImageBytes != null ?
                Uint8List.fromList(book.coverImageBytes!) : null,
                title: book.title ?? 'No Title',
                author: book.author ?? 'Unknown Author',
                onTap: () {
                  if (book.status == db.ProcessingStatus.ready) {
                    context.goNamed('epubReader', pathParameters: {'bookId': book.id.toString()});
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('${book.title ?? 'Book'} is still processing...'),
                    ));
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
