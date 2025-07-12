import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/reader/data/book_data.dart';

enum BackgroundDimming { none, low, medium, high }

// Update available fonts list to include all fonts
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
  final BackgroundDimming backgroundDimming;
  final String fontFamily;

  const ReadingPreferences({
    this.fontSize = 18.0,
    this.lineSpacing = 1.6,
    this.themeMode = ThemeMode.light,
    this.pageColor = const Color(0xFFF5F0E5),
    this.textColor = const Color(0xFF1F1F1F),
    this.isLineGuideEnabled = false,
    this.backgroundDimming = BackgroundDimming.medium,
    this.fontFamily = 'Georgia',
  });

  static const ReadingPreferences light = ReadingPreferences();

  static const ReadingPreferences sepia = ReadingPreferences(
    pageColor: Color(0xFFFBF0D9),
    textColor: Color(0xFF5B4636),
  );

  static const ReadingPreferences dark = ReadingPreferences(
    themeMode: ThemeMode.dark,
    pageColor: Color(0xFF121212),
    textColor: Color(0xFFB0B0B0),
  );

  ReadingPreferences copyWith({
    double? fontSize,
    double? lineSpacing,
    ThemeMode? themeMode,
    Color? pageColor,
    Color? textColor,
    bool? isLineGuideEnabled,
    BackgroundDimming? backgroundDimming,
    String? fontFamily,
  }) {
    return ReadingPreferences(
      fontSize: fontSize ?? this.fontSize,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      themeMode: themeMode ?? this.themeMode,
      pageColor: pageColor ?? this.pageColor,
      textColor: textColor ?? this.textColor,
      isLineGuideEnabled: isLineGuideEnabled ?? this.isLineGuideEnabled,
      backgroundDimming: backgroundDimming ?? this.backgroundDimming,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }

  // This method returns the correct TextStyle for a given block of text.
  TextStyle getStyleForBlock(BlockType type) {
    final baseStyle = TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      color: textColor,
      height: lineSpacing,
    );

    switch (type) {
      case BlockType.h1:
        return baseStyle.copyWith(
            fontSize: baseStyle.fontSize! * 1.8, fontWeight: FontWeight.bold);
      case BlockType.h2:
        return baseStyle.copyWith(
            fontSize: baseStyle.fontSize! * 1.5, fontWeight: FontWeight.bold);
      case BlockType.h3:
        return baseStyle.copyWith(
            fontSize: baseStyle.fontSize! * 1.3, fontWeight: FontWeight.w700);
      case BlockType.h4:
        return baseStyle.copyWith(
            fontSize: baseStyle.fontSize! * 1.15, fontWeight: FontWeight.w600);
      case BlockType.h5:
        return baseStyle.copyWith(
            fontSize: baseStyle.fontSize! * 1.1, fontWeight: FontWeight.w600);
      case BlockType.h6:
        return baseStyle.copyWith(
            fontSize: baseStyle.fontSize!, fontWeight: FontWeight.w600);
      case BlockType.img:
        return baseStyle;
      case BlockType.p:
      case BlockType.unsupported:
      default:
        return baseStyle;
    }
  }
}

class ReadingPreferencesController extends StateNotifier<ReadingPreferences> {
  ReadingPreferencesController() : super(const ReadingPreferences());

  void increaseFontSize() {
    if (state.fontSize < 32) {
      state = state.copyWith(fontSize: state.fontSize + 1);
    }
  }

  void decreaseFontSize() {
    if (state.fontSize > 12) {
      state = state.copyWith(fontSize: state.fontSize - 1);
    }
  }

  void setLineSpacing(double spacing) {
    state = state.copyWith(lineSpacing: spacing);
  }

  void setTheme(ReadingPreferences theme) {
    state = theme.copyWith(
      fontSize: state.fontSize,
      lineSpacing: state.lineSpacing,
      fontFamily: state.fontFamily,
    );
  }

  void toggleLineGuide(bool isEnabled) {
    state = state.copyWith(isLineGuideEnabled: isEnabled);
  }

  void setBackgroundDimming(BackgroundDimming level) {
    state = state.copyWith(backgroundDimming: level);
  }

  void setFontFamily(String fontFamily) {
    if (availableFonts.contains(fontFamily)) {
      state = state.copyWith(fontFamily: fontFamily);
    }
  }
}

final readingPreferencesProvider =
StateNotifierProvider<ReadingPreferencesController, ReadingPreferences>(
        (ref) {
      return ReadingPreferencesController();
    });