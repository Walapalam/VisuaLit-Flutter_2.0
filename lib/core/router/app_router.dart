import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/features/home/presentation/home_screen.dart';
import 'package:visualit/features/library/presentation/library_screen.dart';
import 'package:visualit/features/scaffold.dart';
import 'package:visualit/features/settings/presentation/settings_screen.dart';
import 'package:visualit/main.dart';
import 'package:visualit/features/reader/presentation/reading_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    debugLogDiagnostics: true,
    routes: [
      // Standalone routes (outside the shell)
      GoRoute(path: '/book/:bookId', name: 'bookReader', builder: (context, state) {
        final bookId = int.tryParse(state.pathParameters['bookId'] ?? '0') ?? 0;
        return ReadingScreen(bookId: bookId);
      },
      ),
      // TODO: Add '/preferences' route here when built

      // Main application shell route
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', name: 'home', builder: (context, state) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/library', name: 'library', builder: (context, state) => const LibraryScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/settings', name: 'settings', builder: (context, state) => const SettingsScreen()),
          ]),
        ],
      ),
    ],
  );
});
