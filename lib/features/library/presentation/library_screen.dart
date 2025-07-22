import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/features/library/presentation/library_controller.dart';

import '../../reader/data/book_data.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryState = ref.watch(libraryControllerProvider);
    final libraryController = ref.read(libraryControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => libraryController.pickAndProcessBooks(),
          )
        ],
      ),
      body: libraryState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (books) {
          if (books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Your library is empty.'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => libraryController.pickAndProcessBooks(),
                    child: const Text('Add Books'),
                  )
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2 / 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return GestureDetector(
                onTap: () {
                  if (book.status == ProcessingStatus.ready) {
                    context.goNamed('bookReader',
                        pathParameters: {'bookId': book.id.toString()});
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                        Text('${book.title ?? 'Book'} is still processing...')));
                  }
                },
                child: Card(
                  elevation: 4,
                  child: Column(
                    children: [
                      Expanded(
                        child: book.coverImageBytes != null
                            ? Image.memory(
                          Uint8List.fromList(book.coverImageBytes!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: const Center(
                                  child: Icon(Icons.book, size: 40)),
                            );
                          },
                        )
                            : Container(
                          color: Colors.grey[800],
                          child: const Center(
                              child: Icon(Icons.book, size: 40)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          book.title ?? 'Loading...',
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      if (book.status != ProcessingStatus.ready)
                        const LinearProgressIndicator(),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}