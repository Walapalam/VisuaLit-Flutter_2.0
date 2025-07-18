import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:share_plus/share_plus.dart';
import 'package:visualit/features/reader/presentation/reading_controller.dart';
import 'package:visualit/features/reader/presentation/reading_screen_ui_controller.dart';
import 'package:visualit/features/reader/presentation/widgets/reading_settings_panel.dart';

/// A widget that displays the speed dial for the reading screen.
/// It watches the readingScreenUiProvider to control its visibility.
class ReaderSpeedDial extends ConsumerWidget {
  final int bookId;

  const ReaderSpeedDial({
    super.key,
    required this.bookId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the UI state to get the visibility
    final uiState = ref.watch(readingScreenUiProvider);
    final isVisible = uiState.isUiVisible;
    final isLocked = uiState.isLocked;
    final uiController = ref.read(readingScreenUiProvider.notifier);


    return Positioned(
      bottom: isVisible ? 90 : -60, // Position it above the bottom bar when visible
      right: 16,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        child: SpeedDial(
          icon: Icons.more_horiz,
          activeIcon: Icons.close,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Theme.of(context).colorScheme.onSecondary,
          overlayColor: Colors.black,
          overlayOpacity: 0.5,
          buttonSize: const Size(48, 48),
          childrenButtonSize: const Size(44, 44),
          curve: Curves.bounceIn,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.share_outlined), 
              label: 'Share', 
              onTap: () => _shareReading(ref),
            ),
            SpeedDialChild(
              child: Icon(isLocked ? Icons.lock_open_outlined : Icons.lock_outline),
              label: isLocked ? 'Unlock' : 'Lock Screen',
              onTap: () => uiController.lockScreen(!isLocked),
            ),
            SpeedDialChild(
              child: const Icon(Icons.tune_outlined), 
              label: 'Theme & Settings', 
              onTap: () => _showMainSettingsPanel(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showMainSettingsPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ReadingSettingsPanel(),
    );
  }

  Future<void> _shareReading(WidgetRef ref) async {
    debugPrint("[DEBUG] ReaderSpeedDial: Sharing reading progress");
    try {
      final state = ref.read(readingControllerProvider(bookId));
      final book = state.book;

      if (book == null) {
        debugPrint("[WARN] ReaderSpeedDial: Cannot share - book is null");
        return;
      }

      final title = book.title ?? 'Untitled Book';
      final author = book.author != null && book.author!.isNotEmpty 
          ? ' by ${book.author}' 
          : '';
      final currentPage = state.currentPage + 1;

      // EPUB View doesn't track total pages, so we'll just share the current page
      final shareText = 'I\'m reading "$title"$author - Page $currentPage in VisuaLit';
      debugPrint("[DEBUG] ReaderSpeedDial: Sharing text: $shareText");

      await Share.share(shareText);
      debugPrint("[DEBUG] ReaderSpeedDial: Share completed successfully");
    } catch (e) {
      debugPrint("[ERROR] ReaderSpeedDial: Failed to share reading: $e");
    }
  }

}
