import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:visualit/data/models/book.dart'; // Appwrite Book model
import 'package:visualit/data/models/chapter.dart'; // Appwrite Chapter model
import 'package:visualit/data/models/generated_visual.dart'; // Appwrite GeneratedVisual model
import 'package:visualit/core/api/appwrite_client.dart'; // Assumed to exist for Appwrite client setup
import 'dart:convert'; // For jsonEncode
import 'package:http/http.dart' as http; // For making HTTP requests to backend
import 'package:flutter/foundation.dart'; // For debugPrint

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
  // FastAPI Backend Endpoint for triggering generation
  // This is set to http://localhost:8080/parse/parse/initiate as per your instruction.
  static const String _fastApiGenerateVisualsEndpoint = 'http://localhost:8080/parse/parse/initiate';

  // Fetches a single book from Appwrite by its title. Returns null if not found.
  Future<Book?> getBookByTitle(String title) async {
    try {
      final appwrite_models.DocumentList response = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _booksCollectionId,
        queries: [
          Query.equal('title', title), // Query by title
          Query.limit(1), // Expecting one unique book per title or first match
        ],
      );
      if (response.documents.isNotEmpty) {
        return Book.fromJson(response.documents.first.data);
      }
      return null; // Book not found
    } catch (e) {
      debugPrint('Error finding book by title "$title": $e');
      throw Exception('Failed to find book by title "$title" from Appwrite: $e');
    }
  }

  // Fetches a book from Appwrite by its Appwrite Document ID.
  Future<Book> getBook(String bookId) async {
    try {
      final appwrite_models.Document response = await _databases.getDocument(
        databaseId: _databaseId,
        collectionId: _booksCollectionId,
        documentId: bookId,
      );
      return Book.fromJson(response.data);
    } catch (e) {
      debugPrint('Error fetching book $bookId: $e');
      throw Exception('Failed to fetch book $bookId from Appwrite: $e');
    }
  }

  // Fetches chapters associated with a specific Appwrite Book ID.
  Future<List<Chapter>> getChaptersForBook(String bookId) async {
    try {
      final appwrite_models.DocumentList response = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _chaptersCollectionId,
        queries: [
          Query.equal('bookId', bookId), // Filter by the Appwrite Book ID
          Query.orderAsc('chapterNumber'), // Order by chapter number
        ],
      );
      return response.documents.map((doc) => Chapter.fromJson(doc.data)).toList();
    } catch (e) {
      debugPrint('Error fetching chapters for Appwrite book $bookId: $e');
      throw Exception('Failed to fetch chapters for Appwrite book $bookId: $e');
    }
  }

  // Fetches generated visuals for a list of chapter IDs.
  Future<List<GeneratedVisual>> getGeneratedVisualsForChapters(List<String> chapterIds) async {
    if (chapterIds.isEmpty) return [];
    try {
      final appwrite_models.DocumentList response = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _generatedVisualsCollectionId,
        queries: [
          Query.equal('chapterId', chapterIds), // Filter by multiple chapter IDs
        ],
      );
      return response.documents.map((doc) => GeneratedVisual.fromJson(doc.data)).toList();
    } catch (e) {
      debugPrint('Error fetching generated visuals: $e');
      throw Exception('Failed to fetch generated visuals from Appwrite: $e');
    }
  }

  // Gets a direct URL for an image file from Appwrite Storage.
  String getImageUrl(String fileId) {
    return _storage.getFileView(
      bucketId: _storageBucketId,
      fileId: fileId,
    ).toString();
  }

  // Sends a request to your backend's /parse/parse/initiate endpoint to trigger visual generation.
  Future<void> requestVisualGeneration({
    required String bookTitle,
    String? bookISBN,
    required int chapterNumber,
    required String chapterContent,
  }) async {
    debugPrint('Sending generation request for book: $bookTitle, ISBN: ${bookISBN ?? "N/A"}, '
        'Chapter: $chapterNumber to $_fastApiGenerateVisualsEndpoint');

    final response = await http.post(
      Uri.parse(_fastApiGenerateVisualsEndpoint),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        // Add any necessary authentication headers your FastAPI backend might require
      },
      body: jsonEncode(<String, dynamic>{ // Request body as per your backend API docs
        'isbn': bookISBN ?? "", // Send ISBN (empty string if null, as API expects string)
        'book_title': bookTitle,
        'chapter_number': chapterNumber,
        'chapter_content': chapterContent,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 202) {
      debugPrint('Generation request to backend successful: ${response.body}');
    } else {
      throw Exception('Failed to trigger visual generation from backend (${response.statusCode}): ${response.body}');
    }
  }
}