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
        final status = (user.email?.isEmpty ?? true) ? AuthStatus.guest : AuthStatus.authenticated;
        log('[AuthController] User found, status: $status');
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

  Future<void> signUpWithoutStateUpdate(String name, String email, String password) async {
    log('[AuthController] signUpWithoutStateUpdate() called');
    await _authRepository.signUp(name: name, email: email, password: password);
  }

  Future<void> sendVerificationEmail() async {
    log('[AuthController] sendVerificationEmail() called');
    await _authRepository.sendEmailVerification();
  }

  Future<bool> checkEmailVerified() async {
    log('[AuthController] checkEmailVerified() called');
    return await _authRepository.checkEmailVerified();
  }

  Future<void> loginWithoutStateUpdate(String email, String password) async {
    log('[AuthController] loginWithoutStateUpdate() called');
    await _authRepository.login(email: email, password: password);
  }

  Future<bool> isUserEmailVerified() async {
    log('[AuthController] isUserEmailVerified() called');
    return await _authRepository.isUserEmailVerified();
  }

  void _startLoading() {
    log('[AuthController] _startLoading()');
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
  }

  Future<void> login(String email, String password) async {
    log('[AuthController] login() called with email: $email');
    _startLoading();
    try {
      await _authRepository.login(email: email, password: password);
      log('[AuthController] login() success');
      await initialize();
    } on FirebaseAuthException catch (e) {
      log('[AuthController] login() failed: $e');
      String message;
      if (e.code == 'wrong-password') {
        message = 'Incorrect password. Please try again.';
      } else if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else {
        message = e.message ?? 'Login failed. Please try again.';
      }
      state = state.copyWith(
        status: AuthStatus.invalidLogin,
        errorMessage: message,
      );
    } catch (e) {
      log('[AuthController] login() failed: $e');
      state = state.copyWith(
        status: AuthStatus.invalidLogin,
        errorMessage: 'Login failed. Please try again.',
      );
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    log('[AuthController] signUp() called with email: $email');
    _startLoading();
    try {
      await _authRepository.signUp(name: name, email: email, password: password);
      log('[AuthController] signUp() success, proceeding to login');
      await login(email, password);
    } on AppwriteException catch (e) {
      log('[AuthController] signUp() failed: $e');
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: parseAppwriteException(e),
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
    } on AppwriteException catch (e) {
      log('[AuthController] logout() failed: $e');
      state = state.copyWith(
        status: AuthStatus.authenticated,
        errorMessage: parseAppwriteException(e),
      );
    }
  }

  Future<void> signInAsGuest() async {
    log('[AuthController] signInAsGuest() called');
    _startLoading();
    final isOnline = _ref.read(isOnlineProvider);
    log('[AuthController] isOnline: $isOnline');
    if (isOnline) {
      try {
        await _authRepository.createAnonymousSession();
        log('[AuthController] createAnonymousSession() success');
        await initialize();
      } catch (e) {
        log('[AuthController] createAnonymousSession() failed: $e');
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Failed to sign in as guest',
        );
      }
    } else {
      log('[AuthController] Offline guest mode');
      state = state.copyWith(status: AuthStatus.offlineGuest, user: null);
    }
  }

  Future<void> signInWithGoogle() async {
    log('[AuthController] signInWithGoogle() called');
    _startLoading();
    try {
      await _authRepository.signInWithGoogle();
      log('[AuthController] signInWithGoogle() success');
      await initialize();
    } on FirebaseAuthException catch (e) {
      log('[AuthController] signInWithGoogle() failed: $e');
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.message ?? 'Google sign-in failed',
      );
    } catch (e) {
      log('[AuthController] signInWithGoogle() failed: $e');
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
    }
  }
}