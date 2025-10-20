// lib/features/custom_reader/presentation/reading_preferences_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/custom_reader/model/reading_preferences.dart';

const List<String> availableFonts = [
  'Georgia',
  'OpenDyslexic',
  'Dyslexie',
  'Jersey20'
];

class ReadingPreferencesController extends StateNotifier<ReadingPreferences> {
  ReadingPreferencesController() : super(ReadingPreferences.dark);

  void setFontSize(double size) => state = state.copyWith(fontSize: size);
  void setLineSpacing(double spacing) => state = state.copyWith(lineSpacing: spacing);
  void setFontFamily(String family) => state = state.copyWith(fontFamily: family);
  void setBrightness(double brightness) => state = state.copyWith(brightness: brightness.clamp(0.1, 1.0));
  void setPageTurnStyle(PageTurnStyle style) => state = state.copyWith(pageTurnStyle: style);
  void setMatchDeviceTheme(bool match) => state = state.copyWith(
      matchDeviceTheme: match,
      themeMode: match ? ThemeMode.system : state.themeMode
  );
  void setThemeMode(ThemeMode mode) => state = state.copyWith(
      themeMode: mode,
      matchDeviceTheme: false
  );

  void applyTheme(ReadingPreferences theme) {
    state = theme.copyWith(
        fontSize: state.fontSize,
        fontFamily: state.fontFamily,
        brightness: state.brightness,
        pageTurnStyle: state.pageTurnStyle,
        matchDeviceTheme: state.matchDeviceTheme
    );
  }
}

final readingPreferencesProvider = StateNotifierProvider<ReadingPreferencesController, ReadingPreferences>(
      (ref) => ReadingPreferencesController(),
);
