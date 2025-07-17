import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeController extends StateNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.dark) {
    debugPrint("[DEBUG] ThemeController: Initialized with theme mode: ${ThemeMode.dark}");
  }

  void toggleTheme() {
    final newTheme = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    debugPrint("[DEBUG] ThemeController: Toggling theme from ${state.name} to ${newTheme.name}");
    state = newTheme;
  }
}

final themeControllerProvider = StateNotifierProvider<ThemeController, ThemeMode>(
      (ref) => ThemeController(),
);
