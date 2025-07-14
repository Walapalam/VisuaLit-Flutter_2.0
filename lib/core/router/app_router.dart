import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/features/audiobook_player/presentation/audiobook_player_screen.dart';
import 'package:visualit/features/audiobook_player/presentation/audiobooks_screen.dart';
import 'package:visualit/features/auth/presentation/auth_controller.dart';
import 'package:visualit/features/auth/presentation/login_screen.dart';
import 'package:visualit/features/auth/presentation/signup_screen.dart';
import 'package:visualit/features/auth/presentation/onboarding_screen.dart';
import 'package:visualit/features/home/presentation/home_screen.dart';
import 'package:visualit/features/library/presentation/library_screen.dart';
import 'package:visualit/features/scaffold.dart';
import 'package:visualit/features/settings/presentation/settings_screen.dart';
import 'package:visualit/main.dart';

import '../../features/auth/presentation/splash_screen.dart';
import '../../features/reader/presentation/reading_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    debugLogDiagnostics: true,
    routes: [
      // ... your routes remain the same
      GoRoute(path: '/splash', name: 'splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', name: 'login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', name: 'signup', builder: (context, state) => const SignUpScreen()),
      GoRoute(path: '/onboarding', name: 'onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/book/:bookId', name: 'bookReader', builder: (context, state) {
        final bookId = int.tryParse(state.pathParameters['bookId'] ?? '0') ?? 0;
        return ReadingScreen(bookId: bookId);
      },
      ),
      GoRoute(
        path: '/audiobook/:audiobookId',
        name: 'audiobookPlayer',
        builder: (context, state) {
          final audiobookId = int.tryParse(state.pathParameters['audiobookId'] ?? '0') ?? 0;
          return AudiobookPlayerScreen(audiobookId: audiobookId);
        },
      ),
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
            GoRoute(path: '/audio', name: 'audio', builder: (context, state) => const AudiobooksScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/settings', name: 'settings', builder: (context, state) => const SettingsScreen()),
          ]),
        ],
      ),
    ],
    redirect: (context, state) {
      final location = state.matchedLocation;
      final publicRoutes = ['/splash', '/onboarding', '/login', '/signup'];
      final isGoingToPublicRoute = publicRoutes.contains(location);
      final authStatus = authState.status;

      if (authStatus == AuthStatus.initial) {
        return '/splash';
      }

      // **THE FIX: Treat guest and authenticated users the same for routing.**
      final isLoggedIn = authStatus == AuthStatus.authenticated || authStatus == AuthStatus.guest;

      if (isLoggedIn) {
        // If the user is logged in (as guest or real user) and trying
        // to access a public-only page, send them to the home screen.
        if (isGoingToPublicRoute) {
          return '/home';
        }
      } else if (authStatus == AuthStatus.unauthenticated) {
        // If the user is not logged in and is trying to access a protected
        // page, send them to the onboarding screen.
        if (!isGoingToPublicRoute) {
          return '/onboarding';
        }
      }

      // In all other cases, no redirect is needed.
      return null;
    },
  );
});