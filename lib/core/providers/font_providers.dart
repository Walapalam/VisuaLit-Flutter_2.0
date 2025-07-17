import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, String>((ref) {
  debugPrint("[DEBUG] fontSizeProvider: Creating FontSizeNotifier");
  return FontSizeNotifier();
});

class FontSizeNotifier extends StateNotifier<String> {
  FontSizeNotifier() : super('Medium') {
    debugPrint("[DEBUG] FontSizeNotifier: Initialized with default size: Medium");
  }

  void setFontSize(String size) {
    debugPrint("[DEBUG] FontSizeNotifier: Setting font size from $state to $size");
    state = size;
  }

  double getFontSizeValue() {
    final double value;
    switch (state) {
      case 'Small': 
        value = 14.0;
        break;
      case 'Large': 
        value = 18.0;
        break;
      default: 
        value = 16.0;
        break;
    }
    debugPrint("[DEBUG] FontSizeNotifier: Getting font size value for $state: $value");
    return value;
  }
}

final fontStyleProvider = StateNotifierProvider<FontStyleNotifier, String>((ref) {
  debugPrint("[DEBUG] fontStyleProvider: Creating FontStyleNotifier");
  return FontStyleNotifier();
});

class FontStyleNotifier extends StateNotifier<String> {
  FontStyleNotifier() : super('Inter') {
    debugPrint("[DEBUG] FontStyleNotifier: Initialized with default style: Inter");
  }

  static const List<String> fontStyleOptions = [
    'Inter',
    'Roboto',
    'Poppins',
    'OpenSans'
  ];

  void setFontStyle(String style) {
    debugPrint("[DEBUG] FontStyleNotifier: Setting font style from $state to $style");
    state = style;
  }

  // Helper method to log available font options
  void logAvailableFonts() {
    debugPrint("[DEBUG] FontStyleNotifier: Available font styles: ${fontStyleOptions.join(', ')}");
  }
}
