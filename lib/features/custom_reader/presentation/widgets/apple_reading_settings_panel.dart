import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import 'package:visualit/features/custom_reader/presentation/reading_preferences_controller.dart';
import 'package:visualit/features/custom_reader/model/reading_preferences.dart';
import 'package:visualit/core/theme/app_theme.dart';

class AppleReadingSettingsPanel extends ConsumerWidget {
  final VoidCallback onBack;
  final ScrollController scrollController;

  const AppleReadingSettingsPanel({
    super.key,
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
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(
              0xFF1C1C1E,
            ).withOpacity(0.85), // Dark iOS-like background
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.1), width: 0.5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),

              // Title Row with Close Button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Appearance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: onBack,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 30,
                          minHeight: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white10, height: 1),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Brightness Slider
                      Row(
                        children: [
                          const Icon(
                            Icons.brightness_5,
                            size: 18,
                            color: Colors.grey,
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 4,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 10,
                                ),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 20,
                                ),
                              ),
                              child: Slider(
                                value: prefs.brightness,
                                min: 0.1,
                                max: 1.0,
                                onChanged: prefsController.setBrightness,
                                activeColor: Colors.white,
                                inactiveColor: Colors.grey[800],
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.brightness_7,
                            size: 24,
                            color: Colors.white,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 2. Themes (Rounded Rectangles)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _ThemeOption(
                            color: Colors.white,
                            textColor: Colors.black,
                            isSelected: prefs.pageColor == Colors.white,
                            onTap: () => prefsController.applyTheme(
                              ReadingPreferences.defaultPreferences().copyWith(
                                pageColor: Colors.white,
                                textColor: Colors.black,
                              ),
                            ),
                          ),
                          _ThemeOption(
                            color: const Color(0xFFF5E6D3), // Sepia
                            textColor: const Color(0xFF5F4B32),
                            isSelected:
                                prefs.pageColor == const Color(0xFFF5E6D3),
                            onTap: () => prefsController.applyTheme(
                              ReadingPreferences.defaultPreferences().copyWith(
                                pageColor: const Color(0xFFF5E6D3),
                                textColor: const Color(0xFF5F4B32),
                              ),
                            ),
                          ),
                          _ThemeOption(
                            color: const Color(0xFF333333), // Dark Gray
                            textColor: Colors.white70,
                            isSelected:
                                prefs.pageColor == const Color(0xFF333333),
                            onTap: () => prefsController.applyTheme(
                              ReadingPreferences.defaultPreferences().copyWith(
                                pageColor: const Color(0xFF333333),
                                textColor: Colors.white70,
                              ),
                            ),
                          ),
                          _ThemeOption(
                            color: Colors.black,
                            textColor: Colors.grey,
                            isSelected: prefs.pageColor == Colors.black,
                            onTap: () => prefsController.applyTheme(
                              ReadingPreferences.defaultPreferences().copyWith(
                                pageColor: Colors.black,
                                textColor: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 3. Font Size & Family
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        child: Column(
                          children: [
                            // Font Size
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () => prefsController.setFontSize(
                                    (prefs.fontSize - 2).clamp(12.0, 32.0),
                                  ),
                                  child: const Text(
                                    'A',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      '${prefs.fontSize.toInt()}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => prefsController.setFontSize(
                                    (prefs.fontSize + 2).clamp(12.0, 32.0),
                                  ),
                                  child: const Text(
                                    'A',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: Colors.white10, height: 32),
                            // Font Family
                            GestureDetector(
                              onTap: () {
                                // TODO: Show font picker bottom sheet or expand
                                // For now, just cycle or show simple list
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Font',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        prefs.fontFamily,
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 16,
                                          fontFamily: prefs.fontFamily,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.chevron_right,
                                        color: Colors.white54,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Simple Font List (Inline for now)
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 40,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: availableFonts
                                    .map(
                                      (font) => Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8.0,
                                        ),
                                        child: ChoiceChip(
                                          label: Text(
                                            font,
                                            style: TextStyle(fontFamily: font),
                                          ),
                                          selected: prefs.fontFamily == font,
                                          onSelected: (_) => prefsController
                                              .setFontFamily(font),
                                          selectedColor: Colors.white24,
                                          backgroundColor: Colors.transparent,
                                          labelStyle: TextStyle(
                                            color: prefs.fontFamily == font
                                                ? Colors.white
                                                : Colors.white54,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            side: BorderSide(
                                              color: prefs.fontFamily == font
                                                  ? Colors.transparent
                                                  : Colors.white24,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 4. Scroll vs Page
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            Expanded(
                              child: _ViewModeButton(
                                icon: Icons.swipe,
                                label: 'Page',
                                isSelected:
                                    prefs.pageTurnStyle == PageTurnStyle.paged,
                                onTap: () => prefsController.setPageTurnStyle(
                                  PageTurnStyle.paged,
                                ),
                              ),
                            ),
                            Expanded(
                              child: _ViewModeButton(
                                icon: Icons.swap_vert,
                                label: 'Scroll',
                                isSelected:
                                    prefs.pageTurnStyle == PageTurnStyle.scroll,
                                onTap: () => prefsController.setPageTurnStyle(
                                  PageTurnStyle.scroll,
                                ),
                              ),
                            ),
                          ],
                        ),
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

class _ThemeOption extends StatelessWidget {
  final Color color;
  final Color textColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.color,
    required this.textColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: AppTheme.primaryGreen, width: 3)
              : Border.all(color: Colors.white24, width: 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.4),
                    blurRadius: 8,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            'Aa',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _ViewModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ViewModeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[800] : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white54,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
