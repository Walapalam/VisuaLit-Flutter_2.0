import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/features/reader/presentation/reading_controller.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';
import 'package:visualit/features/reader/presentation/reading_screen_ui_controller.dart';

/// A widget that displays the app bar for the reading screen.
/// It watches the readingScreenUiProvider to control its visibility.
class ReadingAppBar extends ConsumerWidget {
  final ReadingState state;
  final ReadingPreferences prefs;

  const ReadingAppBar({
    super.key,
    required this.state,
    required this.prefs,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the UI state to get the visibility
    final uiState = ref.watch(readingScreenUiProvider);
    final isVisible = uiState.isUiVisible;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        child: AppBar(
          backgroundColor: isVisible ? prefs.pageColor.withAlpha(200) : Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            isVisible ? state.chapterProgress : state.book?.title ?? "Loading...",
            style: TextStyle(color: prefs.textColor, fontSize: 12),
          ),
          actions: [
            AnimatedOpacity(
              opacity: isVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: IconButton(
                icon: Icon(Icons.close, color: prefs.textColor),
                onPressed: () => context.go('/home'),
              ),
            )
          ],
        ),
      ),
    );
  }
}