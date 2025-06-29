import 'package:flutter/material.dart';

// This file defines the core theme for the VisuaLit app.
// It centralizes all our design choices, from colors to fonts,
// ensuring a consistent look and feel across the entire application.

class AppTheme {
  // --- Core Colors ---
  // We define our brand colors here for easy access.
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color black = Color(0xFF000000);
  static const Color darkGrey = Color(0xFF121212); // A softer black for backgrounds
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF888888);

  // --- Main Theme Data ---
  // This is the main dark theme configuration.
  static final ThemeData darkTheme = ThemeData(
    // Use Material 3 design principles
    useMaterial3: true,

    // Set the overall brightness to dark
    brightness: Brightness.dark,

    // Define the primary color swatch
    primaryColor: primaryGreen,

    // --- Color Scheme ---
    // Defines the specific colors for different parts of the UI
    colorScheme: const ColorScheme.dark(
      primary: primaryGreen,       // Key interactive elements (buttons, active icons)
      secondary: primaryGreen,     // Floating action buttons, accent details
      background: darkGrey,        // Main background for most screens
      surface: black,            // Surface color for elements like cards and app bars
      onPrimary: black,            // Text/icons on primary-colored elements
      onSecondary: black,          // Text/icons on secondary-colored elements
      onBackground: white,         // Main text color on dark backgrounds
      onSurface: white,            // Text/icons on cards and surfaces
      error: Colors.redAccent,     // Color for error messages
      onError: white,              // Text on error-colored elements
    ),

    // --- Scaffold Background Color ---
    // Sets the default background color for all screens (Scaffolds)
    scaffoldBackgroundColor: darkGrey,

    // --- AppBar Theme ---
    // Defines the default style for all AppBars
    appBarTheme: const AppBarTheme(
      backgroundColor: black, // App bars will have a solid black background
      elevation: 0, // No shadow for a flatter, modern look
      iconTheme: IconThemeData(color: white), // Icons like the back arrow will be white
      titleTextStyle: TextStyle(
        color: white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    // --- Text Theme ---
    // Defines default styles for text. We can expand this with bodyText1, headline1, etc.
    // TODO: Choose a custom font and add it here via `fontFamily`
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: white),
      bodyMedium: TextStyle(color: grey),
      headlineMedium: TextStyle(fontWeight: FontWeight.bold, color: white),
    ),

    // --- Floating Action Button Theme ---
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryGreen,
      foregroundColor: black,
    ),

    // --- Bottom Navigation Bar Theme ---
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: black,
      selectedItemColor: primaryGreen,
      unselectedItemColor: grey,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
