import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/providers/font_providers.dart';
import 'package:visualit/core/theme/theme_controller.dart';
import '../../../features/reader/presentation/reading_providers.dart' as reader_providers;

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);
    final fontSize = ref.watch(fontSizeProvider);
    final fontStyle = ref.watch(fontStyleProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preferences Section
            _buildSectionHeader(context, 'Preferences'),
            const SizedBox(height: 8),
            _buildSection(
              context,
              children: [
                _buildSettingItem(
                  context,
                  'Blocks per Page',
                  _buildBlocksPerPageDropdown(context, ref),
                ),
                _buildSettingItem(
                  context,
                  'Dark Mode',
                  Switch.adaptive(
                    value: isDarkMode,
                    onChanged: (_) => ref.read(themeControllerProvider.notifier).toggleTheme(),
                  ),
                ),
                const Divider(height: 1),
                _buildSettingItem(
                  context,
                  'Font Size',
                  _buildFontSizeDropdown(context, ref),
                ),
                const Divider(height: 1),
                _buildSettingItem(
                  context,
                  'Font Style',
                  _buildFontStyleDropdown(context, ref),
                ),
                const Divider(height: 1),
                _buildSettingItem(
                  context,
                  'Language',
                  _buildLanguageDropdown(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Account Section
            _buildSectionHeader(context, 'Account'),
            const SizedBox(height: 8),
            _buildSection(
              context,
              children: [
                _buildNavigationItem(
                  context,
                  'Account Settings',
                      () => Navigator.pushNamed(context, '/account-settings'),
                ),
                const Divider(height: 1),
                _buildNavigationItem(
                  context,
                  'Privacy Settings',
                      () => Navigator.pushNamed(context, '/privacy-settings'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // More Section
            _buildSectionHeader(context, 'More'),
            const SizedBox(height: 8),
            _buildSection(
              context,
              children: [
                _buildNavigationItem(
                  context,
                  'About',
                      () => Navigator.pushNamed(context, '/about'),
                ),
                const Divider(height: 1),
                _buildNavigationItem(
                  context,
                  'Help & Support',
                      () => Navigator.pushNamed(context, '/help-support'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeDropdown(BuildContext context, WidgetRef ref) {
    return DropdownButton<String>(
      value: ref.watch(fontSizeProvider),
      items: ['Small', 'Medium', 'Large'].map((size) {
        return DropdownMenuItem(value: size, child: Text(size));
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          ref.read(fontSizeProvider.notifier).setFontSize(value);
        }
      },
      underline: Container(),
    );
  }

  Widget _buildFontStyleDropdown(BuildContext context, WidgetRef ref) {
    return DropdownButton<String>(
      value: ref.watch(fontStyleProvider),
      items: FontStyleNotifier.fontStyleOptions.map((style) {
        return DropdownMenuItem(
          value: style,
          child: Text(style, style: TextStyle(fontFamily: style)),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          ref.read(fontStyleProvider.notifier).setFontStyle(value);
        }
      },
      underline: Container(),
    );
  }

  Widget _buildLanguageDropdown(BuildContext context) {
    return DropdownButton<String>(
      value: 'en',
      items: [
        DropdownMenuItem(value: 'en', child: Text('English')),
      ],
      onChanged: (_) {},
      underline: Container(),
    );
  }

  Widget _buildBlocksPerPageDropdown(BuildContext context, WidgetRef ref) {
    return DropdownButton<int>(
      value: ref.watch(reader_providers.readerSettingsProvider).blocksPerPage,
      items: [5, 10, 15, 20, 25].map((blocks) {
        return DropdownMenuItem(
          value: blocks,
          child: Text('$blocks blocks'),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          ref.read(reader_providers.readerSettingsProvider.notifier)
              .setBlocksPerPage(value);
        }
      },
      underline: Container(),
    );
  }

  Widget _buildNavigationItem(
      BuildContext context,
      String title,
      VoidCallback onTap,
      ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      title: Text(title),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isDarkMode ? Colors.white70 : Colors.black54,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      onTap: onTap,
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required List<Widget> children}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingItem(BuildContext context, String title, Widget trailing) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
    );
  }
}