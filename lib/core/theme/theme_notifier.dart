import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme_state.dart';

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(ThemeState.initial());

  /// Toggle between light and dark mode
  void toggleTheme() {
    state = state.copyWith(
      themeMode: state.themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light,
    );
  }

  /// Set font family
  void setFontFamily(String fontFamily) {
    const validFonts = ['Dyslexie', 'OpenDyslexie', 'Jersey20'];
    if (validFonts.contains(fontFamily)) {
      state = state.copyWith(fontFamily: fontFamily);
    }
  }

  /// Set font size
  void setFontSize(double fontSize) {
    state = state.copyWith(fontSize: fontSize);
  }
}
