import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:visualit/data/models/book.dart'; // This is your Appwrite Book model
import 'package:visualit/data/models/chapter.dart';
import 'package:visualit/data/models/generated_visual.dart';
import 'package:visualit/core/api/appwrite_client.dart';
import 'dart:convert'; // For jsonEncode
import 'package:http/http.dart' as http; // For making HTTP requests

final appwriteServiceProvider = Provider((ref) {
  final databases = ref.watch(appwriteDatabasesProvider);
  final storage = ref.watch(appwriteStorageProvider);
  return AppwriteService(databases: databases, storage: storage);
});

class AppwriteService {
  final Databases _databases;
  final Storage _storage;

  AppwriteService({required Databases databases, required Storage storage})
      : _databases = databases,
        _storage = storage;


// --- IMPORTANT: REPLACE THESE PLACEHOLDERS WITH YOUR ACTUAL APPWRITE IDs ---
// You can find these in your Appwrite Console under Project Settings, Databases, and Storage.
  static const String _databaseId = '6877ec0a003d7d8fdc69'; // e.g., '669d2c20000a9437b752'
  static const String _booksCollectionId = 'books'; // e.g., '669d2d88001e3b5e4063'
  static const String _chaptersCollectionId = 'chapters'; // e.g., '669d2d88001e3b5e4063'
  static const String _generatedVisualsCollectionId = 'generated_visuals'; // e.g., '669d2d88001e3b5e4063'
  static const String _storageBucketId = '6877d3f9001285376da6'; // e.g., '669d2d88001e3b5e4063'
// -------------------------------------------------------------------------

  // NEW: FastAPI Backend Endpoint for triggering generation
  // Set to http://localhost:8080/parse/parse/initiate as per your instruction.
  static const String _fastApiGenerateVisualsEndpoint = 'http://localhost:8080/parse/parse/initiate';

  Future<Book?> getBookByTitle(String title) async {
    try {
      final appwrite_models.DocumentList response = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _booksCollectionId,
        queries: [
          Query.equal('title', title),
          Query.limit(1),
        ],
      );
      if (response.documents.isNotEmpty) {
        return Book.fromJson(response.documents.first.data);
      }
      return null;
    } catch (e) {
      print('Error finding book by title "$title": $e');
      throw Exception('Failed to find book by title "$title" from Appwrite: $e');
    }
  }

  Future<Book> getBook(String bookId) async {
    try {
      final appwrite_models.Document response = await _databases.getDocument(
        databaseId: _databaseId,
        collectionId: _booksCollectionId,
        documentId: bookId,
      );
      return Book.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch book $bookId from Appwrite: $e');
    }
  }

  Future<List<Chapter>> getChaptersForBook(String bookId) async {
    try {
      final appwrite_models.DocumentList response = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _chaptersCollectionId,
        queries: [
          Query.equal('bookId', bookId),
          Query.orderAsc('chapterNumber'),
        ],
      );
      return response.documents.map((doc) => Chapter.fromJson(doc.data)).toList();
    } catch (e) {
      throw Exception('Failed to fetch chapters for Appwrite book $bookId: $e');
    }
  }

  Future<List<GeneratedVisual>> getGeneratedVisualsForChapters(List<String> chapterIds) async {
    if (chapterIds.isEmpty) return [];
    try {
      final appwrite_models.DocumentList response = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _generatedVisualsCollectionId,
        queries: [
          Query.equal('chapterId', chapterIds),
        ],
      );
      return response.documents.map((doc) => GeneratedVisual.fromJson(doc.data)).toList();
    } catch (e) {
      throw Exception('Failed to fetch generated visuals from Appwrite: $e');
    }
  }

  String getImageUrl(String fileId) {
    return _storage.getFileView(
      bucketId: _storageBucketId,
      fileId: fileId,
    ).toString();
  }

  // NEW METHOD: Send a request to your backend's /parse/parse/initiate endpoint
  // This now includes chapter content.
  Future<void> requestVisualGeneration({
    required String bookTitle,
    String? bookISBN,
    required int chapterNumber,
    required String chapterContent,
  }) async {
    print('Sending generation request for book: $bookTitle, ISBN: ${bookISBN ?? "N/A"}, '
        'Chapter: $chapterNumber to $_fastApiGenerateVisualsEndpoint');

    final response = await http.post(
      Uri.parse(_fastApiGenerateVisualsEndpoint),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        // Add any necessary authentication headers your FastAPI backend might require
      },
      body: jsonEncode(<String, dynamic>{ // Use dynamic for mixed types
        'isbn': bookISBN ?? "", // Send ISBN (empty string if null, as API expects string)
        'book_title': bookTitle,
        'chapter_number': chapterNumber,
        'chapter_content': chapterContent,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 202) { // 200 OK or 202 Accepted
      print('Generation request to backend successful: ${response.body}');
    } else {
      throw Exception('Failed to trigger visual generation from backend (${response.statusCode}): ${response.body}');
    }
  }
}