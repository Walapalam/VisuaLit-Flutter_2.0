import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/reader/presentation/reading_controller.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';
import 'package:visualit/features/reader/presentation/reading_screen_ui_controller.dart';

/// A widget that displays the bottom bar for the reading screen.
/// It watches the readingScreenUiProvider to control its visibility.
class ReadingBottomBar extends ConsumerWidget {
  final ReadingState state;
  final ReadingPreferences prefs;
  final int bookId;

  const ReadingBottomBar({
    super.key,
    required this.state,
    required this.prefs,
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
    if (prefs.pageTurnStyle == PageTurnStyle.scroll) return const SizedBox.shrink();

    return BottomAppBar(
      color: Theme.of(context).colorScheme.surface.withAlpha(242),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Text('Page ${state.currentPage + 1}', style: TextStyle(color: prefs.textColor, fontSize: 12)),
            Expanded(
              child: Slider(
                value: state.currentPage.toDouble().clamp(0, (state.totalPages > 0 ? state.totalPages - 1 : 0).toDouble()),
                min: 0,
                max: (state.totalPages > 0 ? state.totalPages - 1 : 0).toDouble(),
                onChanged: (value) => ref.read(readingControllerProvider(bookId).notifier).onPageChanged(value.round()),
                activeColor: prefs.textColor,
                inactiveColor: prefs.textColor.withAlpha(77),
              ),
            ),
            Text('${state.totalPages}', style: TextStyle(color: prefs.textColor, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}