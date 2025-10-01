import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/api/appwrite_client.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseAuth = ref.read(firebaseAuthProvider);
  return AuthRepository(firebaseAuth: firebaseAuth);
});

class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepository({required FirebaseAuth firebaseAuth}) : _firebaseAuth = firebaseAuth;

  Future<User?> getCurrentUser() async {
    return _firebaseAuth.currentUser;
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Optionally update display name
    await credential.user?.updateDisplayName(name);
    return credential;
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  // Firebase does not support anonymous session in the same way, but you can use signInAnonymously
  Future<UserCredential> createAnonymousSession() async {
    return await _firebaseAuth.signInAnonymously();
  }

  // Google sign-in requires additional setup with google_sign_in package
  Future<UserCredential?> signInWithGoogle() async {
    // Implement using google_sign_in package
    // Placeholder for now
    throw UnimplementedError('Google sign-in not implemented');
  }
}
/*
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
 */