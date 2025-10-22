import 'package:flutter/material.dart';
import 'app_theme.dart';

extension ResponsiveContext on BuildContext {
  // Screen Size Helpers
  bool get isMobile => MediaQuery.of(this).size.width < AppTheme.mobileBreakpoint;
  bool get isTablet => MediaQuery.of(this).size.width >= AppTheme.mobileBreakpoint &&
      MediaQuery.of(this).size.width < AppTheme.tabletBreakpoint;
  bool get isDesktop => MediaQuery.of(this).size.width >= AppTheme.tabletBreakpoint;

  // Grid Columns
  int get gridColumns => AppTheme.getGridColumns(MediaQuery.of(this).size.width);

  // Responsive Padding
  EdgeInsets get screenPadding {
    if (isMobile) return const EdgeInsets.all(AppSpacing.md);
    if (isTablet) return const EdgeInsets.all(AppSpacing.lg);
    return const EdgeInsets.all(AppSpacing.xl);
  }

  // Card Aspect Ratio
  double get cardAspectRatio {
    if (isMobile) return 2 / 3.5;
    if (isTablet) return 2 / 3;
    return 0.7;
  }

  // Book Shelf Height
  double get bookShelfHeight {
    if (isMobile) return 200.0;
    if (isTablet) return 240.0;
    return 280.0;
  }

  // Responsive Font Size
  double responsiveFontSize(double baseSize, {double minSize = 10.0, double maxSize = 24.0}) {
    return AppTypography.getResponsiveSize(this, baseSize, minSize: minSize, maxSize: maxSize);
  }
}
