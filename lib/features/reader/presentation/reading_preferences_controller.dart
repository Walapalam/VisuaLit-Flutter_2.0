import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define the PageTurnStyle enum
enum PageTurnStyle {
  epubView,
}

// Define the list of available fonts
const List<String> availableFonts = [
  'Roboto',
  'Open Sans',
  'Lato',
  'Merriweather',
  'Literata',
];

// Define the ReadingPreferences class
class ReadingPreferences {
  final double brightness;
  final double fontSize;
  final String fontFamily;
  final PageTurnStyle pageTurnStyle;
  final Color pageColor;
  final Color textColor;
  final ThemeMode themeMode;
  final bool matchDeviceTheme;
  final bool enableHyphenation;
  final bool isLineGuideEnabled;

  const ReadingPreferences({
    this.brightness = 1.0,
    this.fontSize = 18.0,
    this.fontFamily = 'Roboto',
    this.pageTurnStyle = PageTurnStyle.epubView,
    this.pageColor = Colors.white,
    this.textColor = Colors.black87,
    this.themeMode = ThemeMode.light,
    this.matchDeviceTheme = true,
    this.enableHyphenation = false,
    this.isLineGuideEnabled = false,
  });

  // Predefined themes
  static const ReadingPreferences light = ReadingPreferences(
    pageColor: Colors.white,
    textColor: Colors.black87,
    themeMode: ThemeMode.light,
  );

  static const ReadingPreferences sepia = ReadingPreferences(
    pageColor: Color(0xFFF8F1E3),
    textColor: Color(0xFF5F4B32),
    themeMode: ThemeMode.light,
  );

  static const ReadingPreferences dark = ReadingPreferences(
    pageColor: Color(0xFF121212),
    textColor: Colors.white70,
    themeMode: ThemeMode.dark,
  );

  // Copy with method for creating a new instance with some properties changed
  ReadingPreferences copyWith({
    double? brightness,
    double? fontSize,
    String? fontFamily,
    PageTurnStyle? pageTurnStyle,
    Color? pageColor,
    Color? textColor,
    ThemeMode? themeMode,
    bool? matchDeviceTheme,
    bool? enableHyphenation,
    bool? isLineGuideEnabled,
  }) {
    return ReadingPreferences(
      brightness: brightness ?? this.brightness,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      pageTurnStyle: pageTurnStyle ?? this.pageTurnStyle,
      pageColor: pageColor ?? this.pageColor,
      textColor: textColor ?? this.textColor,
      themeMode: themeMode ?? this.themeMode,
      matchDeviceTheme: matchDeviceTheme ?? this.matchDeviceTheme,
      enableHyphenation: enableHyphenation ?? this.enableHyphenation,
      isLineGuideEnabled: isLineGuideEnabled ?? this.isLineGuideEnabled,
    );
  }
}

// Define the ReadingPreferencesController
class ReadingPreferencesController extends StateNotifier<ReadingPreferences> {
  ReadingPreferencesController() : super(const ReadingPreferences());

  void setBrightness(double value) {
    state = state.copyWith(brightness: value);
  }

  void setFontSize(double value) {
    state = state.copyWith(fontSize: value);
  }

  void setFontFamily(String fontFamily) {
    state = state.copyWith(fontFamily: fontFamily);
  }

  void setPageTurnStyle(PageTurnStyle style) {
    state = state.copyWith(pageTurnStyle: style);
  }

  void applyTheme(ReadingPreferences theme) {
    state = state.copyWith(
      pageColor: theme.pageColor,
      textColor: theme.textColor,
      themeMode: theme.themeMode,
    );
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  void setMatchDeviceTheme(bool value) {
    state = state.copyWith(matchDeviceTheme: value);
  }

  void toggleHyphenation(bool value) {
    state = state.copyWith(enableHyphenation: value);
  }

  void toggleLineGuide(bool value) {
    state = state.copyWith(isLineGuideEnabled: value);
  }
}

// Define the provider
final readingPreferencesProvider = StateNotifierProvider<ReadingPreferencesController, ReadingPreferences>((ref) {
  return ReadingPreferencesController();
});