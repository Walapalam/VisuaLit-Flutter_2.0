import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';

part 'user_settings.g.dart';

@collection
class UserSettings {
  Id id = Isar.autoIncrement;

  // Reading preferences
  double fontSize = 18.0;
  double lineSpacing = 1.6;
  @enumerated
  ThemeMode themeMode = ThemeMode.dark;
  int pageColor = const Color(0xFF121212).value;
  int textColor = const Color(0xFFE0E0E0).value;
  bool isLineGuideEnabled = false;
  String fontFamily = 'Georgia';
  double brightness = 1.0;
  @enumerated
  PageTurnStyle pageTurnStyle = PageTurnStyle.paged;
  bool matchDeviceTheme = false;
  @enumerated
  BackgroundDimming backgroundDimming = BackgroundDimming.medium;

  // Last update timestamp for sync conflict resolution
  DateTime updatedAt = DateTime.now();
  
  // ID of the corresponding document in Appwrite
  String? serverId;

  // Convert to ReadingPreferences object
  ReadingPreferences toReadingPreferences() {
    return ReadingPreferences(
      fontSize: fontSize,
      lineSpacing: lineSpacing,
      themeMode: themeMode,
      pageColor: Color(pageColor),
      textColor: Color(textColor),
      isLineGuideEnabled: isLineGuideEnabled,
      fontFamily: fontFamily,
      brightness: brightness,
      pageTurnStyle: pageTurnStyle,
      matchDeviceTheme: matchDeviceTheme,
      backgroundDimming: backgroundDimming,
    );
  }

  // Update from ReadingPreferences object
  void updateFromReadingPreferences(ReadingPreferences prefs) {
    fontSize = prefs.fontSize;
    lineSpacing = prefs.lineSpacing;
    themeMode = prefs.themeMode;
    pageColor = prefs.pageColor.value;
    textColor = prefs.textColor.value;
    isLineGuideEnabled = prefs.isLineGuideEnabled;
    fontFamily = prefs.fontFamily;
    brightness = prefs.brightness;
    pageTurnStyle = prefs.pageTurnStyle;
    matchDeviceTheme = prefs.matchDeviceTheme;
    backgroundDimming = prefs.backgroundDimming;
    updatedAt = DateTime.now();
  }
}