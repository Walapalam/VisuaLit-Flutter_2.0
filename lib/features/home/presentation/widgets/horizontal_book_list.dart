import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/features/reader/data/book_data.dart' as db;
import 'package:visualit/shared_widgets/book_card.dart';
import 'package:visualit/core/services/toast_service.dart';

class HorizontalBookList extends StatelessWidget {
  final List<db.Book> books;

  const HorizontalBookList({super.key, required this.books});

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
          return BookCard(
            imageBytes: book.coverImageBytes != null
                ? Uint8List.fromList(book.coverImageBytes!)
                : null,
            title: book.title ?? 'No Title',
            author: book.author ?? 'Unknown',
            onTap: () {
              if (book.status == db.ProcessingStatus.ready) {
                context.pushNamed(
                  'epubReader',
                  pathParameters: {'bookId': book.id.toString()},
                );
              } else {
                ToastService.show(
                  context,
                  '${book.title ?? 'Book'} is still processing...',
                  type: ToastType.info,
                );
              }
            },
          );
        },
      ),
    );
  }
}
