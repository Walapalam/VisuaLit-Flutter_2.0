// lib/features/custom_reader/model/reading_preferences.dart
import 'package:flutter/material.dart';

enum PageTurnStyle { paged, scroll }

class ReadingPreferences {
  final double fontSize;
  final String fontFamily;
  final double brightness;
  final PageTurnStyle pageTurnStyle;
  final bool matchDeviceTheme;
  final ThemeMode themeMode;
  final Color textColor;
  final Color pageColor;
  final double sidePadding; // Renamed from leftPadding/rightPadding
  final double topPadding;
  final double bottomPadding;
  final double lineHeight; // Moved to end

  const ReadingPreferences({
    required this.fontSize,
    required this.fontFamily,
    required this.brightness,
    required this.pageTurnStyle,
    required this.matchDeviceTheme,
    required this.themeMode,
    required this.textColor,
    required this.pageColor,
    required this.sidePadding,
    required this.topPadding,
    required this.bottomPadding,
    required this.lineHeight,
  });

  ReadingPreferences copyWith({
    double? fontSize,
    String? fontFamily,
    double? brightness,
    PageTurnStyle? pageTurnStyle,
    bool? matchDeviceTheme,
    ThemeMode? themeMode,
    Color? textColor,
    Color? pageColor,
    double? sidePadding,
    double? topPadding,
    double? bottomPadding,
    double? lineHeight,
  }) {
    return ReadingPreferences(
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      brightness: brightness ?? this.brightness,
      pageTurnStyle: pageTurnStyle ?? this.pageTurnStyle,
      matchDeviceTheme: matchDeviceTheme ?? this.matchDeviceTheme,
      themeMode: themeMode ?? this.themeMode,
      textColor: textColor ?? this.textColor,
      pageColor: pageColor ?? this.pageColor,
      sidePadding: sidePadding ?? this.sidePadding,
      topPadding: topPadding ?? this.topPadding,
      bottomPadding: bottomPadding ?? this.bottomPadding,
      lineHeight: lineHeight ?? this.lineHeight,
    );
  }

  // Convenience getters for backward compatibility
  double get leftPadding => sidePadding;
  double get rightPadding => sidePadding;

  TextStyle get baseTextStyle => TextStyle(
    fontSize: fontSize,
    fontFamily: fontFamily,
    color: textColor,
    height: lineHeight,
  );

  TextStyle getStyleForHeading(int level) {
    switch (level) {
      case 1:
        return baseTextStyle.copyWith(fontSize: fontSize * 2.0, fontWeight: FontWeight.bold);
      case 2:
        return baseTextStyle.copyWith(fontSize: fontSize * 1.5, fontWeight: FontWeight.bold);
      case 3:
        return baseTextStyle.copyWith(fontSize: fontSize * 1.25, fontWeight: FontWeight.w600);
      case 4:
        return baseTextStyle.copyWith(fontSize: fontSize * 1.15, fontWeight: FontWeight.w600);
      default:
        return baseTextStyle.copyWith(fontWeight: FontWeight.w600);
    }
  }

  static const ReadingPreferences light = ReadingPreferences(
    fontSize: 18.0,
    fontFamily: 'Georgia',
    brightness: 1.0,
    pageTurnStyle: PageTurnStyle.paged,
    matchDeviceTheme: false,
    themeMode: ThemeMode.light,
    textColor: Colors.black,
    pageColor: Colors.white,
    sidePadding: 16.0,
    topPadding: 16.0,
    bottomPadding: 16.0,
    lineHeight: 1.6,
  );

  static const ReadingPreferences dark = ReadingPreferences(
    fontSize: 18.0,
    fontFamily: 'Georgia',
    brightness: 1.0,
    pageTurnStyle: PageTurnStyle.paged,
    matchDeviceTheme: false,
    themeMode: ThemeMode.dark,
    textColor: Colors.white,
    pageColor: Colors.black,
    sidePadding: 16.0,
    topPadding: 16.0,
    bottomPadding: 16.0,
    lineHeight: 1.6,
  );
}
