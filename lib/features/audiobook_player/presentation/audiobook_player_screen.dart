// lib/features/audiobook_player/presentation/audiobook_player_screen.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/audiobook_player/data/audiobook.dart';
import 'package:go_router/go_router.dart';
import 'audiobook_player_service.dart';
import 'widgets/info_sheet_content.dart';
import 'widgets/player_bottom_tabs.dart';
import 'widgets/player_controls.dart';
import 'widgets/progress_slider.dart';

// --- MAIN WIDGET: Rebuilds only when the book or lock state changes ---
class AudiobookPlayerScreen extends ConsumerWidget {
  final int audiobookId;

  const AudiobookPlayerScreen({super.key, required this.audiobookId});

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
    final book = ref.watch(audiobookPlayerServiceProvider.select((state) => state.audiobook));
    final isScreenLocked = ref.watch(audiobookPlayerServiceProvider.select((state) => state.isScreenLocked));

    final textTheme = Theme.of(context).textTheme;
    const Color accentGreen = Color(0xFF1DB954);
    const Color darkBackground = Color(0xFF121212);

    if (book == null || book.id != audiobookId) {
      return Scaffold(backgroundColor: darkBackground, body: const Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: isScreenLocked ? null : () => context.pop(),
          icon: const Icon(Icons.expand_more, color: Colors.white),
        ),
        title: const Text("Now Playing", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          if (!isScreenLocked)
            IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        top: false, // AppBar handles the top safe area
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              AbsorbPointer(
                absorbing: isScreenLocked,
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
                            ? Image.memory(
                          Uint8List.fromList(book.coverImageBytes!),
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                        )
                            : Container(color: Colors.grey.shade800, child: const Icon(Icons.music_note, size: 100, color: Colors.white54)),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(book.displayTitle, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(book.author ?? "Unknown Artist", style: textTheme.bodyLarge?.copyWith(color: Colors.grey[400]), textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    const ProgressSlider(),
                  ],
                ),
              ),
              // MOVED Spacer to push the controls and tabs down together
              const Spacer(),
              const PlayerControls(),
              // ADDED a fixed SizedBox to create a smaller, controlled gap
              const SizedBox(height: 20),
              AbsorbPointer(
                absorbing: isScreenLocked,
                child: PlayerBottomTabs(
                  accentColor: accentGreen,
                  initialIndex: 0,
                  onChaptersTap: () => _showInfoSheet(context, ref, initialTabIndex: 0),
                  onReadTap: () => _showInfoSheet(context, ref, initialTabIndex: 1),
                  onVisualizeTap: () => _showInfoSheet(context, ref, initialTabIndex: 2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}