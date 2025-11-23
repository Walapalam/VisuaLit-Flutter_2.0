import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/features/audiobook_player/presentation/audiobooks_screen.dart';
import 'package:visualit/features/auth/presentation/auth_controller.dart';
import 'package:visualit/features/auth/presentation/login_screen.dart';
import 'package:visualit/features/auth/presentation/signup_screen.dart';
import 'package:visualit/features/auth/presentation/welcome_screen.dart';
import 'package:visualit/features/auth/presentation/onboarding/onboarding_screen.dart'
    as onboarding;
import 'package:visualit/features/auth/application/onboarding_notifier.dart';
import 'package:visualit/features/auth/presentation/email_verification_screen.dart';
import 'package:visualit/features/auth/presentation/splash_screen.dart';
import 'package:visualit/features/home/presentation/home_screen.dart';
import 'package:visualit/features/library/presentation/library_screen.dart';
import 'package:visualit/features/scaffold.dart';
import 'package:visualit/features/settings/presentation/settings_screen.dart';
import 'package:visualit/features/settings/presentation/storage_settings_screen.dart';
import 'package:visualit/features/reader/presentation/old_reading_screen.dart';
import 'package:visualit/features/audiobook_player/presentation/audiobook_player_screen.dart';

import 'package:visualit/features/marketplace/presentation/marketplace_screen.dart';
import 'package:visualit/features/Cart/presentation/CartScreen.dart';
import 'package:visualit/features/custom_reader/presentation/reading_screen.dart'
    as custom_reader;
import 'package:visualit/features/marketplace/presentation/all_books_screen.dart';
import 'package:visualit/features/settings/presentation/account_settings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);
  final onboardingState = ref.watch(onboardingProvider);

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
        builder: (context, state) => const onboarding.OnboardingScreen(),
      ),
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
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
        path: '/email-verification',
        name: 'email_verification',
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return EmailVerificationScreen(email: email);
        },
      ),
      GoRoute(
        path: '/book/:bookId',
        name: 'bookReader',
        builder: (context, state) {
          final bookId =
              int.tryParse(state.pathParameters['bookId'] ?? '0') ?? 0;
          return ReadingScreen(bookId: bookId);
        },
      ),
      GoRoute(
        path: '/audiobook/:audiobookId',
        name: 'audiobookPlayer',
        builder: (context, state) {
          final audiobookId =
              int.tryParse(state.pathParameters['audiobookId'] ?? '0') ?? 0;
          return AudiobookPlayerScreen(audiobookId: audiobookId);
        },
      ),

      GoRoute(
        path: '/epub/:bookId',
        name: 'epubReader',
        builder: (context, state) {
          final bookId =
              int.tryParse(state.pathParameters['bookId'] ?? '0') ?? 0;
          return custom_reader.ReadingScreen(bookId: bookId);
        },
      ),
      GoRoute(
        path: '/all-books',
        name: 'allBooks',
        builder: (context, state) => const AllBooksScreen(),
      ),
      // TODO: Add '/preferences' route here when built

      // Main application shell route
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                name: 'library',
                builder: (context, state) => const LibraryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/audio',
                name: 'audio',
                builder: (context, state) => const AudiobooksScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/marketplace',
                name: 'marketplace',
                builder: (context, state) => const MarketplaceScreen(),
                routes: [
                  GoRoute(
                    path: 'cart',
                    name: 'cart',
                    builder: (context, state) => const CartScreen(),
                  ),
                ],
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'account',
                    name: 'accountSettings',
                    builder: (context, state) => const AccountSettingsScreen(),
                  ),
                  GoRoute(
                    path: 'storage',
                    name: 'storageSettings',
                    builder: (context, state) => const StorageSettingsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (context, state) async {
      final status = authState.status;
      final location = state.matchedLocation;
      final publicRoutes = [
        '/splash',
        '/onboarding',
        '/welcome',
        '/login',
        '/signup',
        '/email-verification',
      ];

      // Stay on splash until initialization is complete (including loading state)
      if ((status == AuthStatus.initial ||
              status == AuthStatus.loading ||
              onboardingState.isLoading) &&
          location != '/splash') {
        return '/splash';
      }

      /*
      // If authenticated or guest, redirect to home from public routes
      if ((status == AuthStatus.authenticated || status == AuthStatus.guest || status == AuthStatus.offlineGuest) &&
          publicRoutes.contains(location)) {
        return '/home';
      }*/

      // If invalidLogin, stay on /login
      if (status == AuthStatus.invalidLogin &&
          location != '/login' &&
          location != '/onboarding') {
        return '/login';
      }

      if ((status == AuthStatus.authenticated || status == AuthStatus.guest) &&
          publicRoutes.contains(location)) {
        return '/home';
      }

      // If unauthenticated and not on a public route, redirect to welcome or onboarding
      if (status == AuthStatus.unauthenticated &&
          !publicRoutes.contains(location)) {
        return onboardingState.hasSeenOnboarding ? '/welcome' : '/onboarding';
      }

      // If on splash and initialization is complete, redirect based on status
      if (location == '/splash' &&
          status != AuthStatus.initial &&
          status != AuthStatus.loading &&
          !onboardingState.isLoading) {
        if (status == AuthStatus.unauthenticated) {
          return onboardingState.hasSeenOnboarding ? '/welcome' : '/onboarding';
        }
        return '/home';
      }

      return null;
    },
  );
});
