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

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: primaryGreen),
    ),
  );

  // Premium Light Theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: const Color(
      0xFFF8F9FA,
    ), // Soft off-white for premium feel

    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      secondary: primaryGreen,
      background: Color(0xFFF8F9FA),
      surface: white,
      surfaceVariant: Color(0xFFF0F2F5), // Slightly darker surface for contrast
      onPrimary: white,
      onSecondary: white,
      onBackground: Color(0xFF1A1A1A), // Soft black for text
      onSurface: Color(0xFF1A1A1A),
      error: Colors.redAccent,
      onError: white,
      outline: Color(0xFFE0E0E0), // Light grey for borders
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent, // Transparent for glass effect
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF1A1A1A)),
      titleTextStyle: TextStyle(
        color: Color(0xFF1A1A1A),
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Jersey20', // Consistent branding
      ),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: Color(0xFF1A1A1A),
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: Color(0xFF1A1A1A),
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(color: Color(0xFF1A1A1A)),
      bodyMedium: TextStyle(
        color: Color(0xFF4A4A4A),
      ), // Medium grey for secondary text
      titleMedium: TextStyle(
        color: Color(0xFF1A1A1A),
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        color: Color(0xFF1A1A1A),
        fontWeight: FontWeight.bold,
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryGreen,
      foregroundColor: white,
      elevation: 4,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: white,
      selectedItemColor: primaryGreen,
      unselectedItemColor: grey,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: primaryGreen),
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
