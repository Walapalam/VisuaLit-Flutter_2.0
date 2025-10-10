import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/features/auth/presentation/auth_controller.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface, // ✅ Theme-aware
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: colorScheme.primary, // ✅ Adapts to theme
            ),
            accountName: Text(
              user?.displayName ?? 'Guest User',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: colorScheme.onPrimary, // ✅ Contrast color
              ),
            ),
            accountEmail: Text(
              user?.email ?? 'Sign in for full features',
              style: TextStyle(color: colorScheme.onPrimary), // ✅ Contrast color
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppTheme.primaryGreen,
              child: Text(
                user?.displayName?.isNotEmpty == true
                    ? user!.displayName![0].toUpperCase()
                    : 'G',
                style: const TextStyle(fontSize: 40.0, color: AppTheme.black),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person_outline, color: colorScheme.onSurface),
            title: Text('My Profile', style: TextStyle(color: colorScheme.onSurface)),
            onTap: () {
              // TODO: Navigate to profile screen
            },
          ),
          ListTile(
            leading: Icon(Icons.leaderboard_outlined, color: colorScheme.onSurface),
            title: Text('Leaderboards', style: TextStyle(color: colorScheme.onSurface)),
            onTap: () {
              // TODO: Navigate to leaderboards screen
            },
          ),
          Divider(color: colorScheme.onSurface.withOpacity(0.2)),
          if (authState.status == AuthStatus.authenticated || authState.status == AuthStatus.guest)
            ListTile(
              leading: Icon(Icons.logout, color: colorScheme.onSurface),
              title: Text('Logout', style: TextStyle(color: colorScheme.onSurface)),
              onTap: () {
                Navigator.of(context).pop();
                ref.read(authControllerProvider.notifier).logout();
              },
            )
          else
            ListTile(
              leading: Icon(Icons.login, color: colorScheme.onSurface),
              title: Text('Login', style: TextStyle(color: colorScheme.onSurface)),
              onTap: () {
                Navigator.of(context).pop();
                context.goNamed('login', extra: true);
              },
            ),
        ],
      ),
    );
  }
}

