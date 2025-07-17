import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/reader/data/book_data.dart';

// Enum for the new page turning style setting
enum PageTurnStyle { paged, scroll, slide, curl, fastFade, epubView }
enum BackgroundDimming { none, low, medium, high }
enum OrientationMode { auto, portrait, landscape }

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
  final OrientationMode orientationMode;
  final bool enableHyphenation;

  const ReadingPreferences({
    this.fontSize = 18.0,
    this.lineSpacing = 1.6,
    this.themeMode = ThemeMode.dark,
    this.pageColor = const Color(0xFF121212),
    this.textColor = const Color(0xFFE0E0E0),
    this.isLineGuideEnabled = false,
    this.fontFamily = 'Georgia',
    this.brightness = 1.0, // Full brightness by default
    this.pageTurnStyle = PageTurnStyle.paged, // Paged turning by default
    this.matchDeviceTheme = false,
    this.backgroundDimming = BackgroundDimming.medium,
    this.orientationMode = OrientationMode.auto,
    this.enableHyphenation = true, // Enable hyphenation by default
  });

  static const ReadingPreferences light = ReadingPreferences(
      pageColor: Color(0xFFF5F0E5),
      textColor: Color(0xFF1F1F1F),
      themeMode: ThemeMode.light,
      orientationMode: OrientationMode.auto,
      enableHyphenation: true
  );
  static const ReadingPreferences sepia = ReadingPreferences(
      pageColor: Color(0xFFFBF0D9),
      textColor: Color(0xFF5B4636),
      themeMode: ThemeMode.light,
      orientationMode: OrientationMode.auto,
      enableHyphenation: true
  );
  static const ReadingPreferences dark = ReadingPreferences(
      pageColor: Color(0xFF121212),
      textColor: Color(0xFFB0B0B0),
      themeMode: ThemeMode.dark,
      orientationMode: OrientationMode.auto,
      enableHyphenation: true
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
    OrientationMode? orientationMode,
    bool? enableHyphenation,
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
      orientationMode: orientationMode ?? this.orientationMode,
      enableHyphenation: enableHyphenation ?? this.enableHyphenation,
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
      case BlockType.h4: return baseStyle.copyWith(fontSize: baseStyle.fontSize! * 1.15, fontWeight: FontWeight.w600);
      case BlockType.h5: return baseStyle.copyWith(fontSize: baseStyle.fontSize! * 1.1, fontWeight: FontWeight.w600);
      case BlockType.h6: return baseStyle.copyWith(fontSize: baseStyle.fontSize!, fontWeight: FontWeight.w600);
      case BlockType.p:
      case BlockType.img:
      case BlockType.unsupported:
      default: return baseStyle;
    }
  }
}

class ReadingPreferencesController extends StateNotifier<ReadingPreferences> {
  ReadingPreferencesController() : super(ReadingPreferences.dark) {
    debugPrint("[DEBUG] ReadingPreferencesController: Initialized with dark theme");
  }

  void setFontSize(double size) {
    debugPrint("[DEBUG] ReadingPreferencesController: Setting font size to $size");
    state = state.copyWith(fontSize: size);
  }

  void setFontFamily(String family) {
    debugPrint("[DEBUG] ReadingPreferencesController: Setting font family to $family");
    state = state.copyWith(fontFamily: family);
  }

  void toggleLineGuide(bool enabled) {
    debugPrint("[DEBUG] ReadingPreferencesController: ${enabled ? 'Enabling' : 'Disabling'} line guide");
    state = state.copyWith(isLineGuideEnabled: enabled);
  }

  // --- NEW METHODS ---
  void setBrightness(double newBrightness) {
    final clampedBrightness = newBrightness.clamp(0.1, 1.0);
    debugPrint("[DEBUG] ReadingPreferencesController: Setting brightness to $clampedBrightness");
    state = state.copyWith(brightness: clampedBrightness);
  }

  void setPageTurnStyle(PageTurnStyle style) {
    debugPrint("[DEBUG] ReadingPreferencesController: Setting page turn style to $style");
    state = state.copyWith(pageTurnStyle: style);
  }

  void setMatchDeviceTheme(bool match) {
    debugPrint("[DEBUG] ReadingPreferencesController: ${match ? 'Enabling' : 'Disabling'} device theme matching");
    state = state.copyWith(matchDeviceTheme: match, themeMode: match ? ThemeMode.system : state.themeMode);
  }

  void setThemeMode(ThemeMode mode) {
    debugPrint("[DEBUG] ReadingPreferencesController: Setting theme mode to $mode");
    state = state.copyWith(themeMode: mode, matchDeviceTheme: false);
  }

  void toggleHyphenation(bool enabled) {
    debugPrint("[DEBUG] ReadingPreferencesController: ${enabled ? 'Enabling' : 'Disabling'} hyphenation");
    state = state.copyWith(enableHyphenation: enabled);
  }

  void applyTheme(ReadingPreferences theme) {
    debugPrint("[DEBUG] ReadingPreferencesController: Applying theme with page color: ${theme.pageColor}, text color: ${theme.textColor}");
    state = theme.copyWith(
        fontSize: state.fontSize,
        fontFamily: state.fontFamily,
        brightness: state.brightness,
        pageTurnStyle: state.pageTurnStyle,
        isLineGuideEnabled: state.isLineGuideEnabled,
        matchDeviceTheme: state.matchDeviceTheme,
        orientationMode: state.orientationMode,
        enableHyphenation: state.enableHyphenation
    );
    debugPrint("[DEBUG] ReadingPreferencesController: Theme applied successfully");
  }
}

final readingPreferencesProvider = StateNotifierProvider<ReadingPreferencesController, ReadingPreferences>(
      (ref) => ReadingPreferencesController(),
);
