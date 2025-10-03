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
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Library',
            onPressed: () => libraryController.rescanVisuaLitFolder(),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => libraryController.pickAndProcessBooks(),
          ),
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
              childAspectRatio: 2 / 3.5, // Make cards longer (was 2/3)
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return GestureDetector(
                onTap: () {
                  if (book.status == ProcessingStatus.ready || book.status == ProcessingStatus.partiallyReady) {
                    context.goNamed('bookReader',
                        pathParameters: {'bookId': book.id.toString()});
                    if (book.status == ProcessingStatus.partiallyReady) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('${book.title ?? 'Book'} is still being processed. Some chapters may not be available yet.'),
                        duration: const Duration(seconds: 3),
                      ));
                    }
                  } else if (book.status == ProcessingStatus.error) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Error Processing ${book.title ?? 'Book'}'),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: book.failedPermanently ? Colors.black : Colors.red,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      book.failedPermanently
                                          ? 'PERMANENTLY FAILED'
                                          : 'ERROR',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[700],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Retry: ${book.retryCount}/3',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text('Error: ${book.errorMessage ?? 'Unknown error'}'),
                              const SizedBox(height: 16),
                              const Text('Stack Trace:', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  book.errorStackTrace ?? 'No stack trace available',
                                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('CLOSE'),
                          ),
                          if (!book.failedPermanently)
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                libraryController.retryProcessingBook(book.id);
                              },
                              child: const Text('RETRY'),
                            ),
                        ],
                      ),
                    );
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
                      SizedBox(
                        height: 120, // Set a fixed height for the cover image area
                        width: double.infinity,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: book.coverImageBytes != null
                                  ? Image.memory(
                                      Uint8List.fromList(book.coverImageBytes!),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[800],
                                          child: const Center(child: Icon(Icons.book, size: 40)),
                                        );
                                      },
                                    )
                                  : Container(
                                      color: Colors.grey[800],
                                      child: const Center(child: Icon(Icons.book, size: 40)),
                                    ),
                            ),
                            if (book.status == ProcessingStatus.error)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: book.failedPermanently ? Colors.black : Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    book.failedPermanently ? Icons.block : Icons.error_outline,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                          ],
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
                      if (book.status == ProcessingStatus.processing)
                        const LinearProgressIndicator(),
                      if (book.status == ProcessingStatus.partiallyReady)
                        LinearProgressIndicator(
                          value: book.processingProgress,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
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
