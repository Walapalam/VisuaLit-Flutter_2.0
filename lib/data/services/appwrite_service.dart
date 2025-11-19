import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:visualit/data/models/book.dart'; // This is your Appwrite Book model
import 'package:visualit/data/models/chapter.dart';
import 'package:visualit/data/models/generated_visual.dart';
import 'package:visualit/core/api/appwrite_client.dart';
import 'dart:convert'; // For jsonEncode
import 'dart:async'; // For TimeoutException
import 'package:http/http.dart' as http; // For making HTTP requests
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
// You can find these in your Appwrite Console under Project Settings, Databases, and Storage.// e.g., 'https://cloud.appwrite.io/v1'
  // Add these at the top of your AppwriteService class
  static const String APPWRITE_ENDPOINT = 'https://nyc.cloud.appwrite.io/v1';
  static const String APPWRITE_PROJECT_ID = '6860a42f00029d56e718';
  static const String _databaseId = '6877ec0a003d7d8fdc69'; // e.g., '669d2c20000a9437b752'
  static const String _booksCollectionId = 'books'; // e.g., '669d2d88001e3b5e4063'
  static const String _chaptersCollectionId = 'chapters'; // e.g., '669d2d88001e3b5e4063'
  static const String _generatedVisualsCollectionId = 'generated_visuals'; // e.g., '669d2d88001e3b5e4063'
  static const String _storageBucketId = '6877d3f9001285376da6'; // e.g., '669d2d88001e3b5e4063'
