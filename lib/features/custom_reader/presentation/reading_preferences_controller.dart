// lib/features/custom_reader/presentation/reading_preferences_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screen_brightness/screen_brightness.dart'; // Add import
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
  void setLineHeight(double height) => state = state.copyWith(lineHeight: height); // Renamed
  void setFontFamily(String family) => state = state.copyWith(fontFamily: family);
  void setBrightness(double brightness) async {
    state = state.copyWith(brightness: brightness.clamp(0.1, 1.0));
    await ScreenBrightness().setScreenBrightness(brightness); // Set device brightness
  }
  void setPageTurnStyle(PageTurnStyle style) => state = state.copyWith(pageTurnStyle: style);
  void setMatchDeviceTheme(bool match) => state = state.copyWith(
      matchDeviceTheme: match,
      themeMode: match ? ThemeMode.system : state.themeMode
  );
  void setThemeMode(ThemeMode mode) => state = state.copyWith(
      themeMode: mode,
      matchDeviceTheme: false
  );
  // Update in reading_preferences_controller.dart
  void setSidePadding(double padding) => state = state.copyWith(sidePadding: padding);
// Keep these for backward compatibility if needed
  void setLeftPadding(double padding) => state = state.copyWith(sidePadding: padding);
  void setRightPadding(double padding) => state = state.copyWith(sidePadding: padding);
  void setTopPadding(double padding) => state = state.copyWith(topPadding: padding);
  void setBottomPadding(double padding) => state = state.copyWith(bottomPadding: padding);
  void setTextColor(Color color) => state = state.copyWith(textColor: color);
  void setPageColor(Color color) => state = state.copyWith(pageColor: color);

  void applyTheme(ReadingPreferences theme) {
    state = theme.copyWith(
      fontSize: state.fontSize,
      fontFamily: state.fontFamily,
      brightness: state.brightness,
      pageTurnStyle: state.pageTurnStyle,
      matchDeviceTheme: state.matchDeviceTheme,
      sidePadding: state.sidePadding,
      topPadding: state.topPadding,
      bottomPadding: state.bottomPadding,
      lineHeight: state.lineHeight,
    );
  }
}

final readingPreferencesProvider = StateNotifierProvider<ReadingPreferencesController, ReadingPreferences>(
      (ref) => ReadingPreferencesController(),
);
