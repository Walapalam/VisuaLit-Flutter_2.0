import 'dart:ui';
import 'package:flutter/material.dart';

class LiquidGlassContainer extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double sigmaX;
  final double sigmaY;
  final bool applyPaddingOnBlur;

  const LiquidGlassContainer({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.backgroundColor,
    this.sigmaX = 10.0,
    this.sigmaY = 10.0,
    this.applyPaddingOnBlur = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(16.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white.withOpacity(0.15),
            borderRadius: borderRadius ?? BorderRadius.circular(16.0),
            border: Border.all(
              color: Colors.white.withOpacity(0.2), // Subtle border
              width: 0.5,
            ),
          ),
          padding: applyPaddingOnBlur ? padding : null,
          child: applyPaddingOnBlur ? child : Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}