import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/reader/presentation/reading_controller.dart';
import 'package:visualit/features/reader/presentation/reading_screen_ui_controller.dart';

/// A widget that displays the bottom bar for the reading screen.
/// It watches the readingScreenUiProvider to control its visibility.
class ReadingBottomBar extends ConsumerWidget {
  final ReadingState state;
  final int bookId;

  const ReadingBottomBar({
    super.key,
    required this.state,
    required this.bookId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the UI state to get the visibility
    final uiState = ref.watch(readingScreenUiProvider);
    final isVisible = uiState.isUiVisible;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: isVisible ? 80 : 0,
        child: isVisible ? _buildBottomScrubber(context, ref) : null,
      ),
    );
  }

  Widget _buildBottomScrubber(BuildContext context, WidgetRef ref) {
    // EPUB View doesn't support page scrubbing in the same way as custom rendering
    // We'll show a simplified version with just the current page
    return BottomAppBar(
      color: Theme.of(context).colorScheme.surface.withAlpha(242),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: Text(
            'Page ${state.currentPage + 1}',
            style: const TextStyle(color: Colors.black, fontSize: 14),
          ),
        ),
      ),
    );
  }
}