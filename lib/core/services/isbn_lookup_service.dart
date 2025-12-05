import 'dart:convert';
import 'package:http/http.dart' as http;

class IsbnLookupService {
  /// Enhanced ISBN lookup with multi-source fallback and validation
  /// Returns empty string if no valid ISBN found
  static Future<String> lookupIsbnByTitle(String title, String author) async {
    print('📚 ISBN Lookup: Starting for title="$title", author="$author"');

    // Strategy 1: Google Books API with title + author
    String? isbn = await _tryGoogleBooksWithAuthor(title, author);
    if (isbn != null && isbn.isNotEmpty) {
      print('📚 ISBN Lookup: Found via Google Books (title+author): $isbn');
      return isbn;
    }

    // Strategy 2: Google Books API with title only
    isbn = await _tryGoogleBooksWithTitle(title);
    if (isbn != null && isbn.isNotEmpty) {
      print('📚 ISBN Lookup: Found via Google Books (title only): $isbn');
      return isbn;
    }

    // Strategy 3: Open Library API fallback
    isbn = await _tryOpenLibrary(title, author);
    if (isbn != null && isbn.isNotEmpty) {
      print('📚 ISBN Lookup: Found via Open Library: $isbn');
      return isbn;
    }

    print('📚 ISBN Lookup: Failed - No valid ISBN found from any source');
    return '';
  }

  /// Try Google Books API with both title and author
  static Future<String?> _tryGoogleBooksWithAuthor(String title, String author) async {
    final cleanedTitle = _cleanTitle(title);
    final cleanedAuthor = _cleanTitle(author);
    final query = 'intitle:$cleanedTitle+inauthor:$cleanedAuthor';

    return await _queryGoogleBooks(query, 'title+author');
  }

  /// Try Google Books API with title only
  static Future<String?> _tryGoogleBooksWithTitle(String title) async {
    final cleanedTitle = _cleanTitle(title);
    final query = 'intitle:$cleanedTitle';

    return await _queryGoogleBooks(query, 'title');
  }

  /// Query Google Books API and extract ISBN
  static Future<String?> _queryGoogleBooks(String query, String strategy) async {
    final url = Uri.https(
      'www.googleapis.com',
      '/books/v1/volumes',
      {'q': query, 'maxResults': '5'}, // Increased to check multiple results
    );

    try {
      print('📚 ISBN Lookup: Querying Google Books ($strategy): $query');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['totalItems'] > 0 && data['items'] != null) {
          // Check first 5 results for valid ISBN
          for (var item in data['items']) {
            final volumeInfo = item['volumeInfo'];
            final identifiers = volumeInfo['industryIdentifiers'] ?? [];

            // Prefer ISBN-13 over ISBN-10
            for (var identifier in identifiers) {
              if (identifier['type'] == 'ISBN_13') {
                final isbn = identifier['identifier'] as String;
                if (_validateIsbn13Checksum(isbn)) {
                  return isbn;
                }
              }
            }

            // Fallback to ISBN-10 if no ISBN-13 found
            for (var identifier in identifiers) {
              if (identifier['type'] == 'ISBN_10') {
                return identifier['identifier'] as String;
              }
            }
          }
        }
      }
      print('📚 ISBN Lookup: Google Books ($strategy) - No results');
    } catch (e) {
      print('📚 ISBN Lookup: Google Books ($strategy) error: $e');
    }

    return null;
  }

  /// Try Open Library API as fallback
  static Future<String?> _tryOpenLibrary(String title, String author) async {
    final cleanedTitle = _cleanTitle(title);
    final cleanedAuthor = _cleanTitle(author);

    final url = Uri.https(
      'openlibrary.org',
      '/search.json',
      {
        'title': cleanedTitle,
        'author': cleanedAuthor,
        'fields': 'isbn',
        'limit': '5',
      },
    );

    try {
      print('📚 ISBN Lookup: Querying Open Library');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['docs'] != null && (data['docs'] as List).isNotEmpty) {
          for (var doc in data['docs']) {
            final isbns = doc['isbn'] as List?;
            if (isbns != null && isbns.isNotEmpty) {
              // Look for ISBN-13 first
              for (var isbn in isbns) {
                final isbnStr = isbn.toString().replaceAll('-', '');
                if (isbnStr.length == 13 && _validateIsbn13Checksum(isbnStr)) {
                  return isbnStr;
                }
              }
              // Fallback to any ISBN
              return isbns.first.toString().replaceAll('-', '');
            }
          }
        }
      }
      print('📚 ISBN Lookup: Open Library - No results');
    } catch (e) {
      print('📚 ISBN Lookup: Open Library error: $e');
    }

    return null;
  }

  /// Validate ISBN-13 using checksum algorithm
  /// ISBN-13 checksum: multiply alternating digits by 1 and 3, sum them,
  /// check if (10 - (sum % 10)) % 10 equals the check digit
  static bool _validateIsbn13Checksum(String isbn) {
    // Remove any hyphens or spaces
    final cleanIsbn = isbn.replaceAll(RegExp(r'[-\s]'), '');

    // Must be exactly 13 digits
    if (cleanIsbn.length != 13 || !RegExp(r'^\d{13}$').hasMatch(cleanIsbn)) {
      return false;
    }

    int sum = 0;
    for (int i = 0; i < 12; i++) {
      final digit = int.parse(cleanIsbn[i]);
      sum += (i % 2 == 0) ? digit : digit * 3;
    }

    final checkDigit = int.parse(cleanIsbn[12]);
    final calculatedCheckDigit = (10 - (sum % 10)) % 10;

    final isValid = checkDigit == calculatedCheckDigit;
    if (!isValid) {
      print('📚 ISBN Lookup: Invalid ISBN-13 checksum for $isbn');
    }

    return isValid;
  }

  static String _cleanTitle(String title) {
    return title.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }
}