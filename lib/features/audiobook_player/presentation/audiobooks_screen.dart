import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Make sure GoRouter is imported
import 'package:visualit/features/audiobook_player/data/audiobook.dart';
import 'package:visualit/features/audiobook_player/presentation/audiobooks_controller.dart';

class AudiobooksScreen extends ConsumerWidget {
  const AudiobooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audiobooksAsync = ref.watch(audiobooksControllerProvider);

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Your audiobook library is empty.'),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.create_new_folder_outlined),
                    label: const Text('Add Audiobook Folder'),
                    onPressed: () => ref.read(audiobooksControllerProvider.notifier).addAudiobookFromFolder(),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.audio_file_outlined),
                    label: const Text('Add Single MP3 File'),
                    onPressed: () => ref.read(audiobooksControllerProvider.notifier).addAudiobookFromFile(),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              // --- Multi-File Section ---
              if (multiFileAudiobooks.isNotEmpty)
                _buildSectionHeader('Multi-File Audio'),
              ...multiFileAudiobooks.map((book) => ListTile(
                leading: const Icon(Icons.folder, size: 40, color: Colors.orange),
                title: Text(book.displayTitle),
                subtitle: Text("${book.chapters.length} Chapters"),
                onTap: () {
                  // --- FIX: NAVIGATE TO PLAYER ---
                  print("DEBUG: Navigating to player for audiobookId: ${book.id}");
                  context.goNamed('audiobookPlayer', pathParameters: {'audiobookId': book.id.toString()});
                },
              )),

              if (multiFileAudiobooks.isNotEmpty && singleFileAudiobooks.isNotEmpty)
                const Divider(height: 32),

              // --- Single-File Section ---
              if (singleFileAudiobooks.isNotEmpty)
                _buildSectionHeader('Single File Audio'),
              ...singleFileAudiobooks.map((book) => ListTile(
                leading: const Icon(Icons.music_note, size: 40, color: Colors.tealAccent),
                title: Text(book.displayTitle),
                subtitle: const Text("1 Chapter"),
                onTap: () {
                  // --- FIX: NAVIGATE TO PLAYER ---
                  print("DEBUG: Navigating to player for audiobookId: ${book.id}");
                  context.goNamed('audiobookPlayer', pathParameters: {'audiobookId': book.id.toString()});
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
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }
}