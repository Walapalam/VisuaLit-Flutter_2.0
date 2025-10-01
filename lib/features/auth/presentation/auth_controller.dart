import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/utils/error_parser.dart';
import 'package:visualit/features/auth/data/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authRepository);
});

enum AuthStatus { initial, loading, authenticated, guest, unauthenticated }

class AuthState {
  final AuthStatus status;
  final User? user; // Use Firebase User
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
        final status = (user.email?.isEmpty ?? true) ? AuthStatus.guest : AuthStatus.authenticated;
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
      await _authRepository.login(email: email, password: password);
      await initialize();
    } on AppwriteException catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: parseAppwriteException(e),
      );
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    _startLoading();
    try {
      await _authRepository.signUp(name: name, email: email, password: password);
      await login(email, password);
    } on AppwriteException catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: parseAppwriteException(e),
      );
    }
  }

  Future<void> logout() async {
    _startLoading();
    try {
      await _authRepository.logout();
      state = state.copyWith(status: AuthStatus.unauthenticated, clearUser: true);
    } on AppwriteException catch (e) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        errorMessage: parseAppwriteException(e),
      );
    }
  }

  Future<void> signInAsGuest() async {
    _startLoading();
    try {
      await _authRepository.createAnonymousSession();
      await initialize();
    } on AppwriteException catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: parseAppwriteException(e),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    _startLoading();
    try {
      await _authRepository.signInWithGoogle();
      await Future.delayed(const Duration(seconds: 1));
      await initialize();
    } on AppwriteException catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: parseAppwriteException(e),
      );
    }
  }
}