import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_notifier.dart';
import '../theme/theme_state.dart';

final themeControllerProvider =
    StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
      return ThemeNotifier();
    });
