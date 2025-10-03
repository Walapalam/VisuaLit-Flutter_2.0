
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/utils/error_parser.dart';
import 'package:visualit/features/auth/data/auth_repository.dart';
import 'package:flutter/foundation.dart'; // Add this import for debugPrint


import 'dart:developer';
import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/utils/error_parser.dart';
import 'package:visualit/features/auth/data/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:visualit/core/services/connectivity_provider.dart';


final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authRepository, ref: ref);
});

enum AuthStatus { initial, loading, authenticated, guest, offlineGuest, unauthenticated, invalidLogin }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });


  AuthState copyWith({
    AuthStatus? status,
    User? user,
    bool clearUser = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}





class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthController({required AuthRepository authRepository, required Ref ref})
      : _authRepository = authRepository,
        _ref = ref,
        super(AuthState());

  Future<void> initialize() async {
    log('[AuthController] initialize() called');
    state = state.copyWith(status: AuthStatus.loading);
    final isOnline = _ref.read(isOnlineProvider);
    log('[AuthController] isOnline: $isOnline');

    if (!isOnline) {
      log('[AuthController] No internet, setting offlineGuest');
      state = state.copyWith(status: AuthStatus.offlineGuest, user: null);
      return;
    }

    try {
      final user = await _authRepository.getCurrentUser();
      log('[AuthController] getCurrentUser: $user');
      if (user != null) {
        final status = user.isAnonymous ? AuthStatus.guest : AuthStatus.authenticated;
        state = state.copyWith(status: status, user: user);
      } else {
        log('[AuthController] No user found, unauthenticated');
        state = state.copyWith(status: AuthStatus.unauthenticated, clearUser: true);
      }
    } catch (e) {
      log('[AuthController] Exception in initialize: $e');
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        errorMessage: 'Failed to initialize session',
      );
    }
  }

  void _startLoading() {
    log('[AuthController] _startLoading()');
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
  }

  Future<void> login(String email, String password) async {
    log('[AuthController] login() called with email: $email');
    _startLoading();
    try {
      final userCredential = await _authRepository.login(email: email, password: password);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: userCredential.user,
        errorMessage: null, // Clear any previous errors
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.code}');
      // Handle specific error codes
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email address.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid login credentials.';
          break;
        default:
          errorMessage = e.message ?? 'Authentication failed. Please try again.';
      }

      // IMPORTANT: Set both status and error message
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: errorMessage,
      );
    } catch (e) {
      debugPrint('Login error: $e');
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'An unexpected error occurred.',
      );
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    log('[AuthController] signUp() called with email: $email');
    _startLoading();
    try {
      debugPrint("Attempting signup for: $email");
      final userCredential = await _authRepository.signUp(name: name, email: email, password: password);
      debugPrint("Signup successful for user: ${userCredential.user?.uid}");

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: userCredential.user,
        clearError: true,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email address.';
          break;
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address.';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak. Please use a stronger password.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Account creation is disabled. Please contact support.';
          break;
        default:
          errorMessage = e.message ?? 'Registration failed. Please try again.';
      }

      debugPrint("Signup error: ${e.code} - $errorMessage");

      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: errorMessage,
      );
    } catch (e) {
      debugPrint("Unexpected signup error: $e");
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'An unexpected error occurred during registration.',
      );
    }
  }

  Future<void> logout() async {
    log('[AuthController] logout() called');
    _startLoading();
    try {
      await _authRepository.logout();
      log('[AuthController] logout() success');
      state = state.copyWith(status: AuthStatus.unauthenticated, clearUser: true);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to logout',
      );
    }
  }

  Future<void> signInAsGuest() async {
    log('[AuthController] signInAsGuest() called');
    _startLoading();
    try {
      final userCredential = await _authRepository.signInAnonymously();
      state = state.copyWith(
        status: AuthStatus.guest,
        user: userCredential.user,
      );
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.message ?? 'Anonymous sign-in failed',
      );
    }
  }

  Future<void> signInWithGoogle() async {
    log('[AuthController] signInWithGoogle() called');
    _startLoading();
    try {
      final userCredential = await _authRepository.signInWithGoogle();
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: userCredential.user,
      );
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.message ?? 'Google sign-in failed',
      );
    }
  }
}