import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/core/providers/theme_provider.dart';
import 'package:visualit/features/auth/presentation/auth_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/features/widgets/drawer_header.dart' as custom;
import 'package:visualit/features/widgets/drawer_menu_item.dart';
import 'package:visualit/features/widgets/theme_toggle_item.dart';
import 'package:visualit/features/widgets/drawer_action_button.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Drawer(
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
          color: backgroundColor,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                // Header Section - Compact
                custom.AppDrawerHeader(
                  displayName: user?.displayName ?? 'Guest User',
                  email: user?.email ?? 'Sign in for full features',
                ),

                // Thin divider
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppTheme.primaryGreen.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Menu Items - Simpler design
                DrawerMenuItem(
                  icon: Icons.person_outline,
                  label: 'My Profile',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to profile screen
                  },
                ),
                const SizedBox(height: 8),
                DrawerMenuItem(
                  icon: Icons.leaderboard_outlined,
                  label: 'Leaderboards',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to leaderboards screen
                  },
                ),
                const SizedBox(height: 8),

                // Theme Toggle
                ThemeToggleItem(
                  isDark: isDark,
                  onToggle: () {
                    ref.read(themeControllerProvider.notifier).toggleTheme();
                  },
                ),

                const Spacer(),

                // Logout/Login Button - Cleaner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child:
                      authState.status == AuthStatus.authenticated ||
                          authState.status == AuthStatus.guest
                      ? DrawerActionButton(
                          icon: Icons.logout,
                          label: 'Logout',
                          onTap: () {
                            Navigator.of(context).pop();
                            ref.read(authControllerProvider.notifier).logout();
                          },
                        )
                      : DrawerActionButton(
                          icon: Icons.login,
                          label: 'Login',
                          onTap: () {
                            Navigator.of(context).pop();
                            context.goNamed('login', extra: true);
                          },
                        ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
