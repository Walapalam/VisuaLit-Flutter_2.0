// lib/features/reader/presentation/widgets/reading_settings_panel.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';

class ReadingSettingsPanel extends ConsumerWidget {
  const ReadingSettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(readingPreferencesProvider);
    final prefsController = ref.read(readingPreferencesProvider.notifier);
    final isDark = prefs.themeMode == ThemeMode.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final panelColor = isDark ? const Color(0xFF2C2C2E) : Colors.grey[200];
    final textColor = isDark ? Colors.white70 : Colors.black87;

    print("🔄 [SettingsPanel] Building settings panel.");

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- FONT SIZE & THEME ROW ---
            _buildSectionContainer(
              isDark: isDark,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('a', style: TextStyle(fontSize: 16)),
                      Expanded(
                        child: Slider(
                          value: prefs.fontSize,
                          min: 12,
                          max: 32,
                          // Use onChangeEnd to avoid excessive logging while dragging
                          onChangeEnd: (value) {
                            print("  [SettingsPanel] Changing font size to ${value.toStringAsFixed(1)}");
                            prefsController.state = prefs.copyWith(fontSize: value);
                          },
                          onChanged: (value) => prefsController.state = prefs.copyWith(fontSize: value),
                          activeColor: primaryColor,
                        ),
                      ),
                      const Text('A', style: TextStyle(fontSize: 24)),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ThemeChip(theme: ReadingPreferences.light),
                      _ThemeChip(theme: ReadingPreferences.sepia),
                      _ThemeChip(theme: ReadingPreferences.dark),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- FONT FAMILY SELECTION ---
            _buildSectionContainer(
              isDark: isDark,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: availableFonts.map((font) {
                    return _FontButton(fontFamily: font);
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- ACCESSIBILITY OPTIONS ---
            _buildSectionContainer(
              isDark: isDark,
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Line Guide', style: TextStyle(color: textColor)),
                    value: prefs.isLineGuideEnabled,
                    onChanged: (value) {
                      print("  [SettingsPanel] Toggling Line Guide to: $value");
                      prefsController.toggleLineGuide(value);
                    },
                    activeColor: primaryColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  if (prefs.isLineGuideEnabled) ...[
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: SegmentedButton<BackgroundDimming>(
                        segments: const [
                          ButtonSegment(value: BackgroundDimming.none, label: Text('None')),
                          ButtonSegment(value: BackgroundDimming.low, label: Text('Low')),
                          ButtonSegment(value: BackgroundDimming.medium, label: Text('Med')),
                          ButtonSegment(value: BackgroundDimming.high, label: Text('High')),
                        ],
                        selected: {prefs.backgroundDimming},
                        onSelectionChanged: (s) {
                          print("  [SettingsPanel] Changing background dimming to: ${s.first.name}");
                          prefsController.setBackgroundDimming(s.first);
                        },
                        style: SegmentedButton.styleFrom(
                          backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                          foregroundColor: textColor,
                          selectedForegroundColor: panelColor,
                          selectedBackgroundColor: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContainer({required Widget child, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class _ThemeChip extends ConsumerWidget {
  final ReadingPreferences theme;
  const _ThemeChip({required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTheme = ref.watch(readingPreferencesProvider);
    final bool isSelected = selectedTheme.pageColor == theme.pageColor;

    return GestureDetector(
      onTap: () {
        print("  [SettingsPanel] Changing theme to one with page color: ${theme.pageColor}");
        ref.read(readingPreferencesProvider.notifier).setTheme(theme);
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: theme.pageColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
            width: isSelected ? 3 : 1,
          ),
        ),
      ),
    );
  }
}

class _FontButton extends ConsumerWidget {
  final String fontFamily;
  const _FontButton({required this.fontFamily});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(readingPreferencesProvider);
    final isSelected = prefs.fontFamily == fontFamily;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: OutlinedButton(
        onPressed: () {
          print("  [SettingsPanel] Setting font family to: $fontFamily");
          ref.read(readingPreferencesProvider.notifier).setFontFamily(fontFamily);
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : null,
          foregroundColor: prefs.themeMode == ThemeMode.dark ? Colors.white70 : Colors.black87,
          side: BorderSide(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(fontFamily, style: TextStyle(fontFamily: fontFamily)),
      ),
    );
  }
}