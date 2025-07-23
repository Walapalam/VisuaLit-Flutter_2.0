import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/features/audiobook_player/data/audiobook.dart';
import 'package:visualit/features/audiobook_player/presentation/audiobooks_controller.dart';

class AudiobooksScreen extends ConsumerWidget {
  const AudiobooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audiobooksAsync = ref.watch(audiobooksControllerProvider);
    final theme = Theme.of(context);

    // --- STYLE FOR THE 'ADD' BUTTONS ---
    // Define the button style once to reuse it.
    final ButtonStyle customButtonStyle = ElevatedButton.styleFrom(
      // A dark grey background that fits the theme
      backgroundColor: Colors.grey[850],
      // A light color for the text and icon for high contrast
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Audiobooks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.audio_file_outlined),
            tooltip: 'Add Single MP3 File',
            onPressed: () => ref.read(audiobooksControllerProvider.notifier).addAudiobookFromFile(),
          ),
          IconButton(
            icon: const Icon(Icons.create_new_folder_outlined),
            tooltip: 'Add Audiobook Folder',
            onPressed: () => ref.read(audiobooksControllerProvider.notifier).addAudiobookFromFolder(),
          ),
        ],
      ),
      body: audiobooksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (audiobooks) {
          final multiFileAudiobooks = audiobooks.where((b) => !b.isSingleFile).toList();
          final singleFileAudiobooks = audiobooks.where((b) => b.isSingleFile).toList();

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
                      // *** STYLE CHANGE HERE ***
                      style: customButtonStyle,
                      icon: const Icon(Icons.create_new_folder_outlined),
                      label: const Text('Add Audiobook Folder'),
                      onPressed: () => ref.read(audiobooksControllerProvider.notifier).addAudiobookFromFolder(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      // *** STYLE CHANGE HERE ***
                      style: customButtonStyle,
                      icon: const Icon(Icons.audio_file_outlined),
                      label: const Text('Add Single MP3 File'),
                      onPressed: () => ref.read(audiobooksControllerProvider.notifier).addAudiobookFromFile(),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              // --- Multi-File Section ---
              if (multiFileAudiobooks.isNotEmpty)
                _buildSectionHeader('Multi-File Audiobooks'),
              ...multiFileAudiobooks.map((book) => ListTile(
                leading: const Icon(Icons.folder_open, size: 40, color: Colors.orangeAccent),
                title: Text(book.displayTitle),
                subtitle: Text("${book.chapters.length} Chapters"),
                onTap: () {
                  // *** NAVIGATION FIX: Use .pushNamed instead of .goNamed ***
                  // This ensures the player screen is placed ON TOP of this one,
                  // allowing context.pop() to work correctly.
                  print("DEBUG: Pushing player for audiobookId: ${book.id}");
                  context.pushNamed('audiobookPlayer', pathParameters: {'audiobookId': book.id.toString()});
                },
              )),

              if (multiFileAudiobooks.isNotEmpty && singleFileAudiobooks.isNotEmpty)
                const Divider(height: 32, indent: 16, endIndent: 16),

              // --- Single-File Section ---
              if (singleFileAudiobooks.isNotEmpty)
                _buildSectionHeader('Single-File Audiobooks'),
              ...singleFileAudiobooks.map((book) => ListTile(
                leading: const Icon(Icons.music_note, size: 40, color: Colors.tealAccent),
                title: Text(book.displayTitle),
                subtitle: const Text("1 Chapter"),
                onTap: () {
                  // *** NAVIGATION FIX: Use .pushNamed instead of .goNamed ***
                  print("DEBUG: Pushing player for audiobookId: ${book.id}");
                  context.pushNamed('audiobookPlayer', pathParameters: {'audiobookId': book.id.toString()});
                },
              )),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }
}