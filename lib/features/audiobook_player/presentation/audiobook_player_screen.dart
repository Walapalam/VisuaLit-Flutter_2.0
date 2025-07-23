import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/audiobook_player/presentation/audiobook_player_controller.dart';

class AudiobookPlayerScreen extends ConsumerWidget {
  final int audiobookId;

  const AudiobookPlayerScreen({super.key, required this.audiobookId});

  // Helper to format duration to mm:ss
  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(audiobookPlayerControllerProvider(audiobookId));
    final playerController = ref.read(audiobookPlayerControllerProvider(audiobookId).notifier);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (playerState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (playerState.audiobook == null) {
      return const Scaffold(body: Center(child: Text("Audiobook not found.")));
    }

    final book = playerState.audiobook!;

    return Scaffold(
      backgroundColor: const Color(0xFF1F2E2E), // Dark cyan background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.expand_more),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Now Playing"),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Album Art
            Container(
              height: MediaQuery.of(context).size.width * 0.8,
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: book.coverImageBytes != null
                    ? Image.memory(
                  Uint8List.fromList(book.coverImageBytes!),
                  fit: BoxFit.cover,
                )
                    : Container(
                  color: Colors.grey.shade800,
                  child: const Icon(Icons.music_note, size: 100, color: Colors.white54),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Title and Artist
            Text(
              book.displayTitle,
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              book.author ?? "Unknown Artist",
              style: textTheme.bodyLarge?.copyWith(color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Action Buttons (Like, Save, etc)

            const SizedBox(height: 20),
            // Seek Bar
            Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2.0,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
                  ),
                  child: Slider(
                    value: playerState.currentPosition.inSeconds.toDouble(),
                    max: playerState.totalDuration.inSeconds.toDouble(),
                    min: 0,
                    activeColor: Colors.white,
                    inactiveColor: Colors.grey.shade700,
                    onChanged: (value) {
                      playerController.seek(Duration(seconds: value.round()));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(playerState.currentPosition), style: TextStyle(color: Colors.grey[400])),
                      Text(_formatDuration(playerState.totalDuration), style: TextStyle(color: Colors.grey[400])),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Player Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(icon: const Icon(Icons.shuffle, size: 28), color: Colors.white, onPressed: () {}),
                IconButton(icon: const Icon(Icons.skip_previous, size: 40), color: Colors.white, onPressed: playerController.skipToPrevious),
                IconButton(
                  iconSize: 70,
                  icon: Icon(playerState.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                  color: Colors.white,
                  onPressed: () => playerState.isPlaying ? playerController.pause() : playerController.play(),
                ),
                IconButton(icon: const Icon(Icons.skip_next, size: 40), color: Colors.white, onPressed: playerController.skipToNext),
                IconButton(icon: const Icon(Icons.repeat, size: 28), color: Colors.white, onPressed: () {}),
              ],
            ),
            const Spacer(),
            // Up Next, Lyrics, etc.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _bottomTabText("CHAPTER"),
                _bottomTabText("", isSelected: true),
                _bottomTabText("RELATED"),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _iconButtonWithText(IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        IconButton(icon: Icon(icon, color: Colors.grey[400]), onPressed: onPressed),
        if (label.isNotEmpty) Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
      ],
    );
  }

  Widget _bottomTabText(String text, {bool isSelected = false}) {
    return Text(
      text,
      style: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[600],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 14,
      ),
    );
  }
}