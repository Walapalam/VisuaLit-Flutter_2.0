import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'reading_screen_ui_controller.freezed.dart';

/// Represents the UI state of the reading screen
@freezed
class ReadingScreenUiState with _$ReadingScreenUiState {
  const factory ReadingScreenUiState({
    /// Whether the UI elements (app bar, bottom bar, etc.) are visible
    @Default(false) bool isUiVisible,

    /// Whether the screen is locked (prevents UI visibility toggling)
    @Default(false) bool isLocked,

  }) = _ReadingScreenUiState;
}

/// Controller for managing the UI state of the reading screen
class ReadingScreenUiController extends Notifier<ReadingScreenUiState> {
  @override
  ReadingScreenUiState build() {
    return const ReadingScreenUiState();
  }

  /// Toggles the visibility of UI elements if the screen is not locked
  void toggleUiVisibility() {
    if (state.isLocked) {
      debugPrint("[DEBUG] ReadingScreenUiController: UI toggle ignored - screen is locked");
      return;
    }

    debugPrint("[DEBUG] ReadingScreenUiController: Toggling UI visibility from ${state.isUiVisible} to ${!state.isUiVisible}");
    try {
      state = state.copyWith(isUiVisible: !state.isUiVisible);
      SystemChrome.setEnabledSystemUIMode(
        state.isUiVisible ? SystemUiMode.edgeToEdge : SystemUiMode.immersive,
      );
    } catch (e) {
      debugPrint("[ERROR] ReadingScreenUiController: Failed to toggle UI visibility: $e");
    }
  }

  /// Locks or unlocks the screen
  void lockScreen(bool lock) {
    debugPrint("[DEBUG] ReadingScreenUiController: ${lock ? 'Locking' : 'Unlocking'} screen");
    state = state.copyWith(isLocked: lock);
  }

}

/// Provider for the ReadingScreenUiController
final readingScreenUiProvider = NotifierProvider<ReadingScreenUiController, ReadingScreenUiState>(
  () => ReadingScreenUiController(),
);
