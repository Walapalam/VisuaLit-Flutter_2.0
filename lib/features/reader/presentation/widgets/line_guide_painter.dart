import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';

class LineGuidePainter extends CustomPainter {
  final double lineGuideY;
  final ReadingPreferences preferences;

  const LineGuidePainter({required this.lineGuideY, required this.preferences});

  @override
  void paint(Canvas canvas, Size size) {
    debugPrint("[DEBUG] LineGuidePainter: Paint called with lineGuideY: $lineGuideY, size: ${size.width}x${size.height}");

    if (!preferences.isLineGuideEnabled) {
      debugPrint("[DEBUG] LineGuidePainter: Line guide disabled, skipping paint");
      return;
    }

    final guideHeight = preferences.fontSize * preferences.lineSpacing * 2;
    final guideTop = (lineGuideY - guideHeight / 2).clamp(0.0, size.height - guideHeight);
    final guideBottom = guideTop + guideHeight;

    debugPrint("[DEBUG] LineGuidePainter: Calculated guide dimensions - height: $guideHeight, top: $guideTop, bottom: $guideBottom");

    final dimmingPaint = Paint()
      ..color = _getDimmingColor()
      ..style = PaintingStyle.fill;

    if (dimmingPaint.color.alpha > 0) {
      debugPrint("[DEBUG] LineGuidePainter: Drawing dimming rectangles with alpha: ${dimmingPaint.color.alpha}");
      canvas.drawRect(Rect.fromLTRB(0, 0, size.width, guideTop), dimmingPaint);
      canvas.drawRect(Rect.fromLTRB(0, guideBottom, size.width, size.height), dimmingPaint);
    } else {
      debugPrint("[DEBUG] LineGuidePainter: Skipping dimming rectangles (alpha is 0)");
    }

    final linePaint = Paint()
      ..color = Colors.blue.withAlpha(128) // Fixed deprecated call
      ..strokeWidth = 1.0;

    debugPrint("[DEBUG] LineGuidePainter: Drawing guide lines at y=$guideTop and y=$guideBottom");
    canvas.drawLine(Offset(0, guideTop), Offset(size.width, guideTop), linePaint);
    canvas.drawLine(Offset(0, guideBottom), Offset(size.width, guideBottom), linePaint);
  }

  Color _getDimmingColor() {
    debugPrint("[DEBUG] LineGuidePainter: Getting dimming color for theme mode: ${preferences.themeMode}");
    final baseColor = preferences.themeMode == ThemeMode.dark ? Colors.white : Colors.black;

    final Color result;
    switch (preferences.backgroundDimming) {
      case BackgroundDimming.none:
        debugPrint("[DEBUG] LineGuidePainter: Using 'none' dimming (alpha: 0)");
        result = baseColor.withAlpha(0);
        break;
      case BackgroundDimming.low:
        debugPrint("[DEBUG] LineGuidePainter: Using 'low' dimming (alpha: 64)");
        result = baseColor.withAlpha(64); // ~25%
        break;
      case BackgroundDimming.medium:
        debugPrint("[DEBUG] LineGuidePainter: Using 'medium' dimming (alpha: 128)");
        result = baseColor.withAlpha(128); // ~50%
        break;
      case BackgroundDimming.high:
        debugPrint("[DEBUG] LineGuidePainter: Using 'high' dimming (alpha: 178)");
        result = baseColor.withAlpha(178); // ~70%
        break;
    }

    return result;
  }

  @override
  bool shouldRepaint(covariant LineGuidePainter oldDelegate) {
    final shouldRepaint = oldDelegate.lineGuideY != lineGuideY || oldDelegate.preferences != preferences;
    debugPrint("[DEBUG] LineGuidePainter: shouldRepaint: $shouldRepaint (oldY: ${oldDelegate.lineGuideY}, newY: $lineGuideY)");
    return shouldRepaint;
  }
}
