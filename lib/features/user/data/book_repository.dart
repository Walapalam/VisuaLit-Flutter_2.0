import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/api/appwrite_client.dart';

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  final databases = ref.read(appwriteDatabasesProvider);
  final storage = ref.read(appwriteStorageProvider);
  return BookRepository(databases: databases, storage: storage);
});

class BookRepository {
  final Databases _databases;
  final Storage _storage;
  final String _databaseId = dotenv.env['APPWRITE_DATABASE_ID']!;
  final String _bucketId = dotenv.env['APPWRITE_BUCKET_ID']!;

  BookRepository({required Databases databases, required Storage storage})
      : _databases = databases,
        _storage = storage;

  Future<List<models.Document>> getMarketplaceBooks() async {
    try {
      final response = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'Books',
        queries: [
          Query.equal('is_in_marketplace', true),
        ],
      );
      return response.documents;
    } on AppwriteException catch (e) {
      throw Exception('Failed to get marketplace books: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<List<models.Document>> getGeneratedVisualizations(
      String bookId, int chapterNumber) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'GeneratedContent',
        queries: [
          Query.equal('bookId', bookId),
          Query.equal('chapterNumber', chapterNumber),
          Query.equal('contentType', 'visualization'),
        ],
      );
      return response.documents;
    } on AppwriteException catch (e) {
      throw Exception('Failed to get generated visualizations: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<models.Document?> getGeneratedAudiobook(
      String bookId, int chapterNumber) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'GeneratedContent',
        queries: [
          Query.equal('bookId', bookId),
          Query.equal('chapterNumber', chapterNumber),
          Query.equal('contentType', 'audiobook'),
        ],
      );
      return response.documents.isNotEmpty ? response.documents.first : null;
    } on AppwriteException catch (e) {
      throw Exception('Failed to get generated audiobook: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<Uint8List> downloadFile(String fileId) async {
    try {
      return await _storage.getFileDownload(
        bucketId: _bucketId,
        fileId: fileId,
      );
    } on AppwriteException catch (e) {
      throw Exception('Failed to download file: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}