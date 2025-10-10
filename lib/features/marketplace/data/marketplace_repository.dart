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
        return {
          'results': data['results'],
          'next': data['next'],
        };
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

  Future<Map<String, dynamic>> fetchBooksByTopic(String topic, {int limit = 30}) async {
    return fetchBooks('$baseUrl?topic=${Uri.encodeComponent(topic)}');
  }

  Future<Map<String, dynamic>> fetchAllBooks({int page = 1}) async {
    return fetchBooks('$baseUrl?page=$page');
  }
}
