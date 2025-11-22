// lib/features/marketplace/data/marketplace_repository.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class MarketplaceRepository {
  static const baseUrl = 'https://gutendex.com/books';

  Future<Map<String, dynamic>> fetchBooks(String endpoint) async {
    try {
      final response = await http.get(Uri.parse(endpoint));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'results': data['results'], 'next': data['next']};
      } else {
        throw Exception('Failed to load books: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> fetchPopularBooks({int limit = 30}) async {
    return fetchBooks('$baseUrl?sort=popular');
  }

  Future<Map<String, dynamic>> fetchRecentBooks({int limit = 30}) async {
    return fetchBooks('$baseUrl?sort=descending');
  }

  Future<Map<String, dynamic>> fetchBooksByTopic(
    String topic, {
    int limit = 30,
  }) async {
    return fetchBooks('$baseUrl?topic=${Uri.encodeComponent(topic)}');
  }

  Future<Map<String, dynamic>> fetchAllBooks({int page = 1}) async {
    return fetchBooks('$baseUrl?page=$page');
  }

  Future<List<dynamic>> fetchBestsellers() async {
    List<dynamic> allBooks = [];
    String? nextUrl = '$baseUrl?sort=popular';

    for (int i = 0; i < 4 && nextUrl != null; i++) {
      try {
        final response = await http.get(Uri.parse(nextUrl));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          allBooks.addAll(data['results']);
          nextUrl = data['next'];
        } else {
          // Stop if there's an error
          break;
        }
      } catch (e) {
        // Stop on network error
        break;
      }
    }
    return allBooks;
  }
}
