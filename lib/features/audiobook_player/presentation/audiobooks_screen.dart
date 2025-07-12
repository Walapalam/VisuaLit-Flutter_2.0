import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/audiobook_player/presentation/audiobooks_controller.dart';

class AudiobooksScreen extends ConsumerWidget {
  const AudiobooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We need to handle the async Isar provider first
    final isarAsync = ref.watch(isarDBProvider);

    return Scaffold(
      body: isarAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Database Error: $err')),
        data: (isar) {
          // Only watch the controller once the database is ready
          final audiobooksState = ref.watch(audiobooksControllerProvider);
          return audiobooksState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (audiobooks) {
              if (audiobooks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Your audiobook library is empty.'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add Audiobook'),
                        onPressed: () {
                          ref
                              .read(audiobooksControllerProvider.notifier)
                              .addAudiobook();
                        },
                      )
                    ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: audiobooks.length,
                itemBuilder: (context, index) {
                  final audiobook = audiobooks[index];
                  return ListTile(
                    leading: const Icon(Icons.music_note, size: 40),
                    title: Text(audiobook.title ?? 'Unknown Title'),
                    subtitle: Text(audiobook.author ?? 'Unknown Author'),
                    onTap: () {
                      // Navigate to the player screen
                      context.go('/audiobook/${audiobook.id}');
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(audiobooksControllerProvider.notifier).addAudiobook();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}