import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/audiobook_player/data/audiobook.dart';
import 'package:visualit/features/audiobook_player/presentation/audiobook_player_controller.dart';
import 'package:go_router/go_router.dart';

class AudiobookPlayerScreen extends ConsumerWidget {
  final int audiobookId;

  const AudiobookPlayerScreen({super.key, required this.audiobookId});

  // Helper to format duration to mm:ss
  String _formatDuration(Duration d) {
    d = d.isNegative ? Duration.zero : d;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  // Helper method for the speed selection menu (unchanged)
  void _showSpeedSelectionMenu(BuildContext context, WidgetRef ref) {
    final playerController = ref.read(audiobookPlayerControllerProvider(audiobookId).notifier);
    final currentSpeed = ref.read(audiobookPlayerControllerProvider(audiobookId)).playbackSpeed;
    const List<double> availableSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C3E3E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
                child: Text('Playback Speed', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              ...availableSpeeds.map((speed) {
                return ListTile(
                  title: Text(
                    speed == 1.0 ? 'Normal' : '${speed}x',
                    style: TextStyle(color: Colors.white, fontWeight: currentSpeed == speed ? FontWeight.bold : FontWeight.normal),
                  ),
                  trailing: currentSpeed == speed ? const Icon(Icons.check, color: Colors.white) : null,
                  onTap: () {
                    playerController.setSpeed(speed);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  // --- REWRITTEN HELPER METHOD TO SHOW THE NEW CHAPTER LIST UI ---
  void _showChapterList(BuildContext context, WidgetRef ref) {
    final playerState = ref.read(audiobookPlayerControllerProvider(audiobookId));
    final playerController = ref.read(audiobookPlayerControllerProvider(audiobookId).notifier);
    final book = playerState.audiobook;

    if (book == null) return; // Guard against null book

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Use a very dark background color similar to the image
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.8, // Sheet takes up 80% of the screen height
          child: Column(
            children: [
              // Draggable handle for the bottom sheet for better UX
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              // The scrollable list of chapters
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero, // Remove default padding
                  itemCount: book.chapters.length,
                  itemBuilder: (context, index) {
                    final Chapter chapter = book.chapters[index];
                    final bool isCurrentlyPlaying = playerState.currentChapterIndex == index;

                    final durationText = chapter.durationInSeconds != null
                        ? _formatDuration(Duration(seconds: chapter.durationInSeconds!))
                        : '--:--';

                    // Combine author and duration for the subtitle
                    final subtitleText = "${book.author ?? 'Unknown Author'} • $durationText";

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                      leading: SizedBox(
                        width: 50,
                        height: 50,
                        // Use a ClipRRect for the squared cover art
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          // Stack allows overlaying the playing indicator on the image
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Background Cover Art
                              book.coverImageBytes != null
                                  ? Image.memory(
                                Uint8List.fromList(book.coverImageBytes!),
                                fit: BoxFit.cover,
                                width: 50,
                                height: 50,
                              )
                                  : Container(
                                color: Colors.grey.shade800,
                                child: const Icon(Icons.music_note, size: 24, color: Colors.white54),
                              ),
                              // "Now Playing" overlay
                              if (isCurrentlyPlaying)
                                Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.black.withOpacity(0.6),
                                  // Use an icon that represents playback
                                  child: const Icon(Icons.bar_chart_rounded, color: Colors.white),
                                ),
                            ],
                          ),
                        ),
                      ),
                      title: Text(
                        chapter.title ?? 'Chapter ${index + 1}',
                        style: TextStyle(
                          // Highlight the playing chapter's title
                          color: isCurrentlyPlaying ? Theme.of(context).colorScheme.primary : Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        subtitleText,
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                      // Drag handle icon on the right
                      trailing: Icon(
                        Icons.drag_handle,
                        color: Colors.grey[700],
                      ),
                      onTap: () {
                        // Only jump if it's not the currently playing chapter
                        if (!isCurrentlyPlaying) {
                          playerController.jumpToChapter(index);
                        }
                        // Always close the sheet on tap
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This build method remains unchanged from the last correct version.
    final playerState = ref.watch(audiobookPlayerControllerProvider(audiobookId));
    final playerController = ref.read(audiobookPlayerControllerProvider(audiobookId).notifier);
    final textTheme = Theme.of(context).textTheme;

    if (playerState.isLoading && playerState.audiobook == null) {
      return const Scaffold(backgroundColor: Color(0xFF1F2E2E), body: Center(child: CircularProgressIndicator()));
    }
    if (playerState.audiobook == null) {
      return Scaffold(
          backgroundColor: const Color(0xFF1F2E2E),
          appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
          body: const Center(child: Text("Audiobook not found.", style: TextStyle(color: Colors.white))));
    }

    final book = playerState.audiobook!;

    return Scaffold(
      backgroundColor: const Color(0xFF1F2E2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: playerState.isScreenLocked ? null : () => context.pop(),
          icon: const Icon(Icons.expand_more, color: Colors.white),
        ),
        title: const Text("Now Playing", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          if (!playerState.isScreenLocked)
            IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            AbsorbPointer(
              absorbing: playerState.isScreenLocked,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    height: MediaQuery.of(context).size.width * 0.8,
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: book.coverImageBytes != null
                          ? Image.memory(Uint8List.fromList(book.coverImageBytes!), fit: BoxFit.cover)
                          : Container(color: Colors.grey.shade800, child: const Icon(Icons.music_note, size: 100, color: Colors.white54)),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(book.displayTitle, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(book.author ?? "Unknown Artist", style: textTheme.bodyLarge?.copyWith(color: Colors.grey[400]), textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(trackHeight: 2.0, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0), overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0)),
                        child: Slider(
                          value: playerState.currentPosition.inSeconds.toDouble().clamp(0.0, playerState.totalDuration.inSeconds.toDouble()),
                          max: playerState.totalDuration.inSeconds.toDouble() > 0 ? playerState.totalDuration.inSeconds.toDouble() : 1.0,
                          min: 0,
                          activeColor: Colors.white,
                          inactiveColor: Colors.grey.shade700,
                          onChanged: (value) => playerController.seek(Duration(seconds: value.round())),
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
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 52, height: 52,
                  child: TextButton(
                    onPressed: playerState.isScreenLocked ? null : () => _showSpeedSelectionMenu(context, ref),
                    style: TextButton.styleFrom(foregroundColor: Colors.white, shape: const CircleBorder()),
                    child: Text("${playerState.playbackSpeed}x", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                IconButton(onPressed: playerState.isScreenLocked ? null : playerController.skipToPrevious, icon: const Icon(Icons.skip_previous, size: 40), color: Colors.white),
                IconButton(
                  iconSize: 70,
                  onPressed: playerState.isScreenLocked ? null : (playerState.isPlaying ? playerController.pause : playerController.play),
                  icon: Icon(playerState.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                  color: Colors.white,
                ),
                IconButton(onPressed: playerState.isScreenLocked ? null : playerController.skipToNext, icon: const Icon(Icons.skip_next, size: 40), color: Colors.white),
                IconButton(
                  icon: Icon(playerState.isScreenLocked ? Icons.lock : Icons.lock_outline, size: 28),
                  color: Colors.white,
                  onPressed: playerController.toggleScreenLock,
                ),
              ],
            ),
            const Spacer(),
            AbsorbPointer(
              absorbing: playerState.isScreenLocked,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomTab(text: "CHAPTERS", isSelected: true, onTap: () => _showChapterList(context, ref)),
                  _buildBottomTab(text: "READ", isSelected: false, onTap: () {}),
                  _buildBottomTab(text: "VISUALIZE", isSelected: false, onTap: () {}),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // The helper widget for the bottom tabs (unchanged)
  Widget _buildBottomTab({
    required String text,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text.toUpperCase(),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 2,
              width: 30,
              color: isSelected ? Colors.white : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}