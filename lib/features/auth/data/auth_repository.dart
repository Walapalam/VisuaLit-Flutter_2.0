import 'package:appwrite/appwrite.dart';
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
      final session = await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      return session;
    } on AppwriteException catch (e) {
      throw Exception('Failed to login: ${e.message}');
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

  Future<void> createAnonymousSession() async {
    try {
      await _account.createAnonymousSession();
    } on AppwriteException catch (e) {
      throw Exception('Failed to create guest session: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
