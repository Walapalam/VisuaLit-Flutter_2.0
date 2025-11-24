// lib/features/audiobook_player/presentation/audiobooks_screen.dart
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/features/audiobook_player/data/audiobook.dart';
import 'package:visualit/features/audiobook_player/presentation/audiobooks_controller.dart';
import 'package:visualit/features/audiobook_player/presentation/audiobook_player_service.dart';

class AudiobooksScreen extends ConsumerWidget {
  const AudiobooksScreen({super.key});

  /// Shows a confirmation dialog before deleting an audiobook.
  void _showDeleteConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    Audiobook book,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Audiobook?'),
          content: Text(
            'Are you sure you want to delete "${book.displayTitle}"? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                ref
                    .read(audiobooksControllerProvider.notifier)
                    .deleteAudiobook(book.id);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audiobooksAsync = ref.watch(audiobooksControllerProvider);
    final theme = Theme.of(context);

    final ButtonStyle customButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Audiobooks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.audio_file_outlined),
            tooltip: 'Add Single MP3 File',
            onPressed: () => ref
                .read(audiobooksControllerProvider.notifier)
                .addAudiobookFromFile(),
          ),
          IconButton(
            icon: const Icon(Icons.create_new_folder_outlined),
            tooltip: 'Add Audiobook Folder',
            onPressed: () => ref
                .read(audiobooksControllerProvider.notifier)
                .addAudiobookFromFolder(),
          ),
        ],
      ),
      body: audiobooksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (audiobooks) {
          final multiFileAudiobooks = audiobooks
              .where((b) => !b.isSingleFile)
              .toList();
          final singleFileAudiobooks = audiobooks
              .where((b) => b.isSingleFile)
              .toList();

          if (audiobooks.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Your audiobook library is empty.',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      style: customButtonStyle,
                      icon: const Icon(Icons.create_new_folder_outlined),
                      label: const Text('Add Audiobook Folder'),
                      onPressed: () => ref
                          .read(audiobooksControllerProvider.notifier)
                          .addAudiobookFromFolder(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: customButtonStyle,
                      icon: const Icon(Icons.audio_file_outlined),
                      label: const Text('Add Single MP3 File'),
                      onPressed: () => ref
                          .read(audiobooksControllerProvider.notifier)
                          .addAudiobookFromFile(),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            children: [
              if (multiFileAudiobooks.isNotEmpty) ...[
                _buildSectionHeader('Multi-File Audiobooks'),
                _AudiobookCarousel(
                  books: multiFileAudiobooks,
                  fallbackIcon: Icon(
                    Icons.folder_open,
                    size: 80,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  onDelete: (book) =>
                      _showDeleteConfirmationDialog(context, ref, book),
                ),
              ],
              if (multiFileAudiobooks.isNotEmpty &&
                  singleFileAudiobooks.isNotEmpty)
                const Divider(
                  height: 48,
                  indent: 16,
                  endIndent: 16,
                  thickness: 0.5,
                ),

              if (singleFileAudiobooks.isNotEmpty) ...[
                _buildSectionHeader('Single-File Audiobooks'),
                _AudiobookCarousel(
                  books: singleFileAudiobooks,
                  fallbackIcon: Icon(
                    Icons.music_note,
                    size: 80,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  onDelete: (book) =>
                      _showDeleteConfirmationDialog(context, ref, book),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
      child: Builder(
        builder: (context) {
          return Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          );
        },
      ),
    );
  }
}

class _AudiobookCarousel extends ConsumerWidget {
  final List<Audiobook> books;
  final Icon fallbackIcon;
  final Function(Audiobook) onDelete;

  const _AudiobookCarousel({
    required this.books,
    required this.fallbackIcon,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double cardHeight = 220;
    const double cardWidth = 150;

    return SizedBox(
      height: cardHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return _AudiobookCard(
            book: book,
            width: cardWidth,
            fallbackIcon: fallbackIcon,
            onTap: () {
              ref
                  .read(audiobookPlayerServiceProvider.notifier)
                  .loadAndPlay(book);
              context.pushNamed(
                'audiobookPlayer',
                pathParameters: {'audiobookId': book.id.toString()},
              );
            },
            onDelete: () => onDelete(book),
          );
        },
      ),
    );
  }
}

// --- WIDGET: Card UI for a single audiobook (with long-press to delete) ---
class _AudiobookCard extends StatelessWidget {
  final Audiobook book;
  final double width;
  final Icon fallbackIcon;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _AudiobookCard({
    required this.book,
    required this.width,
    required this.fallbackIcon,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        // --- MODIFICATION IS HERE ---
        // InkWell handles both tap and long press events.
        child: InkWell(
          onTap: onTap, // A short tap plays the book.
          onLongPress:
              onDelete, // A long press now triggers the delete confirmation.
          borderRadius: BorderRadius.circular(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 150,
                width: double.infinity,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  elevation: 4,
                  // The Stack is now simpler as we've removed the button from the corner.
                  child: book.coverImageBytes != null
                      ? Image.memory(
                          Uint8List.fromList(book.coverImageBytes!),
                          fit: BoxFit.cover,
                        )
                      : Center(child: fallbackIcon),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  book.displayTitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  "${book.chapters.length} Chapter${book.chapters.length == 1 ? '' : 's'}",
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
