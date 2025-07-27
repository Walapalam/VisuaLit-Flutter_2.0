import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/features/audiobook_player/presentation/audiobook_player_service.dart';

// --- MAIN WIDGET: The static container ---
// Rebuilds ONLY when a book is loaded/unloaded.
class MiniAudioPlayer extends ConsumerWidget {
  const MiniAudioPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This watch ensures the MiniPlayer appears/disappears when a book is loaded.
    final book = ref.watch(audiobookPlayerServiceProvider.select((s) => s.audiobook));

    const Color darkBackground = Color(0xFF181818);

    // If no book is loaded, show nothing.
    if (book == null) {
      return const SizedBox.shrink();
    }

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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    children: [
                      // STABLE: Cover Art - will not cause blinking.
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: book.coverImageBytes != null
                            ? Image.memory(
                          Uint8List.fromList(book.coverImageBytes!),
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                        )
                            : Container(width: 48, height: 48, color: Colors.grey[700], child: const Icon(Icons.music_note, color: Colors.white)),
                      ),
                      const SizedBox(width: 12),

                      // DEDICATED WIDGET for Title/Chapter
                      const Expanded(child: _MiniPlayerTitleAndChapter()),

                      const SizedBox(width: 8),

                      // DEDICATED WIDGET for Play/Pause/Close controls
                      const _MiniPlayerControls(),
                    ],
                  ),
                ),
              ),
              // DEDICATED WIDGET for the progress bar
              const _MiniPlayerProgressBar(),
            ],
          ),
        ),
      ),
    );
  }
}

// --- DEDICATED WIDGET 1: Title and Chapter ---
// Rebuilds ONLY when the chapter index changes.
class _MiniPlayerTitleAndChapter extends ConsumerWidget {
  const _MiniPlayerTitleAndChapter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Select only the data this widget needs.
    final book = ref.watch(audiobookPlayerServiceProvider.select((s) => s.audiobook!));
    final chapterIndex = ref.watch(audiobookPlayerServiceProvider.select((s) => s.currentChapterIndex));

    final currentChapterTitle = book.chapters.isNotEmpty && chapterIndex < book.chapters.length ? book.chapters[chapterIndex].title ?? 'Chapter ${chapterIndex + 1}' : 'No Chapters';

    return Column(
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
    );
  }
}

// --- DEDICATED WIDGET 2: Player Controls (UPDATED) ---
// Rebuilds ONLY when the isPlaying state changes.
class _MiniPlayerControls extends ConsumerWidget {
  const _MiniPlayerControls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerService = ref.read(audiobookPlayerServiceProvider.notifier);
    final isPlaying = ref.watch(audiobookPlayerServiceProvider.select((s) => s.isPlaying));

    return Row(
      children: [
        IconButton(
          onPressed: playerService.skipToPrevious,
          icon: const Icon(Icons.skip_previous, color: Colors.white),
          iconSize: 28,
          padding: EdgeInsets.zero,
          splashRadius: 20,
        ),
        IconButton(
          onPressed: () => isPlaying ? playerService.pause() : playerService.play(),
          icon: Icon(
            isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
            color: const Color(0xFF1DB954),
          ),
          iconSize: 36,
          padding: EdgeInsets.zero,
          splashRadius: 24,
        ),
        IconButton(
          onPressed: playerService.skipToNext,
          icon: const Icon(Icons.skip_next, color: Colors.white),
          iconSize: 28,
          padding: EdgeInsets.zero,
          splashRadius: 20,
        ),
        // --- NEW: Close Button ---
        IconButton(
          // Calls the new method you'll add to the service
          onPressed: () => playerService.stopAndUnload(),
          icon: const Icon(Icons.close, color: Colors.white),
          iconSize: 28,
          padding: EdgeInsets.zero,
          splashRadius: 20,
        ),
      ],
    );
  }
}

// --- DEDICATED WIDGET 3: Progress Bar ---
// Rebuilds frequently as position changes, but it's cheap to do so.
class _MiniPlayerProgressBar extends ConsumerWidget {
  const _MiniPlayerProgressBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(audiobookPlayerServiceProvider.select((s) => s.currentPosition));
    final duration = ref.watch(audiobookPlayerServiceProvider.select((s) => s.totalDuration));

    final double progress = (position.inMilliseconds > 0 && duration.inMilliseconds > 0) ? position.inMilliseconds / duration.inMilliseconds : 0.0;

    return LinearProgressIndicator(
      value: progress.clamp(0.0, 1.0),
      backgroundColor: Colors.grey[800],
      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1DB954)),
      minHeight: 2.5,
    );
  }
}