// -------------------------------------------------------------------------

  // NEW: FastAPI Backend Endpoint for triggering generation
  // Set to http://localhost:8080/parse/parse/initiate as per your instruction.
  static const String _fastApiGenerateVisualsEndpoint = 'https://fastapi-backend-714527045715.asia-southeast1.run.app/parse/parse/initiate';

  Future<Book?> getBookByTitle(String title) async {
    print('📚 DEBUG: Attempting to fetch book by title: "$title"');
    try {
      final appwrite_models.DocumentList response = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _booksCollectionId,
        queries: [
          Query.equal('title', title),
          Query.limit(1),
        ],
      );
      print('📚 DEBUG: Book search result - Found: ${response.documents.isNotEmpty}');
      if (response.documents.isNotEmpty) {
        final book = Book.fromJson(response.documents.first.data);
        print('📚 DEBUG: Retrieved book - ID: ${book.id}, Title: ${book.title}');
        return book;
      }
      print('📚 DEBUG: No book found with title: "$title"');
      return null;
    } catch (e) {
      print('📚 DEBUG: Error finding book by title "$title": $e');
      throw Exception('Failed to find book by title "$title" from Appwrite: $e');
    }
  }

  Future<Book> getBook(String bookId) async {
    print('📚 DEBUG: Attempting to fetch book by ID: "$bookId"');
    try {
      final appwrite_models.Document response = await _databases.getDocument(
        databaseId: _databaseId,
        collectionId: _booksCollectionId,
        documentId: bookId,
      );
      final book = Book.fromJson(response.data);
      print('📚 DEBUG: Successfully retrieved book - ID: ${book.id}, Title: ${book.title}');
      return book;
    } catch (e) {
      print('📚 DEBUG: Error fetching book $bookId: $e');
      throw Exception('Failed to fetch book $bookId from Appwrite: $e');
    }
  }

  Future<List<Chapter>> getChaptersForBook(String bookId) async {
    print('📚 DEBUG: Fetching chapters for book ID: "$bookId"');
    try {
      print('📚 DEBUG: Requesting all chapters from database');
      final appwrite_models.DocumentList response = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _chaptersCollectionId,
      );
      print('📚 DEBUG: Retrieved ${response.documents.length} total chapters');

      final filteredChapters = response.documents
          .map((doc) => Chapter.fromJson(doc.data))
          .where((chapter) => chapter.bookId == bookId)
          .toList()
        ..sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));

      print('📚 DEBUG: Filtered to ${filteredChapters.length} chapters for book $bookId');
      print('📚 DEBUG: Chapter numbers: ${filteredChapters.map((c) => c.chapterNumber).join(", ")}');

      return filteredChapters;
    } catch (e) {
      print('📚 DEBUG: Error fetching chapters for book $bookId: $e');
      throw Exception('Failed to fetch chapters for Appwrite book $bookId: $e');
    }
  }

  Future<List<GeneratedVisual>> getGeneratedVisualsForChapters(List<String> chapterIds) async {
    print('📚 DEBUG: Fetching visuals for ${chapterIds.length} chapters');
    print('📚 DEBUG: Chapter IDs: ${chapterIds.join(", ")}');

    if (chapterIds.isEmpty) {
      print('📚 DEBUG: No chapter IDs provided, returning empty list');
      return [];
    }

    try {
      final appwrite_models.DocumentList response = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _generatedVisualsCollectionId,
        queries: [
          Query.equal('chapterId', chapterIds),
        ],
      );

      final visuals = response.documents.map((doc) => GeneratedVisual.fromJson(doc.data)).toList();
      print('📚 DEBUG: Retrieved ${visuals.length} visuals');
      print('📚 DEBUG: Visual IDs: ${visuals.map((v) => v.id).join(", ")}');

      return visuals;
    } catch (e) {
      print('📚 DEBUG: Error fetching generated visuals: $e');
      throw Exception('Failed to fetch generated visuals from Appwrite: $e');
    }
  }

  // Update this method in AppwriteService class
  String getImageUrl(String fileId) {
    print('📚 DEBUG: Generating URL for file ID: $fileId');

    // Construct the URL following the Appwrite format
    final url = '$APPWRITE_ENDPOINT/storage/buckets/$_storageBucketId/files/$fileId/view?project=$APPWRITE_PROJECT_ID&mode=admin';

    print('📚 DEBUG: Generated URL: $url');
    return url;
  }

  Future<Map<String, dynamic>> requestVisualGeneration({
    required String bookTitle,
    String? bookISBN,
    required int chapterNumber,
    required String chapterContent,
  }) async {
    print('📚 DEBUG: Starting visual generation request');
    print('📚 DEBUG: Parameters:');
    print('  - Book Title: $bookTitle');
    print('  - ISBN: ${bookISBN ?? "N/A"}');
    print('  - Chapter Number: $chapterNumber');
    print('  - Content Length: ${chapterContent.length} characters');
    print('📚 DEBUG: Sending request to: $_fastApiGenerateVisualsEndpoint');

    try {
      final response = await http.post(
        Uri.parse(_fastApiGenerateVisualsEndpoint),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'isbn': bookISBN ?? "",
          'book_title': bookTitle,
          'chapter_number': chapterNumber,
          'chapter_content': chapterContent,
        }),
      ).timeout(const Duration(seconds: 180)); // 3 minute timeout for long backend processing

      print('📚 DEBUG: Response received:');
      print('  - Status Code: ${response.statusCode}');
      print('  - Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('📚 DEBUG: Generation request successful');
        try {
          final responseData = jsonDecode(response.body) as Map<String, dynamic>;

          // Check if response indicates success
          if (responseData['status'] == 'success') {
            return {
              'success': true,
              'chapter_id': responseData['chapter_id'],
              'analysis': responseData['analysis'],
            };
          } else {
            // Backend returned 200 but with error status
            return {
              'success': false,
              'error': responseData['error'] ?? responseData['analysis']?['error'] ?? 'Unknown error occurred',
              'error_code': 'BACKEND_ERROR',
            };
          }
        } catch (e) {
          // Failed to parse JSON response
          print('📚 DEBUG: Failed to parse response JSON: $e');
          return {
            'success': false,
            'error': 'Invalid response format from backend',
            'error_code': 'PARSE_ERROR',
          };
        }
      } else if (response.statusCode == 400) {
        print('📚 DEBUG: Generation failed with status 400');
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          return {
            'success': false,
            'error': errorData['error'] ?? errorData['message'] ?? 'Bad request',
            'error_code': 'VALIDATION_ERROR',
          };
        } catch (e) {
          return {
            'success': false,
            'error': response.body.isNotEmpty ? response.body : 'Bad request error',
            'error_code': 'VALIDATION_ERROR',
          };
        }
      } else {
        print('📚 DEBUG: Unexpected status code: ${response.statusCode}');
        return {
          'success': false,
          'error': 'Unexpected error (Status ${response.statusCode}): ${response.body}',
          'error_code': 'HTTP_ERROR',
        };
      }
    } on TimeoutException {
      print('📚 DEBUG: Request timed out after 180 seconds');
      return {
        'success': false,
        'error': 'Request timed out after 3 minutes. The backend may still be processing.',
        'error_code': 'TIMEOUT',
      };
    } catch (e) {
      print('📚 DEBUG: Network/connection error: $e');
      return {
        'success': false,
        'error': 'Network error: $e',
        'error_code': 'NETWORK_ERROR',
      };
    }
  }
}