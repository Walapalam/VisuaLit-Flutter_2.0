
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/features/auth/presentation/auth_controller.dart';
import 'package:visualit/core/providers/font_providers.dart';
import 'package:visualit/core/theme/theme_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Log Out', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                ref.read(authControllerProvider.notifier).logout();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final themeMode = ref.watch(themeControllerProvider);
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
            // Account Section
            _buildSectionHeader(context, 'Account'),
            const SizedBox(height: 8),
            _buildSection(
              context,
              children: [
                if ((authState.status == AuthStatus.authenticated || authState.status == AuthStatus.guest) && user != null)
                  ..._buildAuthenticatedAccountItems(context, ref, user)
                else
                  _buildGuestAccountItem(context),
              ],
            ),

            const SizedBox(height: 24),

            // Preferences Section
            _buildSectionHeader(context, 'Preferences'),
            const SizedBox(height: 8),
            _buildSection(
              context,
              children: [
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

            // More Section
            _buildSectionHeader(context, 'More'),
            const SizedBox(height: 8),
            _buildSection(
              context,
              children: [
                _buildNavigationItem(
                  context,
                  'Notifications',
                  Icons.notifications_outlined,
                      () {
                    // TODO: Navigate to notification settings screen
                  },
                ),
                const Divider(height: 1),
                _buildNavigationItem(
                  context,
                  'Privacy Settings',
                  Icons.privacy_tip_outlined,
                      () => Navigator.pushNamed(context, '/privacy-settings'),
                ),
                const Divider(height: 1),
                _buildNavigationItem(
                  context,
                  'About',
                  Icons.info_outline,
                      () => Navigator.pushNamed(context, '/about'),
                ),
                const Divider(height: 1),
                _buildNavigationItem(
                  context,
                  'Help & Support',
                  Icons.help_outline,
                      () => Navigator.pushNamed(context, '/help-support'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAuthenticatedAccountItems(BuildContext context, WidgetRef ref, user) {
    return [
      ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(user.email),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      ),
      const Divider(height: 1),
      _buildNavigationItem(
        context,
        'Account Settings',
        Icons.manage_accounts_outlined,
            () => Navigator.pushNamed(context, '/account-settings'),
      ),
      const Divider(height: 1),
      ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text('Log Out', style: TextStyle(color: Colors.red)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        onTap: () => _showLogoutConfirmation(context, ref),
      ),
    ];
  }

  Widget _buildGuestAccountItem(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.no_accounts, color: Colors.grey),
      title: const Text('You are browsing as a guest'),
      subtitle: const Text('Log in to sync your data across devices'),
      trailing: TextButton(
        child: const Text('Sign In'),
        onPressed: () => context.goNamed('login'),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
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
      items: const [
        DropdownMenuItem(value: 'en', child: Text('English')),
      ],
      onChanged: (_) {},
      underline: Container(),
    );
  }

  Widget _buildNavigationItem(
      BuildContext context,
      String title,
      IconData icon,
      VoidCallback onTap,
      ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon),
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