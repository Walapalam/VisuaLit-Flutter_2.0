import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_provider.dart';


class AppTheme {
  // Core Colors
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color black = Color(0xFF000000);
  static const Color darkGrey = Color(0xFF121212);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF888888);

  // Responsive Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1200.0;

  // Grid System
  static int getGridColumns(double width) {
    if (width < 600) return 3;
    if (width < 900) return 4;
    if (width < 1200) return 6;
    return 8;
  }

  static ThemeData darkTheme({String fontFamily = 'OpenSans', double fontSize = 16}) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: black,
      scaffoldBackgroundColor: black,
      fontFamily: fontFamily,
      textTheme: TextTheme(
        // Display styles
        displayLarge: TextStyle(color: white, fontSize: fontSize + 16, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: white, fontSize: fontSize + 12, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: white, fontSize: fontSize + 8, fontWeight: FontWeight.bold),

        // Headline styles
        headlineLarge: TextStyle(color: white, fontSize: fontSize + 6, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: white, fontSize: fontSize + 4, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: white, fontSize: fontSize + 2, fontWeight: FontWeight.w600),

        // Title styles
        titleLarge: TextStyle(color: white, fontSize: fontSize + 2, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: white, fontSize: fontSize, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: white, fontSize: fontSize - 2, fontWeight: FontWeight.w500),

        // Body styles
        bodyLarge: TextStyle(color: white, fontSize: fontSize),
        bodyMedium: TextStyle(color: grey, fontSize: fontSize - 2),
        bodySmall: TextStyle(color: grey, fontSize: fontSize - 4),

        // Label styles
        labelLarge: TextStyle(color: white, fontSize: fontSize, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: grey, fontSize: fontSize - 2),
        labelSmall: TextStyle(color: grey, fontSize: fontSize - 4),
      ),
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
      appBarTheme: AppBarTheme(
        backgroundColor: black,
        elevation: 0,
        iconTheme: const IconThemeData(color: white),
        titleTextStyle: TextStyle(
          color: white,
          fontSize: fontSize + 4,
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: black,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: black,
        selectedItemColor: primaryGreen,
        unselectedItemColor: grey,
        selectedLabelStyle: TextStyle(fontSize: fontSize - 4),
        unselectedLabelStyle: TextStyle(fontSize: fontSize - 4),
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static ThemeData lightTheme({String fontFamily = 'OpenSans', double fontSize = 16}) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: white,
      scaffoldBackgroundColor: white,
      fontFamily: fontFamily,
      textTheme: TextTheme(
        displayLarge: TextStyle(color: black, fontSize: fontSize + 16, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: black, fontSize: fontSize + 12, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: black, fontSize: fontSize + 8, fontWeight: FontWeight.bold),

        headlineLarge: TextStyle(color: black, fontSize: fontSize + 6, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: black, fontSize: fontSize + 4, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: black, fontSize: fontSize + 2, fontWeight: FontWeight.w600),

        titleLarge: TextStyle(color: black, fontSize: fontSize + 2, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: black, fontSize: fontSize, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: black, fontSize: fontSize - 2, fontWeight: FontWeight.w500),

        bodyLarge: TextStyle(color: black, fontSize: fontSize),
        bodyMedium: TextStyle(color: grey, fontSize: fontSize - 2),
        bodySmall: TextStyle(color: grey, fontSize: fontSize - 4),

        labelLarge: TextStyle(color: black, fontSize: fontSize, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: grey, fontSize: fontSize - 2),
        labelSmall: TextStyle(color: grey, fontSize: fontSize - 4),
      ),
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
      appBarTheme: AppBarTheme(
        backgroundColor: white,
        elevation: 0,
        iconTheme: const IconThemeData(color: black),
        titleTextStyle: TextStyle(
          color: black,
          fontSize: fontSize + 4,
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: white,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: primaryGreen,
        unselectedItemColor: grey,
        selectedLabelStyle: TextStyle(fontSize: fontSize - 4),
        unselectedLabelStyle: TextStyle(fontSize: fontSize - 4),
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  /// Utility to apply current font from ThemeState
  static ThemeData themeFromState(WidgetRef ref, {bool isDark = false}) {
    final themeState = ref.watch(themeControllerProvider);
    return isDark
        ? darkTheme(fontFamily: themeState.fontFamily, fontSize: themeState.fontSize)
        : lightTheme(fontFamily: themeState.fontFamily, fontSize: themeState.fontSize);
  }
}

// Spacing Constants
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}

// Typography Scale
class AppTypography {
  static double getResponsiveSize(BuildContext context, double baseSize,
      {double minSize = 10.0, double maxSize = 24.0}) {
    final scale = MediaQuery.of(context).textScaleFactor;
    return (baseSize * scale).clamp(minSize, maxSize);
  }

  static const double h1 = 24.0;
  static const double h2 = 20.0;
  static const double h3 = 18.0;
  static const double body = 14.0;
  static const double caption = 12.0;
}
