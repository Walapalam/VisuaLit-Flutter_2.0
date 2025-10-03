import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/features/audiobook_player/presentation/audiobooks_screen.dart';
import 'package:visualit/features/auth/presentation/auth_controller.dart';
import 'package:visualit/features/auth/presentation/login_screen.dart';
import 'package:visualit/features/auth/presentation/signup_screen.dart';
import 'package:visualit/features/auth/presentation/onboarding_screen.dart';
import 'package:visualit/features/auth/presentation/signup_screen.dart';
import 'package:visualit/features/auth/presentation/splash_screen.dart';
import 'package:visualit/features/home/presentation/home_screen.dart';
import 'package:visualit/features/library/presentation/library_screen.dart';
import 'package:visualit/features/scaffold.dart';
import 'package:visualit/features/settings/presentation/settings_screen.dart';
import 'package:visualit/features/settings/presentation/storage_settings_screen.dart';
import 'package:visualit/features/audiobook_player/presentation/audiobooks_screen.dart';
import 'package:visualit/features/reader/presentation/reading_screen.dart';
import 'package:visualit/features/audiobook_player/presentation/audiobook_player_screen.dart';
import 'package:visualit/main.dart';

import '../../features/audiobook_player/presentation/audiobook_player_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/reader/presentation/reading_screen.dart';
import 'package:visualit/features/marketplace/presentation/marketplace_screen.dart';
import 'package:visualit/features/Cart/presentation/CartScreen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/book/:bookId',
        name: 'bookReader',
        builder: (context, state) {
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
      GoRoute(
        path: '/storage-settings',
        name: 'storageSettings',
        builder: (context, state) => const StorageSettingsScreen(),
      ),
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) => const CartScreen(),
      ),

      // Main application shell route
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
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
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/marketplace', name: 'marketplace',
                builder: (context, state) => const MarketplaceScreen(),
              ),
            ],
          ),
          StatefulShellBranch(routes: [
            GoRoute(path: '/settings', name: 'settings', builder: (context, state) => const SettingsScreen()),
          ]),
        ],
      ),
    ],
    redirect: (context, state) {
      final status = authState.status;
      final location = state.matchedLocation;
      final publicRoutes = ['/splash', '/onboarding', '/login', '/signup'];
      final hasError = authState.errorMessage != null;


      // For debugging
      debugPrint('AUTH STATUS: $status, LOCATION: $location');

      // Stay on splash while loading
      if (status == AuthStatus.initial || status == AuthStatus.loading) {
        return location == '/splash' ? null : '/splash';
      }

      // IMPORTANT: Check error condition BEFORE checking unauthenticated status
      // Don't redirect during auth attempts with errors - this must come first
      if ((location == '/login' || location == '/signup') &&
          hasError &&
          status == AuthStatus.unauthenticated) {
        debugPrint('Staying on login/signup due to auth error');
        return null; // Stay on current page when there's an auth error
      }

      // Authenticated users should go to home if on public routes
      if ((status == AuthStatus.authenticated || status == AuthStatus.guest) &&
          publicRoutes.contains(location)) {
        return '/home';
      }

      // Unauthenticated users should go to onboarding if not on public routes
      if (status == AuthStatus.unauthenticated &&
          !publicRoutes.contains(location)) {
        return '/onboarding';
      }

      // From splash, redirect based on auth status
      if (location == '/splash' && status != AuthStatus.initial && status != AuthStatus.loading) {
        if (status == AuthStatus.unauthenticated) {
          return '/onboarding';
        } else {
          return '/home';
        }
      }

      // No redirect needed
      return null;
    },
  );
});