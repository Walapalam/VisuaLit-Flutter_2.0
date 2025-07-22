import 'package:flutter/material.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';

class LineGuidePainter extends CustomPainter {
  final double lineGuideY;
  final ReadingPreferences preferences;

  const LineGuidePainter({required this.lineGuideY, required this.preferences});

  @override
  void paint(Canvas canvas, Size size) {
    if (!preferences.isLineGuideEnabled) return;

    final guideHeight = preferences.fontSize * preferences.lineSpacing * 2;
    final guideTop = (lineGuideY - guideHeight / 2).clamp(0.0, size.height - guideHeight);
    final guideBottom = guideTop + guideHeight;

    final dimmingPaint = Paint()
      ..color = _getDimmingColor()
      ..style = PaintingStyle.fill;

    if (dimmingPaint.color.alpha > 0) {
      canvas.drawRect(Rect.fromLTRB(0, 0, size.width, guideTop), dimmingPaint);
      canvas.drawRect(Rect.fromLTRB(0, guideBottom, size.width, size.height), dimmingPaint);
    }

    final linePaint = Paint()
      ..color = Colors.blue.withAlpha(128) // Fixed deprecated call
      ..strokeWidth = 1.0;

    canvas.drawLine(Offset(0, guideTop), Offset(size.width, guideTop), linePaint);
    canvas.drawLine(Offset(0, guideBottom), Offset(size.width, guideBottom), linePaint);
  }

  Color _getDimmingColor() {
    final baseColor = preferences.themeMode == ThemeMode.dark ? Colors.black : Colors.black;
    switch (preferences.backgroundDimming) {
      case BackgroundDimming.none:
        return baseColor.withAlpha(0);
      case BackgroundDimming.low:
        return baseColor.withAlpha(64); // ~25%
      case BackgroundDimming.medium:
        return baseColor.withAlpha(128); // ~50%
      case BackgroundDimming.high:
        return baseColor.withAlpha(178); // ~70%
    }
  }

  @override
  bool shouldRepaint(covariant LineGuidePainter oldDelegate) {
    return oldDelegate.lineGuideY != lineGuideY || oldDelegate.preferences != preferences;
  }
}