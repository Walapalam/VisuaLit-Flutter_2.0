import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_state.dart';

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(ThemeState.initial()) {
    _loadTheme();
  }

  static const _themeKey = 'theme_mode';
  static const _fontFamilyKey = 'font_family';
  static const _fontSizeKey = 'font_size';

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    final fontFamily = prefs.getString(_fontFamilyKey) ?? 'OpenSans';
    final fontSize = prefs.getDouble(_fontSizeKey) ?? ThemeState.fontMedium;

    state = ThemeState(
      themeMode: ThemeMode.values[themeIndex],
      fontFamily: fontFamily,
      fontSize: fontSize,
    );
  }

  Future<void> _saveTheme(ThemeState newState) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, newState.themeMode.index);
    await prefs.setString(_fontFamilyKey, newState.fontFamily);
    await prefs.setDouble(_fontSizeKey, newState.fontSize);
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final newMode = state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;

    state = state.copyWith(themeMode: newMode);
    await _saveTheme(state);
  }

  /// Set specific theme mode
  Future<void> setTheme(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _saveTheme(state);
  }

  /// Set font family
  Future<void> setFontFamily(String fontFamily) async {
    const validFonts = ['Dyslexie', 'OpenDyslexie', 'Jersey20'];
    if (validFonts.contains(fontFamily)) {
      state = state.copyWith(fontFamily: fontFamily);
      await _saveTheme(state);
    }
  }

  /// Set font size
  Future<void> setFontSize(double fontSize) async {
    state = state.copyWith(fontSize: fontSize);
    await _saveTheme(state);
  }
}
