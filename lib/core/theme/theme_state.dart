import 'package:flutter/material.dart';

/// Holds all theme-related preferences in one place.
/// This includes:
/// - ThemeMode (light/dark/system)
/// - FontFamily (string)
/// - FontSize (double)
class ThemeState {
  final ThemeMode themeMode;
  final String fontFamily;
  final double fontSize;

  // Font size presets
  static const double fontSmall = 14.0;
  static const double fontMedium = 16.0;
  static const double fontLarge = 18.0;

  const ThemeState({
    required this.themeMode,
    required this.fontFamily,
    required this.fontSize,
  });

  /// Creates a new ThemeState with modified values.
  ThemeState copyWith({
    ThemeMode? themeMode,
    String? fontFamily,
    double? fontSize,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
    );
  }

  /// Convert to a map for saving to local storage.
  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.index,
      'fontFamily': fontFamily,
      'fontSize': fontSize,
    };
  }

  /// Restore theme settings from local storage.
  factory ThemeState.fromMap(Map<String, dynamic> map) {
    return ThemeState(
      themeMode: ThemeMode.values[map['themeMode'] ?? 0],
      fontFamily: map['fontFamily'] ?? 'OpenSans',
      fontSize: (map['fontSize'] ?? fontMedium).toDouble(),
    );
  }

  static ThemeState initial() {
    return const ThemeState(
      themeMode: ThemeMode.light,
      fontFamily: 'OpenSans',
      fontSize: fontMedium,
    );
  }

  // Helper to get readable font size label
  String get fontSizeLabel {
    if (fontSize == fontSmall) return 'Small';
    if (fontSize == fontLarge) return 'Large';
    return 'Medium';
  }
}
