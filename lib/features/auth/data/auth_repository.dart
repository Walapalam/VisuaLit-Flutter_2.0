import 'package:firebase_auth/firebase_auth.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:visualit/core/api/appwrite_client.dart';
import 'package:flutter/foundation.dart'; // Add this import for debugPrint


final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseAuth = ref.read(firebaseAuthProvider);
  final appwriteAccount = ref.read(appwriteAccountProvider);
  return AuthRepository(
    firebaseAuth: firebaseAuth,
    appwriteAccount: appwriteAccount,
  );
});

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final Account _appwriteAccount;

  AuthRepository({
    required FirebaseAuth firebaseAuth,
    required Account appwriteAccount,
  })  : _firebaseAuth = firebaseAuth,
        _appwriteAccount = appwriteAccount;

  Future<User?> getCurrentUser() async {
    return _firebaseAuth.currentUser;
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    debugPrint("Auth repository: Attempting login for: $email");
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint("Auth repository: Login successful for user: ${result.user?.uid}");
      return result;
    } catch (e) {
      debugPrint("Auth repository: Login error: $e");
      rethrow;
    }
  }

  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    // Create Firebase account
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update Firebase user profile with name
    await userCredential.user?.updateDisplayName(name);

    return userCredential;
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  Future<UserCredential> signInAnonymously() async {
    return await _firebaseAuth.signInAnonymously();
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Sign in to Firebase with the Google credential
    return await _firebaseAuth.signInWithCredential(credential);
  }

  // Helper method to get Appwrite token if needed for storage operations
  Future<String?> getAppwriteToken() async {
    try {
      // For Appwrite storage access, we can use API keys or JWT tokens
      // instead of trying to create sessions with user IDs

      // Option 1: Create an anonymous session
      final session = await _appwriteAccount.createAnonymousSession();
      return session.$id;

      // Option 2: If you have API keys configured:
      // return "your-api-key"; // Replace with actual API key for storage
    } catch (e) {
      return null;
    }
  }
}