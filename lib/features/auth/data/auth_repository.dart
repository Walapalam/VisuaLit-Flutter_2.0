import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:appwrite/enums.dart'; // Add this import
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/api/appwrite_client.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final account = ref.read(appwriteAccountProvider);
  return AuthRepository(account: account);
});

class AuthRepository {
  final Account _account;

  AuthRepository({required Account account}) : _account = account;

  Future<models.User?> getCurrentUser() async {
    try {
      return await _account.get();
    } on AppwriteException {
      return null;
    }
  }

  Future<models.Session> login({
    required String email,
    required String password,
  }) async {
    return await _account.createEmailPasswordSession(
      email: email,
      password: password,
    );
  }

  Future<models.User> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    return await _account.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: name,
    );
  }

  Future<void> logout() async {
    await _account.deleteSession(sessionId: 'current');
  }

  Future<models.Session> createAnonymousSession() async {
    return await _account.createAnonymousSession();
  }

  Future<void> signInWithGoogle() async {
    await _account.createOAuth2Session(
      provider: OAuthProvider.google, // Use enum instead of string
    );
  }
}