import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/features/audiobook_player/presentation/audiobooks_screen.dart';
import 'package:visualit/features/auth/presentation/auth_controller.dart';
import 'package:visualit/features/auth/presentation/login_screen.dart';
import 'package:visualit/features/auth/presentation/signup_screen.dart';
import 'package:visualit/features/auth/presentation/onboarding_screen.dart';
import 'package:visualit/features/home/presentation/home_screen.dart';
import 'package:visualit/features/library/presentation/library_screen.dart';
import 'package:visualit/features/reader/presentation/reading_screen.dart';
import 'package:visualit/features/scaffold.dart';
import 'package:visualit/features/settings/presentation/settings_screen.dart';

import 'package:visualit/main.dart';

import '../../features/auth/presentation/splash_screen.dart';
import '../models/book.dart';

// A GlobalKey is needed for the root navigator.
final _rootNavigatorKey = GlobalKey<NavigatorState>();

// This provider exposes the GoRouter instance to the app.
final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    // The initial location is now handled by the redirect logic.
    initialLocation: '/home',
    debugLogDiagnostics: true,
    routes: [
      // Standalone routes (outside the shell)
      GoRoute(path: '/splash', name: 'splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', name: 'login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', name: 'signup', builder: (context, state) => const SignUpScreen()),
      GoRoute(path: '/onboarding', name: 'onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(
        path: '/reader',
        name: 'reader',
        builder: (context, state) => ReadingScreen(
          book: state.extra as Book,
        ),
      ),
      // TODO: Add '/preferences' route here when built

      // Main application shell route
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // The MainShell widget now wraps all the main screens.
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // Each branch represents a tab with its own navigation stack.
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', name: 'home', builder: (context, state) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/library', name: 'library', builder: (context, state) => const LibraryScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/audio', name: 'audio', builder: (context, state) => const AudiobooksScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/settings', name: 'settings', builder: (context, state) => const SettingsScreen()),
          ]),
        ],
      ),
    ],
    // Corrected redirect logic for robust authentication flow.
    redirect: (context, state) {
      final location = state.matchedLocation;
      final publicRoutes = ['/splash', '/onboarding', '/login', '/signup'];

      // If auth state is still loading, stay on splash
      if (authState.status == AuthStatus.initial) {
        return '/splash';
      }

      // Handle authenticated users (including guests)
      if (authState.status == AuthStatus.authenticated || authState.status == AuthStatus.guest) {
        // If on public routes, redirect to home
        if (publicRoutes.contains(location)) {
          return '/home';
        }
        // Allow access to all other routes
        return null;
      }

      // If unauthenticated and trying to access protected route
      if (!publicRoutes.contains(location)) {
        return '/login';
      }

      return null;
    },
  );
});

