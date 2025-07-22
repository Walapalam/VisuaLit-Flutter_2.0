import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/api/appwrite_client.dart';
import 'package:visualit/core/services/sync_service.dart';

// This provider creates an instance of AuthRepository, making it available to other providers.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final account = ref.read(appwriteAccountProvider);
  final syncService = ref.read(syncServiceProvider);
  return AuthRepository(account: account, syncService: syncService);
});

/// AuthRepository handles all authentication-related communication with Appwrite.
class AuthRepository {
  final Account _account;
  final SyncService _syncService;

  AuthRepository({required Account account, required SyncService syncService}) 
      : _account = account, 
        _syncService = syncService;

  /// Fetches the currently logged-in user account.
  Future<models.User?> getCurrentUser() async {
    try {
      final user = await _account.get();

      // Initialize synchronization for the user if they are logged in
      if (user != null) {
        _syncService.initializeSync(user.$id);
      }

      return user;
    } on AppwriteException {
      // If there's no session or an error, there is no current user.
      // Clean up any existing synchronization
      _syncService.cleanupSync();
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

      // Initialize synchronization for the user
      final user = await _account.get();
      _syncService.initializeSync(user.$id);

      // Update user ID in local data
      await _syncService.updateUserIdInLocalData(user.$id);

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

      // After creating the user, we need to log them in to initialize sync
      await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      // Initialize synchronization for the user
      _syncService.initializeSync(user.$id);

      // Update user ID in local data
      await _syncService.updateUserIdInLocalData(user.$id);

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
      // Clean up synchronization before logging out
      _syncService.cleanupSync();

      await _account.deleteSession(sessionId: 'current');
    } on AppwriteException catch (e) {
      throw Exception('Failed to logout: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> createAnonymousSession() async {
    try {
      // Clean up any existing synchronization
      _syncService.cleanupSync();

      await _account.createAnonymousSession();

      // Anonymous users don't have synchronization
    } on AppwriteException catch (e) {
      throw Exception('Failed to create guest session: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
