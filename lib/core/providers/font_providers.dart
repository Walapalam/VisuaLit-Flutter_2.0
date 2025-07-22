import 'package:flutter_riverpod/flutter_riverpod.dart';

final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, String>((ref) {
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

/// Provider that combines font size and style into a single map
final fontSettingsProvider = Provider<Map<String, dynamic>>((ref) {
  final fontSize = ref.watch(fontSizeProvider);
  final fontStyle = ref.watch(fontStyleProvider);
  final fontSizeValue = ref.read(fontSizeProvider.notifier).getFontSizeValue();

  return {
    'fontSize': fontSizeValue,
    'fontFamily': fontStyle,
    'fontSizeName': fontSize,
    'lineSpacing': 1.5, // Default line spacing
  };
});
