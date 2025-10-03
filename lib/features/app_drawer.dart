import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/features/auth/presentation/auth_controller.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the auth state to get user information.
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    return Drawer(
      backgroundColor: AppTheme.darkGrey,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // A pre-styled header for displaying user info.
          UserAccountsDrawerHeader(
            accountName: Text(
              user?.displayName ?? 'Guest User',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.white),
            ),
            accountEmail: Text(user?.email ?? 'Sign in for full features'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppTheme.primaryGreen,
              child: Text(
                user?.displayName?.isNotEmpty == true ? user!.displayName![0].toUpperCase() : 'G',
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
          const Divider(color: AppTheme.grey),
          // Conditionally show Login or Logout based on auth state.

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.of(context).pop();
                ref.read(authControllerProvider.notifier).logout();
              },
            )
        ],
      ),
    );
  }
}