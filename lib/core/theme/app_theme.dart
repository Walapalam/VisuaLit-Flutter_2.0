import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppTheme {
  // Core Colors
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color black = Color(0xFF000000);
  static const Color darkGrey = Color(0xFF121212);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF888888);

  // Static initializer for debugging
  static void initialize() {
    debugPrint("[DEBUG] AppTheme: Initializing application themes");
    debugPrint("[DEBUG] AppTheme: Primary color: $primaryGreen");
    debugPrint("[DEBUG] AppTheme: Dark theme background: $black");
    debugPrint("[DEBUG] AppTheme: Light theme background: $white");
  }

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: black,

    colorScheme: const ColorScheme.dark(
      primary: black,
      secondary: primaryGreen,
      background: black,
      surface: darkGrey,
      onPrimary: white,
      onSecondary: black,
      onBackground: white,
      onSurface: white,
      error: Colors.redAccent,
      onError: white,
    ),

    scaffoldBackgroundColor: black,

    appBarTheme: const AppBarTheme(
      backgroundColor: black,
      elevation: 0,
      iconTheme: IconThemeData(color: white),
      titleTextStyle: TextStyle(
        color: white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: white),
      bodyMedium: TextStyle(color: grey),
      headlineMedium: TextStyle(fontWeight: FontWeight.bold, color: white),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryGreen,
      foregroundColor: black,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: black,
      selectedItemColor: primaryGreen,
      unselectedItemColor: grey,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
    ),
  );

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: white,

    colorScheme: const ColorScheme.light(
      primary: white,
      secondary: primaryGreen,
      background: white,
      surface: white,
      onPrimary: black,
      onSecondary: white,
      onBackground: black,
      onSurface: black,
      error: Colors.redAccent,
      onError: white,
    ),

    scaffoldBackgroundColor: white,

    appBarTheme: const AppBarTheme(
      backgroundColor: white,
      elevation: 0,
      iconTheme: IconThemeData(color: black),
      titleTextStyle: TextStyle(
        color: black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: black),
      bodyMedium: TextStyle(color: grey),
      headlineMedium: TextStyle(fontWeight: FontWeight.bold, color: black),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryGreen,
      foregroundColor: white,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: white,
      selectedItemColor: primaryGreen,
      unselectedItemColor: grey,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
    ),
  );
  // Debug helper methods
  static void logThemeInfo(ThemeData theme, String themeName) {
    debugPrint("[DEBUG] AppTheme: Theme info for $themeName");
    debugPrint("[DEBUG] AppTheme: Brightness: ${theme.brightness}");
    debugPrint("[DEBUG] AppTheme: Primary color: ${theme.colorScheme.primary}");
    debugPrint("[DEBUG] AppTheme: Background color: ${theme.colorScheme.background}");
    debugPrint("[DEBUG] AppTheme: Surface color: ${theme.colorScheme.surface}");
  }

  static void logCurrentTheme(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    debugPrint("[DEBUG] AppTheme: Current theme is ${isDark ? 'dark' : 'light'}");
    logThemeInfo(theme, isDark ? "Dark Theme" : "Light Theme");
  }
}
