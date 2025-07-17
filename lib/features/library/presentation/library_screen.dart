import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/features/library/presentation/library_controller.dart';

import '../../reader/data/book_data.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint("[DEBUG] LibraryScreen: Building library screen");
    final libraryState = ref.watch(libraryControllerProvider);
    final libraryController = ref.read(libraryControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              debugPrint("[DEBUG] LibraryScreen: Add books button pressed");
              libraryController.pickAndProcessBooks();
            },
          )
        ],
      ),
      body: libraryState.when(
        loading: () {
          debugPrint("[DEBUG] LibraryScreen: Showing loading state");
          return const Center(child: CircularProgressIndicator());
        },
        error: (err, stack) {
          debugPrint("[ERROR] LibraryScreen: Error loading library: $err");
          debugPrintStack(stackTrace: stack);
          return Center(child: Text('Error: $err'));
        },
        data: (books) {
          debugPrint("[DEBUG] LibraryScreen: Loaded ${books.length} books");
          if (books.isEmpty) {
            debugPrint("[DEBUG] LibraryScreen: Library is empty, showing empty state");
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Your library is empty.'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      debugPrint("[DEBUG] LibraryScreen: Add books button pressed (empty state)");
                      libraryController.pickAndProcessBooks();
                    },
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
                  debugPrint("[DEBUG] LibraryScreen: Book tapped - id: ${book.id}, title: ${book.title ?? 'Untitled'}, status: ${book.status}");
                  if (book.status == ProcessingStatus.ready) {
                    debugPrint("[DEBUG] LibraryScreen: Navigating to book reader for book ID: ${book.id}");
                    context.goNamed('bookReader',
                        pathParameters: {'bookId': book.id.toString()});
                  } else {
                    debugPrint("[WARN] LibraryScreen: Cannot open book - still processing");
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
                          // ADDED: This handles errors if the image data is invalid.
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint("[ERROR] LibraryScreen: Failed to load cover image for book ${book.id}: $error");
                            debugPrintStack(stackTrace: stackTrace);
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
