import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:visualit/shared_widgets/sync_status_indicator.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/theme_state.dart';
import 'account_settings_screen.dart';
import 'help_support.dart';
import 'notification_provider.dart';
import 'notification_screen.dart';
import 'privacy_settings.dart';
import 'storage_settings_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeControllerProvider);
    final isDarkMode = themeState.themeMode == ThemeMode.dark;
    final fontFamily = themeState.fontFamily;
    final fontSize = themeState.fontSize;
    final notificationsEnabled = ref.watch(notificationControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Header matching Library style
              Padding(
                padding: const EdgeInsets.only(bottom: 24, top: 8, left: 4),
                child: Text(
                  "Settings",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // ---------------------------------------------------
              // Profile Section
              //
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -12,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AccountSettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      width: double.infinity,
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            // You can use a NetworkImage or AssetImage for the profile picture
                            // backgroundImage: NetworkImage('URL_TO_YOUR_IMAGE'),
                            backgroundColor: Colors.black12,
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            "User Name",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- Section: Appearance & Accessibility ---
              _buildSectionHeader("Appearance & Accessibility"),
              _buildSettingsContainer(
                context,
                children: [
                  _tile(
                    context: context,
                    icon: Icons.dark_mode_outlined,
                    iconColor: Colors.deepPurple,
                    title: "Dark Mode",
                    trailing: Switch(
                      value: isDarkMode,
                      onChanged: (_) {
                        ref
                            .read(themeControllerProvider.notifier)
                            .toggleTheme();
                      },
                    ),
                  ),
                  _divider(context),
                  _tile(
                    context: context,
                    icon: Icons.font_download_outlined,
                    iconColor: Colors.blue,
                    title: "Font Family",
                    subtitle: fontFamily,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        _showFontFamilyDialog(context, ref, fontFamily),
                  ),
                  _divider(context),
                  _tile(
                    context: context,
                    icon: Icons.format_size,
                    iconColor: Colors.orange,
                    title: "Font Size",
                    subtitle: themeState.fontSizeLabel,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        _showFontSizeDialog(context, ref, themeState.fontSize),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- Section: App Controls & Data ---
              _buildSectionHeader("App Controls & Data"),
              _buildSettingsContainer(
                context,
                children: [
                  _tile(
                    context: context,
                    icon: Icons.notifications_outlined,
                    iconColor: Colors.pink,
                    title: "Notifications",
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                        ),
                      );
                    },
                  ),
                  _divider(context),
                  _tile(
                    context: context,
                    icon: Icons.sync,
                    iconColor: Colors.indigo,
                    title: "Sync Status",
                    trailing: const SyncStatusIndicator(),
                  ),
                  _divider(context),
                  _tile(
                    context: context,
                    icon: Icons.storage_outlined,
                    iconColor: Colors.blueGrey,
                    title: "Storage Settings",
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const StorageSettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- Section: Privacy, Support & Account ---
              _buildSectionHeader("Privacy, Support & Account"),
              _buildSettingsContainer(
                context,
                children: [
                  _tile(
                    context: context,
                    icon: Icons.privacy_tip_outlined,
                    iconColor: Colors.green,
                    title: "Privacy Settings",
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const PrivacySettingsScreen(),
                        ),
                      );
                    },
                  ),
                  _divider(context),
                  _tile(
                    context: context,
                    icon: Icons.help_outline,
                    iconColor: Colors.cyan,
                    title: "Help & Support",
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const HelpSupportScreen(),
                        ),
                      );
                    },
                  ),
                  _divider(context),
                  _tile(
                    context: context,
                    icon: Icons.logout_outlined,
                    iconColor: Colors.redAccent,
                    title: "Logout",
                    titleColor: Colors.redAccent,
                    onTap: () {
                      // TODO: Implement logout functionality
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const SizedBox(
        height: 80,
      ), // Add padding for bottom nav
    );
  }

  // ------------------ Reusable Widgets ------------------
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSettingsContainer(
    BuildContext context, {
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _tile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    Color? titleColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: iconColor?.withOpacity(0.15),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: titleColor ?? Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: trailing,
    );
  }

  Widget _divider(BuildContext context) {
    return Divider(
      height: 1,
      indent: 20,
      endIndent: 20,
      color: Theme.of(context).colorScheme.outline.withOpacity(0.15),
    );
  }

  // ------------------ Font Dialogs ------------------
  void _showFontFamilyDialog(
    BuildContext context,
    WidgetRef ref,
    String currentFont,
  ) {
    final fonts = ['Dyslexie', 'OpenDyslexie', 'Jersey20'];
    final isDarkMode =
        ref.read(themeControllerProvider).themeMode == ThemeMode.dark;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        title: const Text("Select Font Family"),
        content: SizedBox(
          width: double.minPositive,
          child: Theme(
            data: Theme.of(context).copyWith(
              radioTheme: RadioThemeData(
                fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.selected)) {
                    return const Color(
                      0xFF50C878,
                    ); // Inner circle color when selected
                  }
                  return isDarkMode
                      ? Colors.white
                      : Colors.black; // Outer circle color
                }),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: fonts.map((f) {
                return RadioListTile(
                  title: Text(f, style: TextStyle(fontFamily: f)),
                  value: f,
                  groupValue: currentFont,
                  onChanged: (value) {
                    Navigator.of(dialogContext).pop();

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (context.mounted) {
                        ref
                            .read(themeControllerProvider.notifier)
                            .setFontFamily(value!);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Color(0xFF50C878)),
            ),
          ),
        ],
      ),
    );
  }

  void _showFontSizeDialog(
    BuildContext context,
    WidgetRef ref,
    double currentSize,
  ) {
    final fontSizes = {
      'Small': ThemeState.fontSmall,
      'Medium': ThemeState.fontMedium,
      'Large': ThemeState.fontLarge,
    };
    final isDarkMode =
        ref.read(themeControllerProvider).themeMode == ThemeMode.dark;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        title: const Text("Select Font Size"),
        content: SizedBox(
          width: double.minPositive,
          child: Theme(
            data: Theme.of(context).copyWith(
              radioTheme: RadioThemeData(
                fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.selected)) {
                    return const Color(
                      0xFF50C878,
                    ); // Inner circle color when selected
                  }
                  return isDarkMode
                      ? Colors.white
                      : Colors.black; // Outer circle color
                }),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: fontSizes.entries.map((entry) {
                return RadioListTile<double>(
                  title: Text(
                    entry.key,
                    style: TextStyle(fontSize: entry.value),
                  ),
                  value: entry.value,
                  groupValue: currentSize,
                  onChanged: (value) {
                    // Close dialog immediately
                    Navigator.of(dialogContext).pop();

                    // Schedule state update after navigation completes
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (context.mounted) {
                        ref
                            .read(themeControllerProvider.notifier)
                            .setFontSize(value!);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Color(0xFF50C878)),
            ),
          ),
        ],
      ),
    );
  }
}
