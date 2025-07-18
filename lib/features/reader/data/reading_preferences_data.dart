import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';

part 'reading_preferences_data.g.dart';

@collection
class ReadingPreferencesData {
  Id id = Isar.autoIncrement;

  // User identifier (can be null for guest users)
  String? userId;

  // Reading preferences
  double brightness = 1.0;
  double fontSize = 18.0;
  String fontFamily = 'Roboto';
  
  @enumerated
  PageTurnStyle pageTurnStyle = PageTurnStyle.epubView;
  
  // Colors stored as integers
  int pageColorValue = Colors.white.value;
  int textColorValue = Colors.black87.value;
  
  @enumerated
  int themeModeValue = ThemeMode.light.index;
  
  bool matchDeviceTheme = true;
  bool enableHyphenation = false;
  bool isLineGuideEnabled = false;
  
  // Last updated timestamp
  DateTime lastUpdated = DateTime.now();
  
  // Convert to domain model
  ReadingPreferences toReadingPreferences() {
    return ReadingPreferences(
      brightness: brightness,
      fontSize: fontSize,
      fontFamily: fontFamily,
      pageTurnStyle: pageTurnStyle,
      pageColor: Color(pageColorValue),
      textColor: Color(textColorValue),
      themeMode: ThemeMode.values[themeModeValue],
      matchDeviceTheme: matchDeviceTheme,
      enableHyphenation: enableHyphenation,
      isLineGuideEnabled: isLineGuideEnabled,
    );
  }
  
  // Create from domain model
  static ReadingPreferencesData fromReadingPreferences(
    ReadingPreferences preferences, 
    {String? userId}
  ) {
    final data = ReadingPreferencesData()
      ..userId = userId
      ..brightness = preferences.brightness
      ..fontSize = preferences.fontSize
      ..fontFamily = preferences.fontFamily
      ..pageTurnStyle = preferences.pageTurnStyle
      ..pageColorValue = preferences.pageColor.value
      ..textColorValue = preferences.textColor.value
      ..themeModeValue = preferences.themeMode.index
      ..matchDeviceTheme = preferences.matchDeviceTheme
      ..enableHyphenation = preferences.enableHyphenation
      ..isLineGuideEnabled = preferences.isLineGuideEnabled
      ..lastUpdated = DateTime.now();
    
    return data;
  }
}