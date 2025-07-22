import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/features/auth/presentation/auth_controller.dart';
import 'package:visualit/features/auth/presentation/login_screen.dart';
import 'package:visualit/features/auth/presentation/signup_screen.dart';
import 'package:visualit/features/auth/presentation/onboarding_screen.dart';
import 'package:visualit/features/home/presentation/home_screen.dart';
import 'package:visualit/features/library/presentation/library_controller.dart';
import 'package:visualit/features/library/presentation/new_library_screen.dart';
import 'package:visualit/features/reader/presentation/reading_screen.dart';
import 'package:visualit/features/scaffold.dart';
import 'package:visualit/main.dart';

import '../../features/auth/presentation/splash_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    debugLogDiagnostics: true,
    routes: [
      // Standalone routes (outside the shell)
      GoRoute(path: '/splash', name: 'splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', name: 'login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', name: 'signup', builder: (context, state) => const SignUpScreen()),
      GoRoute(path: '/onboarding', name: 'onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(
        path: '/reader/:bookId',
        name: 'reader',
        builder: (context, state) {
          final bookId = int.parse(state.pathParameters['bookId']!);
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
        ],
      ),
    ],
    redirect: (context, state) {
      final location = state.matchedLocation;
      final publicRoutes = ['/splash', '/onboarding', '/login', '/signup'];

      if (authState.status == AuthStatus.initial) {
        return '/splash';
      }

      if (authState.status == AuthStatus.authenticated) {
        if (publicRoutes.contains(location)) {
          return '/home';
        }
      }

      if (authState.status == AuthStatus.unauthenticated) {
        if (!publicRoutes.contains(location)) {
          return '/onboarding';
        }
      }

      return null;
    },
  );
});
