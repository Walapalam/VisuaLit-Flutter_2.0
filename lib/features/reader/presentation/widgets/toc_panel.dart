import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/data/toc_entry.dart';
import 'package:visualit/features/reader/presentation/reading_controller.dart';

// Provider to fetch the book data just for the TOC panel. This is efficient.
final bookProvider = FutureProvider.family<Book?, int>((ref, bookId) async {
  final isar = await ref.watch(isarDBProvider.future);
  print("  [TOCPanel] Fetching book data for bookId: $bookId");
  return isar.books.get(bookId);
});

class TOCPanel extends ConsumerWidget {
  final int bookId;
  final Size viewSize;

  const TOCPanel({super.key, required this.bookId, required this.viewSize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookAsync = ref.watch(bookProvider(bookId));

    // --- THIS IS THE FIX ---
    // Access the controller using the corrected provider signature.
    // It only needs the bookId now.
    final readingController = ref.read(readingControllerProvider(bookId).notifier);
    // --- END OF FIX ---

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: bookAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Center(child: Text('Error loading TOC: $err')),
            data: (book) {
              if (book == null || book.toc.isEmpty) {
                return const Center(child: Text('No Table of Contents found.'));
              }
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
  }

  Widget _buildTocEntry(
      BuildContext context, TOCEntry entry, ReadingController controller, int depth) {
    // If the entry has children, create an expandable tile.
    if (entry.children.isNotEmpty) {
      return ExpansionTile(
        tilePadding: EdgeInsets.only(left: 16.0 * (depth + 1), right: 16.0),
        title: Text(entry.title ?? 'Untitled Chapter',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        children: entry.children
            .map((child) => _buildTocEntry(context, child, controller, depth + 1))
            .toList(),
      );
    }

    // Otherwise, create a simple, tappable list tile.
    return ListTile(
      contentPadding: EdgeInsets.only(left: 16.0 * (depth + 1), right: 16.0),
      title: Text(entry.title ?? 'Untitled Chapter'),
      onTap: () {
        print("  [TOCPanel] Tapped on: '${entry.title}'. Jumping location.");
        // This call is now valid because we have the correct controller instance.
        controller.jumpToLocation(entry);
        Navigator.of(context).pop(); // Close the bottom sheet on tap
      },
    );
  }
}