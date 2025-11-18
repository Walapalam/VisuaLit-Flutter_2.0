// lib/features/audiobook_player/presentation/widgets/info_sheet_content.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/audiobook_player/data/audiobook.dart';
import 'package:visualit/features/audiobook_player/presentation/audiobook_player_service.dart';
import 'package:visualit/features/audiobook_player/presentation/lrs_view.dart';
import 'player_bottom_tabs_in_sheet.dart';

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

  @override
  Widget build(BuildContext context) {
    const Color accentGreen = Color(0xFF1DB954);
    final book = ref.watch(audiobookPlayerServiceProvider.select((s) => s.audiobook));
    final currentChapterIndex = ref.watch(audiobookPlayerServiceProvider.select((s) => s.currentChapterIndex));

    if (book == null) return const SizedBox.shrink();

    String? currentChapterJsonPath;
    if (currentChapterIndex < book.chapters.length) {
      currentChapterJsonPath = book.chapters[currentChapterIndex].lrsJsonPath;
    }

    final List<Widget> tabContents = [
      _buildChapterListView(book),
      currentChapterJsonPath != null
          ? LrsView(lrsJsonPath: currentChapterJsonPath)
          : _buildPlaceholderContent('No script available for this chapter.'),
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

  Widget _buildChapterListView(Audiobook book) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: book.chapters.length,
      itemBuilder: (context, index) {
        return _ChapterListTile(
          book: book,
          index: index,
        );
      },
    );
  }

  Widget _buildPlaceholderContent(String title) {
    return Center(
      child: Text(
        title,
        style: TextStyle(color: Colors.grey[600], fontSize: 16),
      ),
    );
  }
}

// --- DEDICATED AND OPTIMIZED WIDGET FOR A SINGLE CHAPTER TILE ---
class _ChapterListTile extends ConsumerWidget {
  final Audiobook book;
  final int index;

  const _ChapterListTile({
    required this.book,
    required this.index,
  });

  String _formatDuration(Duration d) {
    d = d.isNegative ? Duration.zero : d;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerService = ref.read(audiobookPlayerServiceProvider.notifier);

    final bool isCurrentlyPlaying = ref.watch(audiobookPlayerServiceProvider.select(
            (s) => s.currentChapterIndex == index
    ));

    final AudiobookChapter chapter = book.chapters[index];
    const Color accentColor = Color(0xFF1DB954);

    final durationText = chapter.durationInSeconds != null
        ? _formatDuration(Duration(seconds: chapter.durationInSeconds!))
        : '--:--';
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
                  ? Image.memory(Uint8List.fromList(book.coverImageBytes!), fit: BoxFit.cover, width: 50, height: 50, gaplessPlayback: true)
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
        // The Navigator.pop(context) call has been removed from here.
        // This keeps the sheet open after selecting a new chapter.
      },
    );
  }
}
