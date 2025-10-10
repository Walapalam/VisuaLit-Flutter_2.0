// lib/features/auth/data/auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

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
    await credential.user?.updateDisplayName(name);
    return credential;
  }

  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<bool> isUserEmailVerified() async {
    final user = _firebaseAuth.currentUser;
    return user?.emailVerified ?? false;
  }

  Future<bool> checkEmailVerified() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return false;
    await user.reload();
    return _firebaseAuth.currentUser?.emailVerified ?? false;
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  Future<UserCredential> createAnonymousSession() async {
    return await _firebaseAuth.signInAnonymously();
  }

  Future<UserCredential?> signInWithGoogle() async {
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