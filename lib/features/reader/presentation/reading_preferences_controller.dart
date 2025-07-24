import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/reader/data/book_data.dart';

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
  final double brightness;
  final PageTurnStyle pageTurnStyle;
  final bool matchDeviceTheme;
  final BackgroundDimming backgroundDimming;
  final double textIndent;

  const ReadingPreferences({
    this.fontSize = 18.0,
    this.lineSpacing = 1.6,
    this.themeMode = ThemeMode.dark,
    this.pageColor = const Color(0xFF121212),
    this.textColor = const Color(0xFFE0E0E0),
    this.isLineGuideEnabled = false,
    this.fontFamily = 'Georgia',
    this.brightness = 1.0,
    this.pageTurnStyle = PageTurnStyle.paged,
    this.matchDeviceTheme = false,
    this.backgroundDimming = BackgroundDimming.medium,
    this.textIndent = 1.5,
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
    double? textIndent,
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
      textIndent: textIndent ?? this.textIndent,
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

  void setFontSize(double size) {
    print("DEBUG: [PrefsController] Setting font size to: $size");
    state = state.copyWith(fontSize: size);
  }

  void setFontFamily(String family) {
    print("DEBUG: [PrefsController] Setting font family to: $family");
    state = state.copyWith(fontFamily: family);
  }

  void setLineSpacing(double spacing) {
    print("DEBUG: [PrefsController] Setting line spacing to: $spacing");
    state = state.copyWith(lineSpacing: spacing);
  }

  void toggleLineGuide(bool enabled) {
    print("DEBUG: [PrefsController] Setting line guide to: $enabled");
    state = state.copyWith(isLineGuideEnabled: enabled);
  }

  void setBrightness(double newBrightness) {
    print("DEBUG: [PrefsController] Setting brightness to: $newBrightness");
    state = state.copyWith(brightness: newBrightness.clamp(0.1, 1.0));
  }

  void setPageTurnStyle(PageTurnStyle style) {
    print("DEBUG: [PrefsController] Setting page turn style to: $style");
    state = state.copyWith(pageTurnStyle: style);
  }

  void togglePageTurnStyle() {
    print("DEBUG: [PrefsController] Toggling page turn style from ${state.pageTurnStyle}");
    state = state.copyWith(
      pageTurnStyle: state.pageTurnStyle == PageTurnStyle.paged ? PageTurnStyle.scroll : PageTurnStyle.paged,
    );
  }

  void setMatchDeviceTheme(bool match) {
    print("DEBUG: [PrefsController] Setting match device theme to: $match");
    state = state.copyWith(matchDeviceTheme: match, themeMode: match ? ThemeMode.system : state.themeMode);
  }

  void setThemeMode(ThemeMode mode) {
    print("DEBUG: [PrefsController] Setting theme mode to: $mode");
    state = state.copyWith(themeMode: mode, matchDeviceTheme: false);
  }

  void setTextIndent(double indent) {
    print("DEBUG: [PrefsController] Setting text indent to: $indent");
    state = state.copyWith(textIndent: indent);
  }

  void setBackgroundDimming(BackgroundDimming dimming) {
    print("DEBUG: [PrefsController] Setting background dimming to: $dimming");
    state = state.copyWith(backgroundDimming: dimming);
  }

  void applyTheme(ReadingPreferences theme) {
    print("DEBUG: [PrefsController] Applying new theme. Page color: ${theme.pageColor}");
    state = theme.copyWith(
      fontSize: state.fontSize,
      fontFamily: state.fontFamily,
      brightness: state.brightness,
      pageTurnStyle: state.pageTurnStyle,
      isLineGuideEnabled: state.isLineGuideEnabled,
      matchDeviceTheme: state.matchDeviceTheme,
      textIndent: state.textIndent,
      lineSpacing: state.lineSpacing,
    );
  }
}

final readingPreferencesProvider = StateNotifierProvider<ReadingPreferencesController, ReadingPreferences>(
      (ref) => ReadingPreferencesController(),
);