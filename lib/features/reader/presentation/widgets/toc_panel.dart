import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/data/toc_entry.dart';
import 'package:visualit/features/reader/presentation/reading_controller.dart';

/// Provider to fetch the book data just for the TOC panel.
/// This is efficient as it only fetches the book metadata, not the content.
final bookProvider = FutureProvider.family<Book?, int>((ref, bookId) async {
  debugPrint("[DEBUG] TOCPanel.bookProvider: Fetching book data for bookId: $bookId");

  try {
    final isarFuture = ref.watch(isarDBProvider.future);

    // Set up a callback for when this provider is disposed
    ref.onDispose(() {
      debugPrint("[DEBUG] TOCPanel.bookProvider: Disposing provider for bookId: $bookId");
    });

    final isar = await isarFuture;
    debugPrint("[DEBUG] TOCPanel.bookProvider: Isar database ready, fetching book");

    final book = await isar.books.get(bookId);

    if (book == null) {
      debugPrint("[WARN] TOCPanel.bookProvider: Book with ID $bookId not found");
    } else {
      debugPrint("[DEBUG] TOCPanel.bookProvider: Book found: ${book.title ?? 'Untitled'}, TOC entries: ${book.toc.length}");
    }

    return book;
  } catch (e, stack) {
    debugPrint("[ERROR] TOCPanel.bookProvider: Failed to fetch book data: $e");
    debugPrintStack(stackTrace: stack);
    rethrow;
  }
});

class TOCPanel extends ConsumerWidget {
  final int bookId;
  final Size viewSize;

  const TOCPanel({super.key, required this.bookId, required this.viewSize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint("[DEBUG] TOCPanel: Building TOC panel for book ID: $bookId");

    try {
      final bookAsync = ref.watch(bookProvider(bookId));

      // Get the reading controller for this book
      ReadingController? readingController;
      try {
        readingController = ref.read(readingControllerProvider(bookId).notifier);
        debugPrint("[DEBUG] TOCPanel: Successfully obtained reading controller");
      } catch (e) {
        debugPrint("[ERROR] TOCPanel: Failed to get reading controller: $e");
        // We'll handle the null controller case in the UI
      }

      return DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, scrollController) {
          debugPrint("[DEBUG] TOCPanel: Building draggable sheet content");

          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: bookAsync.when(
              loading: () {
                debugPrint("[DEBUG] TOCPanel: Book data is loading");
                return const Center(child: CircularProgressIndicator());
              },
              error: (err, st) {
                debugPrint("[ERROR] TOCPanel: Error loading book data: $err");
                debugPrintStack(stackTrace: st);
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text('Error loading table of contents: ${err.toString()}'),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ),
                );
              },
              data: (book) {
                if (book == null) {
                  debugPrint("[WARN] TOCPanel: Book not found");
                  return const Center(child: Text('Book not found.'));
                }

                if (book.toc.isEmpty) {
                  debugPrint("[WARN] TOCPanel: Book has no table of contents");
                  return const Center(child: Text('No Table of Contents found.'));
                }

                debugPrint("[DEBUG] TOCPanel: Rendering TOC with ${book.toc.length} entries");

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Contents',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: book.toc.length,
                        itemBuilder: (context, index) {
                          return _buildTocEntry(
                            context,
                            book.toc[index],
                            readingController,
                            0, // Initial depth
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      );
    } catch (e, stack) {
      debugPrint("[ERROR] TOCPanel: Unhandled error in build method: $e");
      debugPrintStack(stackTrace: stack);

      // Return a fallback UI in case of error
      return DraggableScrollableSheet(
        initialChildSize: 0.5,
        builder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text('An error occurred while loading the table of contents.'),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildTocEntry(
      BuildContext context, TOCEntry entry, ReadingController? controller, int depth) {
    try {
      final entryTitle = entry.title ?? 'Untitled Chapter';
      debugPrint("[DEBUG] TOCPanel._buildTocEntry: Building entry '$entryTitle' at depth $depth with ${entry.children.length} children");

      // If the entry has children, create an expandable tile.
      if (entry.children.isNotEmpty) {
        debugPrint("[DEBUG] TOCPanel._buildTocEntry: Creating expansion tile for '$entryTitle' with ${entry.children.length} children");
        return ExpansionTile(
          tilePadding: EdgeInsets.only(left: 16.0 * (depth + 1), right: 16.0),
          title: Text(entryTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
          children: entry.children
              .map((child) => _buildTocEntry(context, child, controller, depth + 1))
              .toList(),
        );
      }

      // Otherwise, create a simple, tappable list tile.
      debugPrint("[DEBUG] TOCPanel._buildTocEntry: Creating list tile for '$entryTitle'");
      return ListTile(
        contentPadding: EdgeInsets.only(left: 16.0 * (depth + 1), right: 16.0),
        title: Text(entryTitle),
        onTap: () {
          try {
            debugPrint("[DEBUG] TOCPanel: Tapped on TOC entry: '$entryTitle'");

            if (controller == null) {
              debugPrint("[ERROR] TOCPanel: Cannot navigate - reading controller is null");
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cannot navigate to this location')),
              );
              return;
            }

            if (entry.src == null) {
              debugPrint("[WARN] TOCPanel: TOC entry has no source path, cannot navigate");
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('This chapter has no location information')),
              );
              return;
            }

            debugPrint("[DEBUG] TOCPanel: Jumping to location: ${entry.src}");
            controller.jumpToLocation(entry);
            Navigator.of(context).pop(); // Close the bottom sheet on tap
          } catch (e, stack) {
            debugPrint("[ERROR] TOCPanel: Error navigating to TOC entry: $e");
            debugPrintStack(stackTrace: stack);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error navigating: ${e.toString()}')),
            );
          }
        },
      );
    } catch (e, stack) {
      debugPrint("[ERROR] TOCPanel._buildTocEntry: Error building TOC entry: $e");
      debugPrintStack(stackTrace: stack);

      // Return a fallback UI in case of error
      return ListTile(
        contentPadding: EdgeInsets.only(left: 16.0 * (depth + 1), right: 16.0),
        title: Text('Error: ${e.toString().substring(0, min(e.toString().length, 30))}...'),
        textColor: Colors.red,
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error with this entry: ${e.toString()}')),
        ),
      );
    }
  }
}
