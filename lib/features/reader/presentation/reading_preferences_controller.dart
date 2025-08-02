import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/reader/data/book_data.dart';

// Enum for the new page turning style setting
enum PageTurnStyle { paged, scroll }
enum BackgroundDimming { none, low, medium, high }

const List<String> availableFonts = [
  'Georgia',
  'OpenDyslexic',
  'Dyslexie',
  'Jersey20'
];

@immutable
class ReadingPreferences {
  final double fontSize;
  final double lineSpacing;
  final ThemeMode themeMode;
  final Color pageColor;
  final Color textColor;
  final bool isLineGuideEnabled;
  final String fontFamily;

  // --- NEW PROPERTIES ---
  final double brightness;
  final PageTurnStyle pageTurnStyle;
  final bool matchDeviceTheme;
  final BackgroundDimming backgroundDimming;

  const ReadingPreferences({
    this.fontSize = 18.0,
    this.lineSpacing = 1.6,
    this.themeMode = ThemeMode.dark,
    this.pageColor = const Color(0xFF121212),
    this.textColor = const Color(0xFFE0E0E0),
    this.isLineGuideEnabled = false,
    this.fontFamily = 'Georgia',
    this.brightness = 1.0, // Full brightness by default
    this.pageTurnStyle = PageTurnStyle.scroll, // Paged turning by default
    this.matchDeviceTheme = false,
    this.backgroundDimming = BackgroundDimming.medium,
  });

  static const ReadingPreferences light = ReadingPreferences(
      pageColor: Color(0xFFF5F0E5),
      textColor: Color(0xFF1F1F1F),
      themeMode: ThemeMode.light
  );
  static const ReadingPreferences sepia = ReadingPreferences(
      pageColor: Color(0xFFFBF0D9),
      textColor: Color(0xFF5B4636),
      themeMode: ThemeMode.light
  );
  static const ReadingPreferences dark = ReadingPreferences(
      pageColor: Color(0xFF121212),
      textColor: Color(0xFFB0B0B0),
      themeMode: ThemeMode.dark
  );

  ReadingPreferences copyWith({
    double? fontSize,
    double? lineSpacing,
    ThemeMode? themeMode,
    Color? pageColor,
    Color? textColor,
    bool? isLineGuideEnabled,
    String? fontFamily,
    double? brightness,
    PageTurnStyle? pageTurnStyle,
    bool? matchDeviceTheme,
    BackgroundDimming? backgroundDimming,
  }) {
    return ReadingPreferences(
      fontSize: fontSize ?? this.fontSize,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      themeMode: themeMode ?? this.themeMode,
      pageColor: pageColor ?? this.pageColor,
      textColor: textColor ?? this.textColor,
      isLineGuideEnabled: isLineGuideEnabled ?? this.isLineGuideEnabled,
      fontFamily: fontFamily ?? this.fontFamily,
      brightness: brightness ?? this.brightness,
      pageTurnStyle: pageTurnStyle ?? this.pageTurnStyle,
      matchDeviceTheme: matchDeviceTheme ?? this.matchDeviceTheme,
      backgroundDimming: backgroundDimming ?? this.backgroundDimming,
    );
  }

  TextStyle getStyleForBlock(BlockType type) {
    final baseStyle = TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      color: textColor,
      height: lineSpacing,
    );
    switch (type) {
      case BlockType.h1: return baseStyle.copyWith(fontSize: baseStyle.fontSize! * 1.8, fontWeight: FontWeight.bold);
      case BlockType.h2: return baseStyle.copyWith(fontSize: baseStyle.fontSize! * 1.5, fontWeight: FontWeight.bold);
      case BlockType.h3: return baseStyle.copyWith(fontSize: baseStyle.fontSize! * 1.3, fontWeight: FontWeight.w700);
      default: return baseStyle;
    }
  }
}

class ReadingPreferencesController extends StateNotifier<ReadingPreferences> {
  ReadingPreferencesController() : super(ReadingPreferences.dark);

  void setFontSize(double size) => state = state.copyWith(fontSize: size);
  void setFontFamily(String family) => state = state.copyWith(fontFamily: family);
  void toggleLineGuide(bool enabled) => state = state.copyWith(isLineGuideEnabled: enabled);

  // --- NEW METHODS ---
  void setBrightness(double newBrightness) => state = state.copyWith(brightness: newBrightness.clamp(0.1, 1.0));
  void setPageTurnStyle(PageTurnStyle style) => state = state.copyWith(pageTurnStyle: style);
  void setMatchDeviceTheme(bool match) => state = state.copyWith(matchDeviceTheme: match, themeMode: match ? ThemeMode.system : state.themeMode);
  void setThemeMode(ThemeMode mode) => state = state.copyWith(themeMode: mode, matchDeviceTheme: false);

  void applyTheme(ReadingPreferences theme) {
    state = theme.copyWith(
        fontSize: state.fontSize,
        fontFamily: state.fontFamily,
        brightness: state.brightness,
        pageTurnStyle: state.pageTurnStyle,
        isLineGuideEnabled: state.isLineGuideEnabled,
        matchDeviceTheme: state.matchDeviceTheme
    );
  }
}

final readingPreferencesProvider = StateNotifierProvider<ReadingPreferencesController, ReadingPreferences>(
      (ref) => ReadingPreferencesController(),
);