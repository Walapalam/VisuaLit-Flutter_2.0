import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/features/reader/presentation/reading_controller.dart';
import 'package:visualit/features/reader/presentation/reading_screen_ui_controller.dart';

/// A widget that displays the app bar for the reading screen.
/// It watches the readingScreenUiProvider to control its visibility.
class ReadingAppBar extends ConsumerWidget {
  final ReadingState state;

  const ReadingAppBar({
    super.key,
    required this.state,
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
          backgroundColor: isVisible ? Colors.white.withAlpha(200) : Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            isVisible ? "Page ${state.currentPage + 1}" : state.book?.title ?? "Loading...",
            style: const TextStyle(color: Colors.black, fontSize: 12),
          ),
          actions: [
            AnimatedOpacity(
              opacity: isVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () => context.go('/home'),
              ),
            )
          ],
        ),
      ),
    );
  }
}