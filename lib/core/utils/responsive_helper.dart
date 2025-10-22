import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Defines screen size categories based on width breakpoints
enum ScreenSize {
  mobile,
  tablet,
  desktop,
}

/// Provides responsive utilities for adapting UI to different screen sizes
class ResponsiveHelper {
  // Private constructor to prevent instantiation
  ResponsiveHelper._();

  /// Returns the current screen size category
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < AppTheme.mobileBreakpoint) return ScreenSize.mobile;
    if (width < AppTheme.tabletBreakpoint) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }

  /// Returns appropriate grid column count based on screen width
  static int getGridColumns(BuildContext context) {
    return AppTheme.getGridColumns(MediaQuery.of(context).size.width);
  }

  /// Returns appropriate aspect ratio for book cards
  static double getCardAspectRatio(BuildContext context) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.mobile:
        return 2 / 3.5;
      case ScreenSize.tablet:
        return 2 / 3;
      case ScreenSize.desktop:
        return 0.7;
    }
  }

  /// Returns responsive padding based on screen size
  static EdgeInsets getScreenPadding(BuildContext context) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.mobile:
        return const EdgeInsets.all(AppSpacing.md);
      case ScreenSize.tablet:
        return const EdgeInsets.all(AppSpacing.lg);
      case ScreenSize.desktop:
        return const EdgeInsets.all(AppSpacing.xl);
    }
  }

  /// Returns responsive font size with min/max constraints
  static double getResponsiveFontSize(
      BuildContext context,
      double baseSize, {
        double minSize = 10.0,
        double maxSize = 24.0,
      }) {
    return AppTypography.getResponsiveSize(
      context,
      baseSize,
      minSize: minSize,
      maxSize: maxSize,
    );
  }


  /// Returns responsive height for horizontal book shelves
  static double getBookShelfHeight(BuildContext context) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.mobile:
        return 200.0;
      case ScreenSize.tablet:
        return 240.0;
      case ScreenSize.desktop:
        return 280.0;
    }
  }

  /// Returns responsive spacing between items
  static double getItemSpacing(BuildContext context) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.mobile:
        return AppSpacing.sm;
      case ScreenSize.tablet:
        return AppSpacing.md;
      case ScreenSize.desktop:
        return AppSpacing.lg;
    }
  }

  /// Returns responsive cover image dimensions
  static Size getCoverImageSize(BuildContext context) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.mobile:
        return const Size(120, 180);
      case ScreenSize.tablet:
        return const Size(160, 240);
      case ScreenSize.desktop:
        return const Size(200, 300);
    }
  }

  /// Returns responsive icon size
  static double getIconSize(BuildContext context, {double baseSize = 24.0}) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.mobile:
        return baseSize;
      case ScreenSize.tablet:
        return baseSize * 1.2;
      case ScreenSize.desktop:
        return baseSize * 1.4;
    }
  }

  /// Returns responsive button height
  static double getButtonHeight(BuildContext context) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.mobile:
        return 48.0;
      case ScreenSize.tablet:
        return 52.0;
      case ScreenSize.desktop:
        return 56.0;
    }
  }

  /// Returns responsive dialog width
  static double getDialogWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return width * 0.9;
    if (width < 1200) return 500.0;
    return 600.0;
  }

  /// Helper to check if device is in landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Helper to check if device is mobile size
  static bool isMobile(BuildContext context) {
    return getScreenSize(context) == ScreenSize.mobile;
  }

  /// Helper to check if device is tablet size or larger
  static bool isTabletOrLarger(BuildContext context) {
    final size = getScreenSize(context);
    return size == ScreenSize.tablet || size == ScreenSize.desktop;
  }
}
