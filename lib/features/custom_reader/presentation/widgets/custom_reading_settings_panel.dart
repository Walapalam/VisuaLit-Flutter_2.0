import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import 'package:visualit/features/custom_reader/presentation/reading_preferences_controller.dart';
import 'package:visualit/features/custom_reader/model/reading_preferences.dart';
import 'package:visualit/core/theme/app_theme.dart';

class CustomReadingSettingsPanel extends ConsumerWidget {
  final String category;
  final VoidCallback onBack;
  final ScrollController scrollController;

  const CustomReadingSettingsPanel({
    super.key,
    required this.category,
    required this.onBack,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(readingPreferencesProvider);
    final prefsController = ref.read(readingPreferencesProvider.notifier);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12.0, left: 16.0, right: 16.0, bottom: 8.0),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white38,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Reading Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white24, height: 1),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SettingsRow(
                        icon: Icons.brightness_6_outlined,
                        label: 'Brightness',
                        child: Slider(
                          value: prefs.brightness,
                          min: 0.1,
                          max: 1.0,
                          onChanged: prefsController.setBrightness,
                          activeColor: Colors.white,
                          inactiveColor: Colors.white30,
                        ),
                      ),
                      const Divider(color: Colors.white24),
                      _SettingsRow(
                        icon: Icons.format_size,
                        label: 'Font Size',
                        child: Row(
                          children: [
                            const Text('a', style: TextStyle(fontSize: 14, color: Colors.white)),
                            Expanded(
                              child: Slider(
                                value: prefs.fontSize,
                                min: 12,
                                max: 32,
                                divisions: 20,
                                onChanged: prefsController.setFontSize,
                                activeColor: Colors.white,
                                inactiveColor: Colors.white30,
                              ),
                            ),
                            const Text('A', style: TextStyle(fontSize: 22, color: Colors.white)),
                          ],
                        ),
                      ),
                      const Divider(color: Colors.white24),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Font Family',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: availableFonts.map((font) => _FontButton(fontFamily: font)).toList(),
                        ),
                      ),
                      const Divider(color: Colors.white24),
                      _SettingsRow(
                        icon: Icons.swipe_outlined,
                        label: 'Page Turn Style',
                        child: SegmentedButton<PageTurnStyle>(
                          segments: const [
                            ButtonSegment(value: PageTurnStyle.paged, label: Text('Page')),
                            ButtonSegment(value: PageTurnStyle.scroll, label: Text('Scroll')),
                          ],
                          selected: {prefs.pageTurnStyle},
                          onSelectionChanged: (s) => prefsController.setPageTurnStyle(s.first),
                          style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.resolveWith<Color>(
                                  (states) => states.contains(MaterialState.selected)
                                  ? Colors.black
                                  : Colors.white,
                            ),
                            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                  (states) => states.contains(MaterialState.selected)
                                  ? Colors.white
                                  : Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                      const Divider(color: Colors.white24),
                      _SettingsRow(
                        icon: Icons.color_lens_outlined,
                        label: 'Color Theme',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _ThemeChip(theme: ReadingPreferences.light),
                            _ThemeChip(theme: ReadingPreferences.sepia),
                            _ThemeChip(theme: ReadingPreferences.dark),
                          ],
                        ),
                      ),
                      const Divider(color: Colors.white24),
                      SwitchListTile(
                        title: const Text('Match Device Theme', style: TextStyle(color: Colors.white)),
                        value: prefs.matchDeviceTheme,
                        onChanged: prefsController.setMatchDeviceTheme,
                        secondary: const Icon(Icons.brightness_auto_outlined, color: Colors.white),
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppTheme.primaryGreen,
                      ),
                      if (!prefs.matchDeviceTheme)
                        SwitchListTile(
                          title: const Text('Dark Mode', style: TextStyle(color: Colors.white)),
                          value: prefs.themeMode == ThemeMode.dark,
                          onChanged: (isDark) => prefsController.setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light),
                          secondary: const Icon(Icons.dark_mode_outlined, color: Colors.white),
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppTheme.primaryGreen,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper widgets for consistent layout with frosted glass aesthetic
class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
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
      onTap: () => ref.read(readingPreferencesProvider.notifier).applyTheme(theme),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.pageColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : Colors.white24,
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
        onPressed: () => ref.read(readingPreferencesProvider.notifier).setFontFamily(fontFamily),
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? Colors.white.withAlpha(51) : Colors.transparent,
          foregroundColor: Colors.white,
          side: BorderSide(color: isSelected ? Colors.white : Colors.grey),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(fontFamily, style: TextStyle(fontFamily: fontFamily)),
      ),
    );
  }
}
