import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/custom_reader/presentation/reading_preferences_controller.dart';
import 'package:visualit/features/custom_reader/model/reading_preferences.dart';

/// A compact settings bar designed to mimic the look and feel of Apple Books' reading menu.
class CompactSettingsBar extends ConsumerWidget {
  final VoidCallback onShowAdvancedSettings;

  const CompactSettingsBar({
    super.key,
    required this.onShowAdvancedSettings,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(readingPreferencesProvider);
    final prefsController = ref.read(readingPreferencesProvider.notifier);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: CupertinoColors.systemGrey4.withOpacity(0.5),
              width: 0.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Brightness Slider
              _SettingsSlider(
                value: prefs.brightness,
                onChanged: prefsController.setBrightness,
                minIcon: CupertinoIcons.sun_min_fill,
                maxIcon: CupertinoIcons.sun_max_fill,
              ),
              const SizedBox(height: 12),

              // Font Size Slider
              _SettingsSlider(
                value: (prefs.fontSize - 12) / (32 - 12), // Normalize to 0-1 range
                onChanged: (value) {
                  // Denormalize back to font size
                  prefsController.setFontSize(12 + (value * (32 - 12)));
                },
                minIcon: CupertinoIcons.textformat_size,
                maxIcon: CupertinoIcons.textformat_size,
                minIconSize: 16,
                maxIconSize: 24,
              ),
              const SizedBox(height: 16),

              // Divider
              const Divider(color: CupertinoColors.systemGrey4, height: 1),
              const SizedBox(height: 16),

              // Theme Selector & Advanced Button Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ThemeButton(
                    theme: ReadingPreferences.light,
                    isSelected: prefs.pageColor == ReadingPreferences.light.pageColor,
                    onTap: () => prefsController.applyTheme(ReadingPreferences.light),
                  ),
                  _ThemeButton(
                    theme: ReadingPreferences.dark,
                    isSelected: prefs.pageColor == ReadingPreferences.dark.pageColor,
                    onTap: () => prefsController.applyTheme(ReadingPreferences.dark),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    color: CupertinoColors.systemGrey5,
                    onPressed: onShowAdvancedSettings,
                    borderRadius: BorderRadius.circular(8),
                    child: const Text('Advanced', style: TextStyle(color: CupertinoColors.label)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final IconData minIcon;
  final IconData maxIcon;
  final double minIconSize;
  final double maxIconSize;


  const _SettingsSlider({
    required this.value,
    required this.onChanged,
    required this.minIcon,
    required this.maxIcon,
    this.minIconSize = 20,
    this.maxIconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(minIcon, color: CupertinoColors.systemGrey, size: minIconSize),
        Expanded(
          child: CupertinoSlider(
            value: value.clamp(0.0, 1.0),
            onChanged: onChanged,
            activeColor: CupertinoColors.systemGrey,
            thumbColor: CupertinoColors.white,
          ),
        ),
        Icon(maxIcon, color: CupertinoColors.systemGrey, size: maxIconSize),
      ],
    );
  }
}

class _ThemeButton extends StatelessWidget {
  final ReadingPreferences theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeButton({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: theme.pageColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.systemGrey4,
            width: isSelected ? 3 : 1.5,
          ),
        ),
      ),
    );
  }
}

