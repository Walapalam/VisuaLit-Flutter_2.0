// lib/features/custom_reader/model/reading_preferences.dart
import 'package:flutter/material.dart';

enum PageTurnStyle { paged, scroll }

class ReadingPreferences {
  final double fontSize;
  final double lineSpacing;
  final String fontFamily;
  final Color pageColor;
  final Color textColor;
  final double brightness;
  final PageTurnStyle pageTurnStyle;
  final bool matchDeviceTheme;
  final ThemeMode themeMode;

  const ReadingPreferences({
    this.fontSize = 18.0,
    this.lineSpacing = 1.6,
    this.fontFamily = 'Georgia',
    this.pageColor = const Color(0xFF121212),
    this.textColor = const Color(0xFFE0E0E0),
    this.brightness = 1.0,
    this.pageTurnStyle = PageTurnStyle.paged,
    this.matchDeviceTheme = false,
    this.themeMode = ThemeMode.dark,
  });

  // Predefined themes
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
    String? fontFamily,
    Color? pageColor,
    Color? textColor,
    double? brightness,
    PageTurnStyle? pageTurnStyle,
    bool? matchDeviceTheme,
    ThemeMode? themeMode,
  }) {
    return ReadingPreferences(
      fontSize: fontSize ?? this.fontSize,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      fontFamily: fontFamily ?? this.fontFamily,
      pageColor: pageColor ?? this.pageColor,
      textColor: textColor ?? this.textColor,
      brightness: brightness ?? this.brightness,
      pageTurnStyle: pageTurnStyle ?? this.pageTurnStyle,
      matchDeviceTheme: matchDeviceTheme ?? this.matchDeviceTheme,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  TextStyle get baseTextStyle => TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSize,
    color: textColor,
    height: lineSpacing,
  );

  TextStyle getStyleForHeading(int level) {
    switch (level) {
      case 1:
        return baseTextStyle.copyWith(fontSize: fontSize * 1.8, fontWeight: FontWeight.bold);
      case 2:
        return baseTextStyle.copyWith(fontSize: fontSize * 1.5, fontWeight: FontWeight.bold);
      case 3:
        return baseTextStyle.copyWith(fontSize: fontSize * 1.3, fontWeight: FontWeight.w700);
      case 4:
        return baseTextStyle.copyWith(fontSize: fontSize * 1.15, fontWeight: FontWeight.w600);
      default:
        return baseTextStyle.copyWith(fontWeight: FontWeight.w600);
    }
  }
}
