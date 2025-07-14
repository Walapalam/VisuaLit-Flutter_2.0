import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/api/appwrite_client.dart';

// This provider creates an instance of AuthRepository, making it available to other providers.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final account = ref.read(appwriteAccountProvider);
  return AuthRepository(account: account);
});

/// AuthRepository handles all authentication-related communication with Appwrite.
class AuthRepository {
  final Account _account;

  AuthRepository({required Account account}) : _account = account;

  /// Fetches the currently logged-in user account.
  Future<models.User?> getCurrentUser() async {
    try {
      return await _account.get();
    } on AppwriteException {
      // If there's no session or an error, there is no current user.
      return null;
    }
  }

  /// Logs in a user with their email and password.
  Future<models.Session> login({
    required String email,
    required String password,
  }) async {
    try {
      // **THE FIX: Delete any existing session (like guest) before logging in.**
      try {
        await _account.deleteSession(sessionId: 'current');
      } catch (_) {
        // Ignore errors if no session exists to be deleted.
      }

      // Now, create the new session with email and password.
      final session = await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      return session;
    } on AppwriteException catch (e) {
      // Provide a clearer error message for the user.
      throw Exception('Failed to login: ${e.message ?? "Invalid credentials or network issue."}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Creates a new user account.
  Future<models.User> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final user = await _account.create(
        userId: ID.unique(), // Let Appwrite generate a unique ID
        email: email,
        password: password,
        name: name,
      );
      return user;
    } on AppwriteException catch (e) {
      throw Exception('Failed to sign up: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Logs out the current user by deleting the current session.
  Future<void> logout() async {
    try {
      await _account.deleteSession(sessionId: 'current');
    } on AppwriteException catch (e) {
      throw Exception('Failed to logout: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Creates an anonymous session for guest users.
  Future<void> createAnonymousSession() async {
    try {
      await _account.createAnonymousSession();
    } on AppwriteException catch (e) {
      throw Exception('Failed to create guest session: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Initiates Google OAuth2 login.
  Future<void> signInWithGoogle() async {
    try {
      await _account.createOAuth2Session(provider: OAuthProvider.google);
    } on AppwriteException catch (e) {
      throw Exception('Failed to sign in with Google: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Initiates Apple OAuth2 login.
  Future<void> signInWithApple() async {
    try {
      await _account.createOAuth2Session(provider: OAuthProvider.apple);
    } on AppwriteException catch (e) {
      throw Exception('Failed to sign in with Apple: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}