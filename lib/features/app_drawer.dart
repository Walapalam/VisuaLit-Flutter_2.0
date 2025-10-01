import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/features/auth/presentation/auth_controller.dart';
import 'package:go_router/go_router.dart';

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
              // TODO: Navigate to leaderboards screenimport 'package:flutter/material.dart';
              // import 'package:flutter_riverpod/flutter_riverpod.dart';
              // import 'package:visualit/core/theme/app_theme.dart';
              // import 'package:visualit/features/auth/presentation/auth_controller.dart';
              // import 'package:go_router/go_router.dart';
              // import 'package:visualit/core/theme/app_theme.dart';
              //
              // class AppDrawer extends ConsumerWidget {
              //   const AppDrawer({super.key});
              //
              //   @override
              //   Widget build(BuildContext context, WidgetRef ref) {
              //     // Watch the auth state to get user information.
              //     final authState = ref.watch(authControllerProvider);
              //     final user = authState.user;
              //
              //     return Drawer(
              //       backgroundColor: AppTheme.darkGrey,
              //       child: ListView(
              //         padding: EdgeInsets.zero,
              //         children: [
              //           // A pre-styled header for displaying user info.
              //           UserAccountsDrawerHeader(
              //             accountName: Text(
              //               user?.name ?? 'Guest User',
              //               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.white),
              //             ),
              //             accountEmail: Text(user?.email ?? 'Sign in for full features'),
              //             decoration: const BoxDecoration(
              //               color: AppTheme.black,
              //             ),
              //             currentAccountPicture: CircleAvatar(
              //               backgroundColor: AppTheme.primaryGreen,
              //               child: Text(
              //                 user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'G',
              //                 style: const TextStyle(fontSize: 40.0, color: AppTheme.black),
              //               ),
              //             ),
              //           ),
              //           ListTile(
              //             leading: const Icon(Icons.person_outline),
              //             title: const Text('My Profile'),
              //             onTap: () {
              //               // TODO: Navigate to profile screen
              //             },
              //           ),
              //           ListTile(
              //             leading: const Icon(Icons.leaderboard_outlined),
              //             title: const Text('Leaderboards'),
              //             onTap: () {
              //               // TODO: Navigate to leaderboards screen
              //             },
              //           ),
              //           const Divider(color: AppTheme.grey),
              //           // Conditionally show Login or Logout based on auth state.
              //           if (authState.status == AuthStatus.authenticated)
              //             ListTile(
              //               leading: const Icon(Icons.logout),
              //               title: const Text('Logout'),
              //               onTap: () {
              //                 // Close the drawer first, then log out.
              //                 Navigator.of(context).pop();
              //                 ref.read(authControllerProvider.notifier).logout();
              //               },
              //             )
              //           else
              //             ListTile(
              //               leading: const Icon(Icons.login),
              //               title: const Text('Login'),
              //               onTap: () {
              //                 // This will be handled by the router redirect, just close the drawer.
              //                 Navigator.of(context).pop();
              //                 context.goNamed('login', extra: true);
              //               },
              //             ),
              //         ],
              //       ),
              //     );
              //   }
              // }
            },
          ),
          const Divider(color: AppTheme.grey),
          // Conditionally show Login or Logout based on auth state.
          if (authState.status == AuthStatus.authenticated || authState.status == AuthStatus.guest)
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

