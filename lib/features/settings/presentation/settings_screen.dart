import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/features/auth/presentation/auth_controller.dart';
import 'package:visualit/core/providers/font_providers.dart';
import 'package:visualit/core/services/sync_service.dart';
import 'package:visualit/core/theme/theme_controller.dart';
import 'package:visualit/shared_widgets/sync_status_indicator.dart';
import 'package:visualit/core/services/connectivity_provider.dart';
import 'package:visualit/features/settings/presentation/help_support.dart';
import 'package:visualit/features/settings/presentation/privacy_settings.dart';
import 'package:visualit/features/settings/presentation/account_settings_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final themeMode = ref.watch(themeControllerProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final selectedFont = ref.watch(selectedFontProvider);
    final fontSize = ref.watch(fontSizeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile Section with curved rectangle frame
              _buildProfileSection(context, user),

              const SizedBox(height: 24),

              // Settings Options
              _buildSettingsOptions(context, ref, isDarkMode, selectedFont, fontSize),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, dynamic user) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AccountSettingsScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Profile Picture Circle
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primaryContainer,
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: user?.photoURL != null
                        ? ClipOval(
                            child: Image.network(
                              user!.photoURL!,
                              width: 76,
                              height: 76,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.person,
                                  size: 40,
                                  color: theme.colorScheme.onPrimaryContainer,
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 40,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Name
                Text(
                  user?.displayName ?? user?.email ?? 'Guest User',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Subscription Plan
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        size: 16,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Free',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Edit Icon (Pencil) - Top Right Corner
            Positioned(
              top: 0,
              right: 0,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AccountSettingsScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.shadow.withOpacity(0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.edit,
                      size: 20,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsOptions(
    BuildContext context,
    WidgetRef ref,
    bool isDarkMode,
    String selectedFont,
    double fontSize
  ) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSettingTile(
            context: context,
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) {
                ref.read(themeControllerProvider.notifier).toggleTheme();
              },
            ),
          ),

          _buildDivider(theme),

          _buildSettingTile(
            context: context,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            trailing: Switch(
              value: true, // TODO: Connect to notification provider
              onChanged: (value) {
                // TODO: Implement notification toggle
              },
            ),
          ),

          _buildDivider(theme),

          _buildSettingTile(
            context: context,
            icon: Icons.font_download_outlined,
            title: 'Font Family',
            subtitle: selectedFont,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showFontFamilyDialog(context, ref, selectedFont),
          ),

          _buildDivider(theme),

          _buildSettingTile(
            context: context,
            icon: Icons.format_size,
            title: 'Font Size',
            subtitle: fontSize.toStringAsFixed(0),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showFontSizeDialog(context, ref, fontSize),
          ),

          _buildDivider(theme),

          _buildSettingTile(
            context: context,
            icon: Icons.sync,
            title: 'Sync Status',
            trailing: const SyncStatusIndicator(),
            onTap: () {},
          ),

          _buildDivider(theme),

          _buildSettingTile(
            context: context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Settings',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PrivacySettingsScreen(),
                ),
              );
            },
          ),

          _buildDivider(theme),

          _buildSettingTile(
            context: context,
            icon: Icons.help_outline,
            title: 'Help & Support',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HelpSupportScreen(),
                ),
              );
            },
          ),

          _buildDivider(theme),

          _buildSettingTile(
            context: context,
            icon: Icons.info_outline,
            title: 'About',
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAboutDialog(context),
          ),

          _buildDivider(theme),

          _buildSettingTile(
            context: context,
            icon: Icons.logout,
            title: 'Logout',
            titleColor: theme.colorScheme.error,
            iconColor: theme.colorScheme.error,
            onTap: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true && context.mounted) {
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? theme.colorScheme.onSurface,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: titleColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      endIndent: 16,
      color: theme.colorScheme.outline.withOpacity(0.2),
    );
  }

  void _showFontFamilyDialog(BuildContext context, WidgetRef ref, String currentFont) {
    final availableFonts = ['Roboto', 'OpenDyslexic', 'Atkinson Hyperlegible', 'Comic Sans'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Font Family'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: availableFonts.map((font) {
            return RadioListTile<String>(
              title: Text(font, style: TextStyle(fontFamily: font)),
              value: font,
              groupValue: currentFont,
              onChanged: (value) {
                if (value != null) {
                  ref.read(selectedFontProvider.notifier).state = value;
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showFontSizeDialog(BuildContext context, WidgetRef ref, double currentSize) {
    double tempSize = currentSize;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Font Size'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Preview Text',
                  style: TextStyle(fontSize: tempSize),
                ),
                const SizedBox(height: 16),
                Slider(
                  value: tempSize,
                  min: 12,
                  max: 24,
                  divisions: 12,
                  label: tempSize.round().toString(),
                  onChanged: (value) {
                    setState(() {
                      tempSize = value;
                    });
                  },
                ),
                Text('Size: ${tempSize.round()}'),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(fontSizeProvider.notifier).state = tempSize;
              Navigator.of(context).pop();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'VisuaLit',
      applicationVersion: '2.0.0',
      applicationIcon: const Icon(Icons.book, size: 48),
      children: [
        const Text('A visual learning and reading assistance application.'),
        const SizedBox(height: 16),
        const Text('Designed to help users with dyslexia and visual learning preferences.'),
      ],
    );
  }
}
