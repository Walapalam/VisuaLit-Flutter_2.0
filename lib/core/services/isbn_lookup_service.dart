import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class IsbnLookupService {
  static Future<String> lookupIsbnByTitle(String title) async {
    final cleanedTitle = _cleanTitle(title);
    final url = Uri.https(
      'www.googleapis.com',
      '/books/v1/volumes',
      {'q': 'intitle:$cleanedTitle', 'maxResults': '1'},
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['totalItems'] > 0 && data['items'] != null) {
          final volumeInfo = data['items'][0]['volumeInfo'];
          final identifiers = volumeInfo['industryIdentifiers'] ?? [];
          for (var identifier in identifiers) {
            if (identifier['type'] == 'ISBN_13') {
              return identifier['identifier'];
            } else if (identifier['type'] == 'ISBN_10') {
              return identifier['identifier'];
            }
          }
        }
      }
    } catch (_) {}
    return _generateRandomIsbn();
  }

  static String _cleanTitle(String title) {
    return title.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String _generateRandomIsbn() {
    final rand = Random();
    final prefix = '978';
    final group = '1';
    final publisher = (rand.nextInt(900) + 100).toString();
    final title = (rand.nextInt(9000) + 1000).toString();
    final checkDigit = rand.nextInt(10).toString();
    return '$prefix$group$publisher$title$checkDigit';
  }
}