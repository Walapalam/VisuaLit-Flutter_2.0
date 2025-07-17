import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:visualit/features/reader/data/book_data.dart'; // We'll need BlockType from here

// This class holds all the user-configurable reading settings.
@immutable
class ReadingPreferences {
  final String fontFamily;
  final double fontSize;
  final double lineSpacing;
  final Color textColor;
  final Color backgroundColor;

  const ReadingPreferences({
    this.fontFamily = 'Georgia', // A good default serif font for reading
    this.fontSize = 18.0,
    this.lineSpacing = 1.5,
    this.textColor = Colors.black,
    this.backgroundColor = const Color(0xFFFBF5E9), // A pleasant sepia background
  });

  // Factory constructor for debugging
  static ReadingPreferences create({
    String fontFamily = 'Georgia',
    double fontSize = 18.0,
    double lineSpacing = 1.5,
    Color textColor = Colors.black,
    Color backgroundColor = const Color(0xFFFBF5E9),
  }) {
    debugPrint("[DEBUG] ReadingPreferences: Creating instance with fontFamily: $fontFamily, fontSize: $fontSize");
    return ReadingPreferences(
      fontFamily: fontFamily,
      fontSize: fontSize,
      lineSpacing: lineSpacing,
      textColor: textColor,
      backgroundColor: backgroundColor,
    );
  }

  // This logic is moved from BookPaginator to be reusable by the UI.
  // It returns the correct TextStyle for a given block of text.
  TextStyle getStyleForBlock(BlockType type) {
    debugPrint("[DEBUG] ReadingPreferences.getStyleForBlock: Getting style for block type: $type");

    final baseStyle = TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      color: textColor,
      height: lineSpacing,
    );

    debugPrint("[DEBUG] ReadingPreferences.getStyleForBlock: Base style - fontFamily: $fontFamily, fontSize: $fontSize");

    switch (type) {
      case BlockType.h1:
        debugPrint("[DEBUG] ReadingPreferences.getStyleForBlock: Returning H1 style (fontSize: ${baseStyle.fontSize! * 1.8})");
        return baseStyle.copyWith(fontSize: baseStyle.fontSize! * 1.8, fontWeight: FontWeight.bold);
      case BlockType.h2:
        debugPrint("[DEBUG] ReadingPreferences.getStyleForBlock: Returning H2 style (fontSize: ${baseStyle.fontSize! * 1.5})");
        return baseStyle.copyWith(fontSize: baseStyle.fontSize! * 1.5, fontWeight: FontWeight.bold);
      case BlockType.h3:
        debugPrint("[DEBUG] ReadingPreferences.getStyleForBlock: Returning H3 style (fontSize: ${baseStyle.fontSize! * 1.3})");
        return baseStyle.copyWith(fontSize: baseStyle.fontSize! * 1.3, fontWeight: FontWeight.w700);
      case BlockType.h4:
        debugPrint("[DEBUG] ReadingPreferences.getStyleForBlock: Returning H4 style (fontSize: ${baseStyle.fontSize! * 1.15})");
        return baseStyle.copyWith(fontSize: baseStyle.fontSize! * 1.15, fontWeight: FontWeight.w600);
      case BlockType.h5:
        debugPrint("[DEBUG] ReadingPreferences.getStyleForBlock: Returning H5 style (fontSize: ${baseStyle.fontSize! * 1.1})");
        return baseStyle.copyWith(fontSize: baseStyle.fontSize! * 1.1, fontWeight: FontWeight.w600);
      case BlockType.h6:
        debugPrint("[DEBUG] ReadingPreferences.getStyleForBlock: Returning H6 style (fontSize: ${baseStyle.fontSize!})");
        return baseStyle.copyWith(fontSize: baseStyle.fontSize!, fontWeight: FontWeight.w600);
      case BlockType.p:
      case BlockType.unsupported:
      default:
        debugPrint("[DEBUG] ReadingPreferences.getStyleForBlock: Returning default style (fontSize: ${baseStyle.fontSize!})");
        return baseStyle;
    }
  }
}
