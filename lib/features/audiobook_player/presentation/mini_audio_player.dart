// lib/features/audiobook_player/presentation/mini_audio_player.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/features/audiobook_player/presentation/audiobook_player_service.dart';

class MiniAudioPlayer extends ConsumerWidget {
  const MiniAudioPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(audiobookPlayerServiceProvider);
    final playerService = ref.read(audiobookPlayerServiceProvider.notifier);
    final book = playerState.audiobook;

    const Color accentGreen = Color(0xFF1DB954);
    const Color darkBackground = Color(0xFF181818);

    if (book == null) {
      return const SizedBox.shrink();
    }

    final currentChapterTitle = book.chapters.isNotEmpty
        ? book.chapters[playerState.currentChapterIndex].title ?? 'Chapter ${playerState.currentChapterIndex + 1}'
        : 'No Chapters';

    final double progress = (playerState.currentPosition.inMilliseconds > 0 && playerState.totalDuration.inMilliseconds > 0)
        ? playerState.currentPosition.inMilliseconds / playerState.totalDuration.inMilliseconds
        : 0.0;

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        // The main tap area (excluding buttons) opens the full player
        onTap: () {
          context.pushNamed('audiobookPlayer', pathParameters: {'audiobookId': book.id.toString()});
        },
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            color: darkBackground,
            border: Border(top: BorderSide(color: Colors.grey[850]!, width: 1.0)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    // Cover Art
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: book.coverImageBytes != null
                          ? Image.memory(Uint8List.fromList(book.coverImageBytes!), width: 48, height: 48, fit: BoxFit.cover)
                          : Container(width: 48, height: 48, color: Colors.grey[700], child: const Icon(Icons.music_note, color: Colors.white)),
                    ),
                    const SizedBox(width: 12),
                    // Title and Chapter (wrapped in Expanded to take up available space)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.displayTitle,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentChapterTitle,
                            style: TextStyle(color: Colors.grey[400], fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // --- UPDATED CONTROL BUTTONS ---
                    // Previous Chapter Button
                    IconButton(
                      onPressed: playerService.skipToPrevious,
                      icon: const Icon(Icons.skip_previous, color: Colors.white),
                      iconSize: 28, // Slightly smaller
                      padding: EdgeInsets.zero,
                      splashRadius: 20,
                    ),
                    // Play/Pause Button
                    IconButton(
                      onPressed: () => playerState.isPlaying ? playerService.pause() : playerService.play(),
                      icon: Icon(
                        playerState.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        color: accentGreen,
                      ),
                      iconSize: 36, // Slightly smaller to make room
                      padding: EdgeInsets.zero,
                      splashRadius: 24,
                    ),
                    // Next Chapter Button
                    IconButton(
                      onPressed: playerService.skipToNext,
                      icon: const Icon(Icons.skip_next, color: Colors.white),
                      iconSize: 28, // Slightly smaller
                      padding: EdgeInsets.zero,
                      splashRadius: 20,
                    ),
                    // --- END OF UPDATED BUTTONS ---
                  ],
                ),
              ),
              const Spacer(),
              // Progress Indicator
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0), // Ensure progress is always valid
                backgroundColor: Colors.grey[800],
                valueColor: const AlwaysStoppedAnimation<Color>(accentGreen),
                minHeight: 2.5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}