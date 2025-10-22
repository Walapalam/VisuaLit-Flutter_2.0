import 'package:flutter/material.dart';

class AppTheme {
  // Core Colors
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color black = Color(0xFF000000);
  static const Color darkGrey = Color(0xFF121212);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF888888);

  // ✨ NEW: Responsive Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1200.0;

  // ✨ NEW: Grid System
  static int getGridColumns(double width) {
    if (width < 600) return 3;
    if (width < 900) return 4;
    if (width < 1200) return 6;
    return 8;
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
}

// ✨ Spacing Constants (separate class)
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}

// ✨ Typography Scale (separate class)
class AppTypography {
  static double getResponsiveSize(
      BuildContext context,
      double baseSize, {
        double minSize = 10.0,
        double maxSize = 24.0,
      }) {
    final scale = MediaQuery.of(context).textScaleFactor;
    return (baseSize * scale).clamp(minSize, maxSize);
  }

  static const double h1 = 24.0;
  static const double h2 = 20.0;
  static const double h3 = 18.0;
  static const double body = 14.0;
  static const double caption = 12.0;
}