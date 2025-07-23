import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';

class ReadingSettingsPanel extends ConsumerWidget {
  const ReadingSettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print("DEBUG: ReadingSettingsPanel.build() called.");
    final prefs = ref.watch(readingPreferencesProvider);
    final prefsController = ref.read(readingPreferencesProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final panelColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white70 : Colors.black87;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brightness Slider
              _SettingsRow(
                icon: Icons.brightness_6_outlined,
                child: Slider(
                  value: prefs.brightness,
                  min: 0.1,
                  max: 1.0,
                  onChanged: prefsController.setBrightness,
                ),
              ),
              const Divider(),
              // Font Size Slider
              _SettingsRow(
                icon: Icons.format_size,
                child: Row(
                  children: [
                    const Text('a', style: TextStyle(fontSize: 14)),
                    Expanded(
                      child: Slider(
                        value: prefs.fontSize,
                        min: 12,
                        max: 32,
                        divisions: 20,
                        label: prefs.fontSize.round().toString(),
                        onChanged: prefsController.setFontSize,
                      ),
                    ),
                    const Text('A', style: TextStyle(fontSize: 22)),
                  ],
                ),
              ),
              const Divider(),
              // --- NEW WIDGET: LINE SPACING SLIDER ---
              _SettingsRow(
                icon: Icons.format_line_spacing,
                child: Slider(
                  value: prefs.lineSpacing,
                  min: 1.2,   // Minimum line spacing
                  max: 2.5,   // Maximum line spacing
                  divisions: 13,
                  label: prefs.lineSpacing.toStringAsFixed(1),
                  onChanged: (value) {
                    print("DEBUG: [SettingsPanel] Line spacing slider changed to $value");
                    prefsController.setLineSpacing(value);
                  },
                ),
              ),
              const Divider(),
              // Font Family
              SizedBox(
                height: 50,
                child: _SettingsRow(
                  icon: Icons.font_download_outlined,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: availableFonts.map((font) => _FontButton(fontFamily: font)).toList(),
                  ),
                ),
              ),
              const Divider(),
              // Indentation Slider
              _SettingsRow(
                icon: Icons.format_indent_increase,
                child: Slider(
                  value: prefs.textIndent,
                  min: 0.0,
                  max: 4.0,
                  divisions: 8,
                  label: "${prefs.textIndent.toStringAsFixed(1)}em",
                  onChanged: (value) {
                    print("DEBUG: [SettingsPanel] Indent slider changed to $value");
                    prefsController.setTextIndent(value);
                  },
                ),
              ),
              const Divider(),
              // Page Turn Style
              _SettingsRow(
                icon: Icons.swipe_outlined,
                child: SegmentedButton<PageTurnStyle>(
                  segments: const [
                    ButtonSegment(value: PageTurnStyle.paged, label: Text('Page')),
                    ButtonSegment(value: PageTurnStyle.scroll, label: Text('Scroll')),
                  ],
                  selected: {prefs.pageTurnStyle},
                  onSelectionChanged: (s) => prefsController.setPageTurnStyle(s.first),
                ),
              ),
              const Divider(),
              // Color Themes
              _SettingsRow(
                icon: Icons.color_lens_outlined,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ThemeChip(theme: ReadingPreferences.light),
                    _ThemeChip(theme: ReadingPreferences.sepia),
                    _ThemeChip(theme: ReadingPreferences.dark),
                  ],
                ),
              ),
              const Divider(),
              // Light/Dark/System Mode
              SwitchListTile(
                title: Text('Match Device Theme', style: TextStyle(color: textColor)),
                value: prefs.matchDeviceTheme,
                onChanged: prefsController.setMatchDeviceTheme,
                secondary: const Icon(Icons.brightness_auto_outlined),
                contentPadding: EdgeInsets.zero,
              ),
              if (!prefs.matchDeviceTheme)
                SwitchListTile(
                  title: Text('Dark Mode', style: TextStyle(color: textColor)),
                  value: prefs.themeMode == ThemeMode.dark,
                  onChanged: (isDark) => prefsController.setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light),
                  secondary: const Icon(Icons.dark_mode_outlined),
                  contentPadding: EdgeInsets.zero,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper widgets for consistent layout
class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Widget child;
  const _SettingsRow({required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Expanded(child: child),
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
      onTap: () {
        print("DEBUG: [SettingsPanel] Theme chip tapped. Applying theme.");
        ref.read(readingPreferencesProvider.notifier).applyTheme(theme);
      },
      child: Container(
        width: 40,
        height: 40,
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
          print("DEBUG: [SettingsPanel] Font button tapped: $fontFamily");
          ref.read(readingPreferencesProvider.notifier).setFontFamily(fontFamily);
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? Theme.of(context).colorScheme.primary.withAlpha(51) : null,
          foregroundColor: prefs.textColor,
          side: BorderSide(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(fontFamily, style: TextStyle(fontFamily: fontFamily)),
      ),
    );
  }
}