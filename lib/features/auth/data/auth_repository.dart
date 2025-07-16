import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:appwrite/enums.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthRepository {
  final Client _client;
  late final Account _account;

  AuthRepository()
      : _client = Client()
      .setEndpoint(dotenv.env['APPWRITE_ENDPOINT'] ?? 'https://cloud.appwrite.io/v1')
      .setProject(dotenv.env['APPWRITE_PROJECT_ID'] ?? '')
      .setSelfSigned(status: true) {
    final endpoint = dotenv.env['APPWRITE_ENDPOINT'] ?? 'https://cloud.appwrite.io/v1';
    final projectId = dotenv.env['APPWRITE_PROJECT_ID'] ?? '';
    if (endpoint.isEmpty || projectId.isEmpty) {
      throw Exception('Missing APPWRITE_ENDPOINT or APPWRITE_PROJECT_ID in .env');
    }
    _account = Account(_client);
  }

  Future<models.User?> getCurrentUser() async {
    try {
      return await _account.get();
    } on AppwriteException catch (e) {
      if (e.code == 401) {
        return null; // No active session
      }
      rethrow;
    }
  }

  Future<void> login({required String email, required String password}) async {
    try {
      await _account.createEmailPasswordSession(email: email, password: password);
    } on AppwriteException catch (e) {
      throw AppwriteException(e.message, e.code, e.type);
    }
  }

  Future<void> signUp({required String name, required String email, required String password}) async {
    try {
      final userId = ID.unique();
      await _account.create(userId: userId, email: email, password: password, name: name);
    } on AppwriteException catch (e) {
      throw AppwriteException(e.message, e.code, e.type);
    }
  }

  Future<void> logout() async {
    try {
      await _account.deleteSession(sessionId: 'current');
    } on AppwriteException catch (e) {
      throw AppwriteException(e.message, e.code, e.type);
    }
  }

  Future<void> createAnonymousSession() async {
    try {
      await _account.createAnonymousSession();
    } on AppwriteException catch (e) {
      throw AppwriteException(e.message, e.code, e.type);
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await _account.createOAuth2Session(
        provider: OAuthProvider.google,
        success: 'visualit://auth-callback',
        failure: 'visualit://auth-failure',
      );
    } on AppwriteException catch (e) {
      throw AppwriteException(e.message, e.code, e.type);
    }
  }

  Future<void> requestPasswordReset({required String email}) async {
    try {
      await _account.createRecovery(
        email: email,
        url: 'visualit://reset-password',
      );
    } on AppwriteException catch (e) {
      throw AppwriteException(e.message, e.code, e.type);
    }
  }
}