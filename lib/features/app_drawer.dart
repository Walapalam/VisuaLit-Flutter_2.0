import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: AppTheme.darkGrey,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // A pre-styled header for displaying user info.
          const UserAccountsDrawerHeader(
            accountName: Text(
              'Guest User',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.white),
            ),
            accountEmail: Text('Welcome to VisuaLit'),
            decoration: BoxDecoration(
              color: AppTheme.black,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppTheme.primaryGreen,
              child: Text(
                'G',
                style: TextStyle(fontSize: 40.0, color: AppTheme.black),
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
        ],
      ),
    );
  }
}
