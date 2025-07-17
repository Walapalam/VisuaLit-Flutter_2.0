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
    
    /// The current orientation of the device
    @Default(DeviceOrientation.portraitUp) DeviceOrientation currentOrientation,
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

  /// Sets the orientation of the device
  void setOrientation(DeviceOrientation orientation) {
    state = state.copyWith(currentOrientation: orientation);
  }

  /// Toggles between portrait, landscape, and auto orientation modes
  void toggleOrientation() {
    debugPrint("[DEBUG] ReadingScreenUiController: Toggling orientation from ${state.currentOrientation}");
    try {
      switch (state.currentOrientation) {
        case DeviceOrientation.portraitUp:
          // Switch to landscape
          setOrientation(DeviceOrientation.landscapeLeft);
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
          debugPrint("[DEBUG] ReadingScreenUiController: Switched to landscape orientation");
          break;
        case DeviceOrientation.landscapeLeft:
        case DeviceOrientation.landscapeRight:
          // Switch to auto (all orientations)
          setOrientation(DeviceOrientation.portraitUp);
          SystemChrome.setPreferredOrientations([]);
          debugPrint("[DEBUG] ReadingScreenUiController: Switched to auto orientation");
          break;
        default:
          // Switch to portrait
          setOrientation(DeviceOrientation.portraitUp);
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
          ]);
          debugPrint("[DEBUG] ReadingScreenUiController: Switched to portrait orientation");
          break;
      }
    } catch (e) {
      debugPrint("[ERROR] ReadingScreenUiController: Failed to toggle orientation: $e");
    }
  }

  /// Returns the appropriate icon for the current orientation
  IconData getOrientationIcon() {
    switch (state.currentOrientation) {
      case DeviceOrientation.portraitUp:
        return Icons.screen_rotation;
      case DeviceOrientation.landscapeLeft:
      case DeviceOrientation.landscapeRight:
        return Icons.screen_lock_landscape;
      default:
        return Icons.screen_lock_portrait;
    }
  }

  /// Returns the appropriate label for the current orientation
  String getOrientationLabel() {
    switch (state.currentOrientation) {
      case DeviceOrientation.portraitUp:
        return 'Switch to Landscape';
      case DeviceOrientation.landscapeLeft:
      case DeviceOrientation.landscapeRight:
        return 'Auto Rotation';
      default:
        return 'Switch to Portrait';
    }
  }
}

/// Provider for the ReadingScreenUiController
final readingScreenUiProvider = NotifierProvider<ReadingScreenUiController, ReadingScreenUiState>(
  () => ReadingScreenUiController(),
);