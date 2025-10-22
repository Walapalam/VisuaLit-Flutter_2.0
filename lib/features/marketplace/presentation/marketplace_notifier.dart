// lib/features/marketplace/presentation/marketplace_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:isar/isar.dart';
import '../data/cached_book.dart';

class MarketplaceState {
  final List<dynamic> books;
  final String? nextUrl;
  final bool isLoading;
  final String searchQuery;
  final bool isLoadingFromCache;

  MarketplaceState({
    required this.books,
    required this.nextUrl,
    required this.isLoading,
    required this.searchQuery,
    this.isLoadingFromCache = false,
  });

  MarketplaceState copyWith({
    List<dynamic>? books,
    String? nextUrl,
    bool? isLoading,
    String? searchQuery,
    bool? isLoadingFromCache,
  }) {
    return MarketplaceState(
      books: books ?? this.books,
      nextUrl: nextUrl ?? this.nextUrl,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoadingFromCache: isLoadingFromCache ?? this.isLoadingFromCache,
    );
  }
}

class MarketplaceNotifier extends StateNotifier<MarketplaceState> {
  final Isar? _isar; // Already nullable from previous fix
  static const _cacheExpiry = Duration(hours: 24);

  MarketplaceNotifier(this._isar)
      : super(MarketplaceState(
    books: [],
    nextUrl: 'https://gutendex.com/books/',
    isLoading: false,
    searchQuery: '',
  )) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Only try cache if Isar is available
    if (_isar != null) {
      final cachedBooks = await _loadFromCache('');
      if (cachedBooks.isNotEmpty) {
        state = state.copyWith(
          books: cachedBooks,
          isLoadingFromCache: true,
        );
      }
    }
    // Always load fresh data from API
    await loadBooks(reset: true);
  }

  Future<List<dynamic>> _loadFromCache(String query) async {
    if (_isar == null) return [];

    final expiredDate = DateTime.now().subtract(_cacheExpiry);
    final cached = await _isar!.cachedBooks
        .where()
        .searchQueryEqualTo(query.isEmpty ? null : query)
        .filter()
        .cachedAtGreaterThan(expiredDate)
        .findAll();

    return cached.map((c) => json.decode(c.rawData)).toList();
  }

  Future<void> _saveToCache(List<dynamic> books, String query) async {
    if (_isar == null) return; // Skip caching if Isar not ready

    final now = DateTime.now();

    await _isar!.writeTxn(() async {
      // Clear old entries for this query
      await _isar!.cachedBooks
          .where()
          .searchQueryEqualTo(query.isEmpty ? null : query)
          .deleteAll();

      // Add new entries
      for (final book in books) {
        final cached = CachedBook()
          ..bookId = book['id']
          ..title = book['title'] ?? ''
          ..author = book['authors']?.isNotEmpty == true ? book['authors'][0]['name'] : null
          ..coverUrl = book['formats']?['image/jpeg']
          ..downloadUrl = book['formats']?['application/epub+zip']
          ..language = book['languages']?.isNotEmpty == true ? book['languages'][0] : null
          ..subjects = List<String>.from(book['subjects'] ?? [])
          ..cachedAt = now
          ..rawData = json.encode(book)
          ..searchQuery = query.isEmpty ? null : query
          ..downloadCount = book['download_count'] ?? 0
          ..isBestseller = (book['download_count'] ?? 0) > 10000;

        await _isar!.cachedBooks.put(cached);
      }
    });
  }


  Future<void> _clearOldCache() async {
    if (_isar == null) return;

    final expiredDate = DateTime.now().subtract(_cacheExpiry);
    await _isar!.writeTxn(() async {
      await _isar!.cachedBooks
          .where()
          .filter()
          .cachedAtLessThan(expiredDate)
          .deleteAll();
    });
  }

  Future<void> loadBooks({bool reset = false}) async {
    if (state.isLoading || state.nextUrl == null) return;

    state = state.copyWith(isLoading: true, isLoadingFromCache: false);

    final url = reset
        ? 'https://gutendex.com/books/?search=${Uri.encodeComponent(state.searchQuery)}'
        : state.nextUrl!;

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newBooks = List<dynamic>.from(data['results']);

        // Save to cache
        await _saveToCache(newBooks, state.searchQuery);

        // Clean old cache periodically
        if (reset) {
          await _clearOldCache();
        }

        state = state.copyWith(
          books: reset ? newBooks : [...state.books, ...newBooks],
          nextUrl: data['next'],
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, nextUrl: null);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false, nextUrl: null);
    }
  }

  void searchBooks(String query) async {
    // Try cache first
    final cachedBooks = await _loadFromCache(query);

    state = state.copyWith(
      searchQuery: query,
      nextUrl: 'https://gutendex.com/books/?search=${Uri.encodeComponent(query)}',
      books: cachedBooks,
      isLoadingFromCache: cachedBooks.isNotEmpty,
    );

    await loadBooks(reset: true);
  }

  Future<List<dynamic>> getBestsellers() async {
    if (_isar == null) return [];

    final books = await _isar!.cachedBooks
        .where()
        .filter()
        .isBestsellerEqualTo(true)
        .sortByDownloadCountDesc()
        .limit(20)
        .findAll();

    return books.map((b) => json.decode(b.rawData)).toList();
  }

  Future<List<dynamic>> getBooksBySubject(String subject) async {
    if (_isar == null) return [];

    final allBooks = await _isar!.cachedBooks.where().findAll();
    final filtered = allBooks.where((book) {
      return book.subjects?.any((s) => s.toLowerCase().contains(subject.toLowerCase())) ?? false;
    }).toList()
      ..sort((a, b) => b.downloadCount.compareTo(a.downloadCount));

    return filtered.map((b) => json.decode(b.rawData)).toList();
  }
}
