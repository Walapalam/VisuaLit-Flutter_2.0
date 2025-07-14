import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/api/appwrite_client.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final databases = ref.read(appwriteDatabasesProvider);
  return UserRepository(databases: databases);
});

class UserRepository {
  final Databases _databases;
  final String _databaseId = dotenv.env['APPWRITE_DATABASE_ID']!;

  UserRepository({required Databases databases}) : _databases = databases;

  Future<int> getUserVisualizationQuota(String userId) async {
    try {
      final document = await _databases.getDocument(
        databaseId: _databaseId,
        collectionId: 'Users',
        documentId: userId,
      );
      return document.data['quota_visualizations'];
    } on AppwriteException catch (e) {
      throw Exception('Failed to get user visualization quota: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}