// lib/features/audiobook_player/presentation/audiobook_player_screen.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/audiobook_player/presentation/audiobook_player_controller.dart';
import 'package:go_router/go_router.dart';

class AudiobookPlayerScreen extends ConsumerWidget {
  final int audiobookId;

  const AudiobookPlayerScreen({super.key, required this.audiobookId});

  // Helper to format duration to mm:ss
  String _formatDuration(Duration d) {
    // Handle potential negative durations during seeks
    d = d.isNegative ? Duration.zero : d;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(audiobookPlayerControllerProvider(audiobookId));
    final playerController = ref.read(audiobookPlayerControllerProvider(audiobookId).notifier);
    final textTheme = Theme.of(context).textTheme;

    // Show a loading indicator while the controller is initializing
    if (playerState.isLoading && playerState.audiobook == null) {
      return const Scaffold(
          backgroundColor: Color(0xFF1F2E2E),
          body: Center(child: CircularProgressIndicator())
      );
    }

    // Show an error message if the book couldn't be found after loading
    if (playerState.audiobook == null) {
      return Scaffold(
          backgroundColor: const Color(0xFF1F2E2E),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: const Center(child: Text("Audiobook not found.", style: TextStyle(color: Colors.white)))
      );
    }

    final book = playerState.audiobook!;

    return Scaffold(
      backgroundColor: const Color(0xFF1F2E2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          // Disable the button action when locked, but the icon remains visible.
          onPressed: playerState.isScreenLocked ? null : () => context.goNamed('audio'),
          icon: const Icon(Icons.expand_more, color: Colors.white),
        ),
        title: const Text("Now Playing", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          // Only show the button if not locked
          if (!playerState.isScreenLocked)
            IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            // This AbsorbPointer wraps the UI elements that should be non-interactive when locked.
            AbsorbPointer(
              absorbing: playerState.isScreenLocked,
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
                        child: const Icon(Icons.music_note,
                            size: 100, color: Colors.white54),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Title and Artist
                  Text(
                    book.displayTitle,
                    style: textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.author ?? "Unknown Artist",
                    style: textTheme.bodyLarge?.copyWith(color: Colors.grey[400]),
                    textAlign: TextAlign.center,
                  ),
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
                          max: playerState.totalDuration.inSeconds.toDouble() > 0
                              ? playerState.totalDuration.inSeconds.toDouble()
                              : 1.0,
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
                            Text(_formatDuration(playerState.currentPosition),
                                style: TextStyle(color: Colors.grey[400])),
                            Text(_formatDuration(playerState.totalDuration),
                                style: TextStyle(color: Colors.grey[400])),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // This Row of controls is OUTSIDE the AbsorbPointer.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // SPEED BUTTON
                SizedBox(
                  width: 52, height: 52,
                  child: TextButton(
                    // Manually disable the button when locked
                    onPressed: playerState.isScreenLocked ? null : playerController.cyclePlaybackSpeed,
                    style: TextButton.styleFrom(foregroundColor: Colors.white, shape: const CircleBorder()),
                    child: Text("${playerState.playbackSpeed}x", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                // PREVIOUS BUTTON
                IconButton(
                  // Manually disable the button when locked
                    onPressed: playerState.isScreenLocked ? null : playerController.skipToPrevious,
                    icon: const Icon(Icons.skip_previous, size: 40),
                    color: Colors.white),
                // PLAY/PAUSE BUTTON
                IconButton(
                  iconSize: 70,
                  // Manually disable the button when locked
                  onPressed: playerState.isScreenLocked ? null : () => playerState.isPlaying
                      ? playerController.pause()
                      : playerController.play(),
                  icon: Icon(playerState.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled),
                  color: Colors.white,
                ),
                // NEXT BUTTON
                IconButton(
                  // Manually disable the button when locked
                    onPressed: playerState.isScreenLocked ? null : playerController.skipToNext,
                    icon: const Icon(Icons.skip_next, size: 40),
                    color: Colors.white),
                // LOCK BUTTON - This is always enabled
                IconButton(
                  icon: Icon(
                      playerState.isScreenLocked ? Icons.lock : Icons.lock_outline,
                      size: 28
                  ),
                  color: Colors.white,
                  onPressed: playerController.toggleScreenLock,
                ),
              ],
            ),
            const Spacer(),
            // Also disable the bottom tabs when locked
            AbsorbPointer(
              absorbing: playerState.isScreenLocked,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _bottomTabText("CHAPTERS"),
                  _bottomTabText("READ", isSelected: true),
                  _bottomTabText("VISUALIZE"),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper widget for the bottom tabs
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