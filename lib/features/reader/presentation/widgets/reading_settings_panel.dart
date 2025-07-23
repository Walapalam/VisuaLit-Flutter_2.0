import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart'; // For ReadingPreferences and its controller

class ReadingSettingsPanel extends ConsumerWidget {
  const ReadingSettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(readingPreferencesProvider);
    final prefsController = ref.read(readingPreferencesProvider.notifier);
    // Determine if app is in dark mode based on current theme brightness
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Set panel and text colors dynamically for light/dark themes
    final panelColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white70 : Colors.black87;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), // Rounded top corners
      ),
      child: SafeArea(
        top: false, // Don't pad top for status bar (already handled by modal)
        child: SingleChildScrollView( // Allows content to scroll if too long
          child: Column(
            mainAxisSize: MainAxisSize.min, // Column takes minimum space
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Brightness Slider
              _SettingsRow(
                icon: Icons.brightness_6_outlined,
                child: Slider(
                  value: prefs.brightness,
                  min: 0.1, // Minimum brightness
                  max: 1.0, // Maximum brightness
                  onChanged: prefsController.setBrightness, // Update brightness
                ),
              ),
              const Divider(), // Separator
              // Font Size Slider
              _SettingsRow(
                icon: Icons.format_size,
                child: Row(
                  children: [
                    const Text('a', style: TextStyle(fontSize: 14)), // Small 'a' indicator
                    Expanded(
                      child: Slider(
                        value: prefs.fontSize,
                        min: 12, // Minimum font size
                        max: 32, // Maximum font size
                        divisions: 20, // Slider stops
                        onChanged: prefsController.setFontSize, // Update font size
                      ),
                    ),
                    const Text('A', style: TextStyle(fontSize: 22)), // Large 'A' indicator
                  ],
                ),
              ),
              const Divider(),
              // Font Family Selector (Horizontal ListView of buttons)
              SizedBox(
                height: 50, // Fixed height for horizontal list
                child: _SettingsRow(
                  icon: Icons.font_download_outlined,
                  child: ListView(
                    scrollDirection: Axis.horizontal, // Horizontal scroll
                    children: availableFonts.map((font) => _FontButton(fontFamily: font)).toList(),
                  ),
                ),
              ),
              const Divider(),
              // Page Turn Style Selector (Segmented Button)
              _SettingsRow(
                icon: Icons.swipe_outlined,
                child: SegmentedButton<PageTurnStyle>(
                  segments: const [
                    ButtonSegment(value: PageTurnStyle.paged, label: Text('Page')),
                    ButtonSegment(value: PageTurnStyle.scroll, label: Text('Scroll')),
                  ],
                  selected: {prefs.pageTurnStyle}, // Selected segment
                  onSelectionChanged: (s) => prefsController.setPageTurnStyle(s.first), // Update page style
                ),
              ),
              const Divider(),
              // Color Themes (Chips for different reading themes)
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
              // Match Device Theme Switch
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

// Helper widget for consistent layout of settings rows
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
          Icon(icon, color: Colors.grey[600]), // Icon for the setting
          const SizedBox(width: 16), // Spacing
          Expanded(child: child), // The actual control (slider, button etc.)
        ],
      ),
    );
  }
}

// Helper widget for theme selection chips
class _ThemeChip extends ConsumerWidget {
  final ReadingPreferences theme; // A ReadingPreferences preset
  const _ThemeChip({required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTheme = ref.watch(readingPreferencesProvider); // Current active theme
    final bool isSelected = selectedTheme.pageColor == theme.pageColor; // Check if this chip's theme is active

    return GestureDetector(
      onTap: () => ref.read(readingPreferencesProvider.notifier).applyTheme(theme), // Apply this theme preset
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.pageColor, // Chip color is the page color of the theme
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade400, // Highlight if selected
            width: isSelected ? 3 : 1,
          ),
        ),
      ),
    );
  }
}

// Helper widget for font family selection buttons
class _FontButton extends ConsumerWidget {
  final String fontFamily; // Name of the font family
  const _FontButton({required this.fontFamily});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(readingPreferencesProvider); // Current preferences
    final isSelected = prefs.fontFamily == fontFamily; // Check if this font is active

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: OutlinedButton(
        onPressed: () => ref.read(readingPreferencesProvider.notifier).setFontFamily(fontFamily), // Set this font family
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? Theme.of(context).colorScheme.primary.withAlpha(51) : null, // Highlight if selected
          foregroundColor: prefs.textColor, // Text color from preferences
          side: BorderSide(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey), // Border color
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Rounded corners
        ),
        child: Text(fontFamily, style: TextStyle(fontFamily: fontFamily)), // Display font name with its actual style
      ),
    );
  }
}