import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/utils/error_parser.dart';
import 'package:visualit/features/auth/data/auth_repository.dart';
import 'package:flutter/foundation.dart'; // Add this import for debugPrint


final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authRepository);
});

enum AuthStatus { initial, loading, authenticated, guest, unauthenticated }

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

  AuthController({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthState());

  Future<void> initialize() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        final status = user.isAnonymous ? AuthStatus.guest : AuthStatus.authenticated;
        state = state.copyWith(status: status, user: user);
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated, clearUser: true);
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        errorMessage: 'Failed to initialize session',
      );
    }
  }

  void _startLoading() {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);
  }

  Future<void> login(String email, String password) async {
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
    _startLoading();
    try {
      await _authRepository.logout();
      state = state.copyWith(status: AuthStatus.unauthenticated, clearUser: true);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to logout',
      );
    }
  }

  Future<void> signInAsGuest() async {
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