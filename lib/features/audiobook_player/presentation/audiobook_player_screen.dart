// lib/features/audiobook_player/presentation/audiobook_player_screen.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/audiobook_player/data/audiobook.dart';
import 'package:go_router/go_router.dart';
import 'audiobook_player_service.dart';

class AudiobookPlayerScreen extends ConsumerWidget {
  final int audiobookId;

  const AudiobookPlayerScreen({super.key, required this.audiobookId});

  /// Helper to format a Duration object into a "minutes:seconds" string.
  String _formatDuration(Duration d) {
    d = d.isNegative ? Duration.zero : d;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  /// Shows the speed selection menu.
  void _showSpeedSelectionMenu(BuildContext context, WidgetRef ref) {
    final playerService = ref.read(audiobookPlayerServiceProvider.notifier);
    final currentSpeed = ref.read(audiobookPlayerServiceProvider).playbackSpeed;
    const List<double> availableSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    const Color accentGreen = Color(0xFF1DB954);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF191919), // Darker background for the sheet
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
                  title: Text(speed == 1.0 ? 'Normal' : '${speed}x', style: TextStyle(color: Colors.white, fontWeight: currentSpeed == speed ? FontWeight.bold : FontWeight.normal)),
                  trailing: currentSpeed == speed ? const Icon(Icons.check, color: accentGreen) : null,
                  onTap: () {
                    playerService.setSpeed(speed);
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

  /// Shows the info sheet with tabbed content, opening to the specified initial tab.
  void _showInfoSheet(BuildContext context, WidgetRef ref, {required int initialTabIndex}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
      builder: (context) {
        return InfoSheetContent(
          initialTabIndex: initialTabIndex,
          audiobookId: audiobookId,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(audiobookPlayerServiceProvider);
    final playerService = ref.read(audiobookPlayerServiceProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    const Color accentGreen = Color(0xFF1DB954);
    const Color darkBackground = Color(0xFF121212);

    if (playerState.audiobook == null || playerState.audiobook!.id != audiobookId) {
      return Scaffold(backgroundColor: darkBackground, body: const Center(child: CircularProgressIndicator()));
    }

    final book = playerState.audiobook!;

    return Scaffold(
      backgroundColor: darkBackground,
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
                        data: SliderTheme.of(context).copyWith(trackHeight: 3.0, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7.0), overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0)),
                        child: Slider(
                          value: playerState.currentPosition.inSeconds.toDouble().clamp(0.0, playerState.totalDuration.inSeconds.toDouble() > 0 ? playerState.totalDuration.inSeconds.toDouble() : 0.0),
                          max: playerState.totalDuration.inSeconds.toDouble() > 0 ? playerState.totalDuration.inSeconds.toDouble() : 1.0,
                          min: 0,
                          activeColor: accentGreen,
                          inactiveColor: Colors.grey.shade800,
                          thumbColor: Colors.white,
                          onChanged: (value) => playerService.seek(Duration(seconds: value.round())),
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
                IconButton(onPressed: playerState.isScreenLocked ? null : playerService.skipToPrevious, icon: const Icon(Icons.skip_previous, size: 40), color: Colors.white),
                IconButton(
                  iconSize: 70,
                  onPressed: playerState.isScreenLocked ? null : (playerState.isPlaying ? playerService.pause : playerService.play),
                  icon: Icon(playerState.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                  color: accentGreen,
                ),
                IconButton(onPressed: playerState.isScreenLocked ? null : playerService.skipToNext, icon: const Icon(Icons.skip_next, size: 40), color: Colors.white),
                IconButton(
                  icon: Icon(playerState.isScreenLocked ? Icons.lock : Icons.lock_outline, size: 28),
                  color: Colors.white,
                  onPressed: playerService.toggleScreenLock,
                ),
              ],
            ),
            const Spacer(),
            AbsorbPointer(
              absorbing: playerState.isScreenLocked,
              child: PlayerBottomTabs(
                accentColor: accentGreen,
                initialIndex: 0,
                onChaptersTap: () => _showInfoSheet(context, ref, initialTabIndex: 0),
                onReadTap: () => _showInfoSheet(context, ref, initialTabIndex: 1),
                onVisualizeTap: () => _showInfoSheet(context, ref, initialTabIndex: 2),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// --- SELF-CONTAINED WIDGET FOR THE ANIMATED BOTTOM TABS ---
class PlayerBottomTabs extends StatefulWidget {
  final VoidCallback onChaptersTap;
  final VoidCallback onReadTap;
  final VoidCallback onVisualizeTap;
  final int initialIndex;
  final Color accentColor;

  const PlayerBottomTabs({
    super.key,
    this.initialIndex = 0,
    required this.accentColor,
    required this.onChaptersTap,
    required this.onReadTap,
    required this.onVisualizeTap,
  });

  @override
  State<PlayerBottomTabs> createState() => _PlayerBottomTabsState();
}

class _PlayerBottomTabsState extends State<PlayerBottomTabs> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    // Note: We don't call setState here because the parent's action (opening the sheet)
    // is the primary goal. The selected state is visual flair for the main screen.
    if (index == 0) { widget.onChaptersTap(); }
    else if (index == 1) { widget.onReadTap(); }
    else if (index == 2) { widget.onVisualizeTap(); }
  }

  Widget _buildTab(int index, String text) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onTabTapped(index),
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text.toUpperCase(),
              style: TextStyle(
                color: isSelected ? widget.accentColor : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            // For the main screen, the underline is static and only for the first tab
            Container(
              height: 3,
              width: isSelected ? 30 : 0,
              decoration: BoxDecoration(
                color: widget.accentColor,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildTab(0, "CHAPTERS"),
        _buildTab(1, "READ"),
        _buildTab(2, "VISUALIZE"),
      ],
    );
  }
}


// --- SELF-CONTAINED WIDGET FOR THE INFO SHEET CONTENT ---
class InfoSheetContent extends ConsumerStatefulWidget {
  final int initialTabIndex;
  final int audiobookId;
  const InfoSheetContent({required this.initialTabIndex, required this.audiobookId, super.key});

  @override
  ConsumerState<InfoSheetContent> createState() => _InfoSheetContentState();
}

class _InfoSheetContentState extends ConsumerState<InfoSheetContent> {
  late int selectedTabIndex;

  @override
  void initState() {
    super.initState();
    selectedTabIndex = widget.initialTabIndex;
  }

  String _formatDuration(Duration d) {
    d = d.isNegative ? Duration.zero : d;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    const Color accentGreen = Color(0xFF1DB954);

    final List<Widget> tabContents = [
      _buildChapterListView(accentGreen),
      _buildPlaceholderContent('Read Content'),
      _buildPlaceholderContent('Visualize Content'),
    ];

    return FractionallySizedBox(
      heightFactor: 0.8,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(10))),
          ),
          // Here, the tabs are interactive and manage their own state
          PlayerBottomTabsInSheet(
            initialIndex: selectedTabIndex,
            accentColor: accentGreen,
            onTabSelected: (index) {
              setState(() {
                selectedTabIndex = index;
              });
            },
          ),
          const Divider(color: Colors.white24, height: 1),
          Expanded(
            child: tabContents[selectedTabIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildChapterListView(Color accentColor) {
    final playerState = ref.watch(audiobookPlayerServiceProvider);
    final playerService = ref.read(audiobookPlayerServiceProvider.notifier);
    final book = playerState.audiobook!;

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: book.chapters.length,
      itemBuilder: (context, index) {
        final Chapter chapter = book.chapters[index];
        final bool isCurrentlyPlaying = playerState.currentChapterIndex == index;
        final durationText = chapter.durationInSeconds != null ? _formatDuration(Duration(seconds: chapter.durationInSeconds!)) : '--:--';
        final subtitleText = "${book.author ?? 'Unknown Author'} • $durationText";

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          leading: SizedBox(
            width: 50, height: 50,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  book.coverImageBytes != null
                      ? Image.memory(Uint8List.fromList(book.coverImageBytes!), fit: BoxFit.cover, width: 50, height: 50)
                      : Container(color: Colors.grey.shade800, child: const Icon(Icons.music_note, size: 24, color: Colors.white54)),
                  if (isCurrentlyPlaying)
                    Container(width: 50, height: 50, color: Colors.black.withOpacity(0.6), child: Icon(Icons.bar_chart_rounded, color: accentColor)),
                ],
              ),
            ),
          ),
          title: Text(chapter.title ?? 'Chapter ${index + 1}', style: TextStyle(color: isCurrentlyPlaying ? accentColor : Colors.white, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(subtitleText, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          trailing: Icon(Icons.drag_handle, color: Colors.grey[700]),
          onTap: () {
            if (!isCurrentlyPlaying) {
              playerService.jumpToChapter(index);
            }
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Widget _buildPlaceholderContent(String title) {
    return Center(
      child: Text(
        '$title Coming Soon',
        style: TextStyle(color: Colors.grey[600], fontSize: 16),
      ),
    );
  }
}


// A dedicated, simpler tab widget for use *inside* the bottom sheet
class PlayerBottomTabsInSheet extends StatefulWidget {
  final int initialIndex;
  final Color accentColor;
  final ValueChanged<int> onTabSelected;

  const PlayerBottomTabsInSheet({
    super.key,
    required this.initialIndex,
    required this.accentColor,
    required this.onTabSelected,
  });

  @override
  State<PlayerBottomTabsInSheet> createState() => _PlayerBottomTabsInSheetState();
}

class _PlayerBottomTabsInSheetState extends State<PlayerBottomTabsInSheet> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  Widget _buildTab(int index, String text) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        widget.onTabSelected(index);
      },
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text.toUpperCase(),
              style: TextStyle(
                color: isSelected ? widget.accentColor : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: 3,
              width: isSelected ? 30 : 0,
              decoration: BoxDecoration(
                color: widget.accentColor,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildTab(0, "CHAPTERS"),
        _buildTab(1, "READ"),
        _buildTab(2, "VISUALIZE"),
      ],
    );
  }
}