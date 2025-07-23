import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/reader/data/book_data.dart'; // For BlockType enum

// Enum for the page turning style setting
enum PageTurnStyle { paged, scroll }

// Enum for background dimming levels, often used for features like a line guide or focus mode
enum BackgroundDimming { none, low, medium, high }

// A predefined list of available font families for user selection in the reading settings.
const List<String> availableFonts = [
  'Georgia',      // A classic, highly readable serif font.
  'Inter',        // A popular, clean sans-serif font.
  'Roboto',       // Google's signature sans-serif font.
  'Poppins',      // A modern, geometric sans-serif font.
  'OpenSans',     // A humanist sans-serif font, known for its legibility.
  'OpenDyslexic', // A font specifically designed to aid readers with dyslexia.
  'Dyslexie',     // Another font created to improve readability for those with dyslexia.
  'Jersey20'      // A custom font included in the project assets.
];

/// An immutable class that holds all user-configurable reading preferences.
/// Using `@immutable` is a good practice when working with state management solutions
/// like Riverpod to prevent accidental state mutation.
@immutable
class ReadingPreferences {
  final double fontSize;
  final double lineSpacing;
  final ThemeMode themeMode;
  final Color pageColor;
  final Color textColor;
  final bool isLineGuideEnabled;
  final String fontFamily;
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
    this.pageTurnStyle = PageTurnStyle.paged, // Paged turning by default
    this.matchDeviceTheme = false,
    this.backgroundDimming = BackgroundDimming.medium,
  });

  // --- Predefined Theme Presets ---

  /// A light theme preset with a soft, off-white background.
  static const ReadingPreferences light = ReadingPreferences(
      pageColor: Color(0xFFF5F0E5),
      textColor: Color(0xFF1F1F1F),
      themeMode: ThemeMode.light
  );

  /// A sepia theme preset for warmer, paper-like reading.
  static const ReadingPreferences sepia = ReadingPreferences(
      pageColor: Color(0xFFFBF0D9),
      textColor: Color(0xFF5B4636),
      themeMode: ThemeMode.light
  );

  /// A dark theme preset for comfortable reading in low-light environments.
  static const ReadingPreferences dark = ReadingPreferences(
      pageColor: Color(0xFF121212),
      textColor: Color(0xFFB0B0B0),
      themeMode: ThemeMode.dark
  );

  /// Creates a new `ReadingPreferences` instance by copying the existing state
  /// and applying any specified changes. This is fundamental to working with
  /// immutable state.
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

  /// Generates a `TextStyle` for a given `BlockType` (e.g., h1, p) based on
  /// the current preferences.
  TextStyle getStyleForBlock(BlockType type) {
    final baseStyle = TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      color: textColor,
      height: lineSpacing,
    );
    // Apply stylistic variations for different semantic block types.
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

  /// Overriding equality operator to ensure Riverpod can correctly compare
  /// two `ReadingPreferences` objects and avoid unnecessary rebuilds.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ReadingPreferences &&
              runtimeType == other.runtimeType &&
              fontSize == other.fontSize &&
              lineSpacing == other.lineSpacing &&
              themeMode == other.themeMode &&
              pageColor == other.pageColor &&
              textColor == other.textColor &&
              isLineGuideEnabled == other.isLineGuideEnabled &&
              fontFamily == other.fontFamily &&
              brightness == other.brightness &&
              pageTurnStyle == other.pageTurnStyle &&
              matchDeviceTheme == other.matchDeviceTheme &&
              backgroundDimming == other.backgroundDimming;

  /// Overriding hashCode to match the equality implementation.
  @override
  int get hashCode => Object.hash(
    fontSize,
    lineSpacing,
    themeMode,
    pageColor,
    textColor,
    isLineGuideEnabled,
    fontFamily,
    brightness,
    pageTurnStyle,
    matchDeviceTheme,
    backgroundDimming,
  );
}

/// The controller for managing the `ReadingPreferences` state.
/// It extends `StateNotifier` to provide a reactive state object that widgets can listen to.
class ReadingPreferencesController extends StateNotifier<ReadingPreferences> {
  // Initialize the state with the dark theme preset by default.
  ReadingPreferencesController() : super(ReadingPreferences.dark);

  // --- Methods to update individual preferences ---
  void setFontSize(double size) => state = state.copyWith(fontSize: size);
  void setFontFamily(String family) => state = state.copyWith(fontFamily: family);
  void toggleLineGuide(bool enabled) => state = state.copyWith(isLineGuideEnabled: enabled);
  void setBrightness(double newBrightness) => state = state.copyWith(brightness: newBrightness.clamp(0.1, 1.0));
  void setPageTurnStyle(PageTurnStyle style) => state = state.copyWith(pageTurnStyle: style);

  /// Updates the theme to match the device's setting (light/dark).
  void setMatchDeviceTheme(bool match) => state = state.copyWith(matchDeviceTheme: match, themeMode: match ? ThemeMode.system : state.themeMode);

  /// Manually sets the theme mode (light/dark), and disables `matchDeviceTheme`.
  void setThemeMode(ThemeMode mode) => state = state.copyWith(themeMode: mode, matchDeviceTheme: false);

  /// Applies a theme preset (light, sepia, dark) while preserving dynamic user settings
  /// like font size, font family, brightness, etc.
  void applyTheme(ReadingPreferences theme) {
    state = theme.copyWith(
        fontSize: state.fontSize,
        fontFamily: state.fontFamily,
        brightness: state.brightness,
        pageTurnStyle: state.pageTurnStyle,
        isLineGuideEnabled: state.isLineGuideEnabled,
        matchDeviceTheme: state.matchDeviceTheme,
        lineSpacing: state.lineSpacing
    );
  }
}

/// The Riverpod provider that exposes the `ReadingPreferencesController` and its state
/// to the rest of the application. Widgets can use this provider to read the current
/// preferences or to call methods on the controller to update them.
final readingPreferencesProvider = StateNotifierProvider<ReadingPreferencesController, ReadingPreferences>(
      (ref) => ReadingPreferencesController(),
);
