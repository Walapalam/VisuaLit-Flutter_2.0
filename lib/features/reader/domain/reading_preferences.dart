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

  // This logic is moved from BookPaginator to be reusable by the UI.
  // It returns the correct TextStyle for a given block of text.
  TextStyle getStyleForBlock(BlockType type) {
    final baseStyle = TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      color: textColor,
      height: lineSpacing,
    );

    switch (type) {
      case BlockType.h1:
        return baseStyle.copyWith(fontSize: baseStyle.fontSize! * 1.8, fontWeight: FontWeight.bold);
      case BlockType.h2:
        return baseStyle.copyWith(fontSize: baseStyle.fontSize! * 1.5, fontWeight: FontWeight.bold);
      case BlockType.h3:
        return baseStyle.copyWith(fontSize: baseStyle.fontSize! * 1.3, fontWeight: FontWeight.w700);
      case BlockType.h4:
        return baseStyle.copyWith(fontSize: baseStyle.fontSize! * 1.15, fontWeight: FontWeight.w600);
      case BlockType.h5:
        return baseStyle.copyWith(fontSize: baseStyle.fontSize! * 1.1, fontWeight: FontWeight.w600);
      case BlockType.h6:
        return baseStyle.copyWith(fontSize: baseStyle.fontSize!, fontWeight: FontWeight.w600);
      case BlockType.p:
      case BlockType.unsupported:
      default:
        return baseStyle;
    }
  }
}