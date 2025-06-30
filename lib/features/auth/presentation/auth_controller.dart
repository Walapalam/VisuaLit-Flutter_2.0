import 'package:appwrite/models.dart' as models;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/auth/data/auth_repository.dart';

// This StateNotifierProvider will be what our UI interacts with.
// It exposes the AuthController and its state (AuthState).
final authControllerProvider =
StateNotifierProvider<AuthController, AuthState>((ref) {
  // The controller depends on the repository to perform actions.
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authRepository);
});

// An enum to represent the different states of our authentication process.
enum AuthStatus { initial, loading, authenticated, guest, unauthenticated, error }

// A state class to hold our authentication status, user data, and any error messages.
class AuthState {
  final AuthStatus status;
  final models.User? user;
  final String? errorMessage;

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  // A helper method to create a copy of the state with updated values.
  AuthState copyWith({
    AuthStatus? status,
    models.User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// AuthController manages the business logic for authentication.
/// It extends StateNotifier, which is a Riverpod class for managing state.
class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthController({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthState()) {
    // When the controller is created, immediately check the user's auth status.
    _initializeAuthState();
  }

  /// Checks if a user is already logged in when the app starts.
  Future<void> checkCurrentUser() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> _initializeAuthState() async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  /// Attempts to log the user in.
  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _authRepository.login(email: email, password: password);
      final user = await _authRepository.getCurrentUser();
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  /// Attempts to sign the user up.
  Future<void> signUp(String name, String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _authRepository.signUp(name: name, email: email, password: password);
      // After signing up, log the user in to create a session.
      await login(email, password);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  /// Logs the user out.
  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _authRepository.logout();
      state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> signInAsGuest() async {
    // Save guest info locally if needed
    state = state.copyWith(status: AuthStatus.guest, user: null);
  }

  Future<void> signInWithGoogle() async {
    // TODO: Implement Google OAuth2 logic
    state = state.copyWith(status: AuthStatus.loading);
    try {
      // await _authRepository.signInWithGoogle();
      // final user = await _authRepository.getCurrentUser();
      // state = state.copyWith(status: AuthStatus.authenticated, user: user);
      throw UnimplementedError('Google sign-in not implemented yet.');
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> signInWithApple() async {
    // TODO: Implement Apple OAuth2 logic
    state = state.copyWith(status: AuthStatus.loading);
    try {
      // await _authRepository.signInWithApple();
      // final user = await _authRepository.getCurrentUser();
      // state = state.copyWith(status: AuthStatus.authenticated, user: user);
      throw UnimplementedError('Apple sign-in not implemented yet.');
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }
}
