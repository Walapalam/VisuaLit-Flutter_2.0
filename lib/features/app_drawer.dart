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

    return Drawer(
      backgroundColor: AppTheme.darkGrey,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              user?.name ?? 'Guest User',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.white),
            ),
            accountEmail: Text(user?.email ?? 'Sign in for full features'),
            decoration: const BoxDecoration(
              color: AppTheme.black,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppTheme.primaryGreen,
              child: Text(
                user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'G',
                style: const TextStyle(fontSize: 40.0, color: AppTheme.black),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('My Profile'),
            onTap: () {
              // TODO: Navigate to profile screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.leaderboard_outlined),
            title: const Text('Leaderboards'),
            onTap: () {
              // TODO: Navigate to leaderboards screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Navigator.of(context).pop(); // Close the drawer
              context.goNamed('settings'); // Navigate to the settings page
            },
          ),
          const Divider(color: AppTheme.grey),
          if (authState.status == AuthStatus.authenticated)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.of(context).pop();
                ref.read(authControllerProvider.notifier).logout();
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
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