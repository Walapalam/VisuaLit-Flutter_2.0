import 'package:flutter/material.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';

class LineGuidePainter extends CustomPainter {
  final double lineGuideY;
  final ReadingPreferences preferences;

  LineGuidePainter({required this.lineGuideY, required this.preferences});

  @override
  void paint(Canvas canvas, Size size) {
    // Only paint if the guide is enabled
    if (!preferences.isLineGuideEnabled) return;

    // Define the height of the clear reading area
    final guideHeight = preferences.fontSize * preferences.lineSpacing * 2;
    // Calculate the top of the guide, clamping it to the screen bounds
    final guideTop = (lineGuideY - guideHeight / 2).clamp(0.0, size.height - guideHeight);
    final guideBottom = guideTop + guideHeight;

    // --- 1. Draw Background Dimming ---
    final dimmingPaint = Paint()
      ..color = _getDimmingColor()
      ..style = PaintingStyle.fill;

    if (dimmingPaint.color.alpha > 0) {
      // Draw the top dimmed rectangle
      canvas.drawRect(Rect.fromLTRB(0, 0, size.width, guideTop), dimmingPaint);
      // Draw the bottom dimmed rectangle
      canvas.drawRect(Rect.fromLTRB(0, guideBottom, size.width, size.height), dimmingPaint);
    }

    // --- 2. Draw Guide Lines ---
    final linePaint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..strokeWidth = 1.0;

    canvas.drawLine(Offset(0, guideTop), Offset(size.width, guideTop), linePaint);
    canvas.drawLine(Offset(0, guideBottom), Offset(size.width, guideBottom), linePaint);
  }

  Color _getDimmingColor() {
    final baseColor = preferences.themeMode == ThemeMode.dark ? Colors.black : Colors.black;
    switch (preferences.backgroundDimming) {
      case BackgroundDimming.none:
        return baseColor.withOpacity(0);
      case BackgroundDimming.low:
        return baseColor.withOpacity(0.25);
      case BackgroundDimming.medium:
        return baseColor.withOpacity(0.5);
      case BackgroundDimming.high:
        return baseColor.withOpacity(0.7);
    }
  }

  @override
  bool shouldRepaint(covariant LineGuidePainter oldDelegate) {
    // Repaint whenever the guide's position or any preference changes
    return oldDelegate.lineGuideY != lineGuideY || oldDelegate.preferences != preferences;
  }
}