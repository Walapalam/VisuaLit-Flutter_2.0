import 'package:flutter_riverpod/flutter_riverpod.dart';

final fontSizeProvider = StateProvider<double>((ref) => 16.0);

final selectedFontProvider = StateProvider<String>((ref) => 'Roboto');

final fontSizeNotifierProvider = StateNotifierProvider<FontSizeNotifier, String>((ref) {
  return FontSizeNotifier();
});

class FontSizeNotifier extends StateNotifier<String> {
  FontSizeNotifier() : super('Medium');

  void setFontSize(String size) {
    state = size;
  }

  double getFontSizeValue() {
    switch (state) {
      case 'Small': return 14.0;
      case 'Large': return 18.0;
      default: return 16.0;
    }
  }
}

final fontStyleProvider = StateNotifierProvider<FontStyleNotifier, String>((ref) {
  return FontStyleNotifier();
});

class FontStyleNotifier extends StateNotifier<String> {
  FontStyleNotifier() : super('Inter');

  static const List<String> fontStyleOptions = [
    'Inter',
    'Roboto',
    'Poppins',
    'OpenSans'
  ];

  void setFontStyle(String style) {
    state = style;
  }
}