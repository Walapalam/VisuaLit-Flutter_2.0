// lib/features/marketplace/presentation/marketplace_notifier.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:visualit/features/marketplace/data/marketplace_repository.dart';
import '../data/cached_book.dart';

class MarketplaceState {
  final List<dynamic> books;
  final String? nextUrl;
  final bool isLoading;
  final String searchQuery;
  final bool isLoadingFromCache;
  final bool isInitialLoading;
  final bool isOffline;
  final String? errorMessage;
  final List<dynamic> bestsellers;
  final Map<String, List<dynamic>> categorizedBooks;

  MarketplaceState({
    required this.books,
    required this.nextUrl,
    required this.isLoading,
    required this.searchQuery,
    this.isLoadingFromCache = false,
    this.isInitialLoading = false,
    this.isOffline = false,
    this.errorMessage,
    this.bestsellers = const [],
    this.categorizedBooks = const {},
  });

  MarketplaceState copyWith({
    List<dynamic>? books,
    String? nextUrl,
    bool? isLoading,
    String? searchQuery,
    bool? isLoadingFromCache,
    bool? isInitialLoading,
    bool? isOffline,
    String? errorMessage,
    List<dynamic>? bestsellers,
    Map<String, List<dynamic>>? categorizedBooks,
  }) {
    return MarketplaceState(
      books: books ?? this.books,
      nextUrl: nextUrl ?? this.nextUrl,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoadingFromCache: isLoadingFromCache ?? this.isLoadingFromCache,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isOffline: isOffline ?? this.isOffline,
      errorMessage: errorMessage ?? this.errorMessage,
      bestsellers: bestsellers ?? this.bestsellers,
      categorizedBooks: categorizedBooks ?? this.categorizedBooks,
    );
  }
}

class MarketplaceNotifier extends StateNotifier<MarketplaceState> {
  final Isar? _isar;
  final MarketplaceRepository _repository;
  static const _cacheExpiry = Duration(hours: 24);

  MarketplaceNotifier(this._isar, this._repository)
      : super(MarketplaceState(
          books: [],
          nextUrl: 'https://gutendex.com/books/',
          isLoading: false,
          searchQuery: '',
          isInitialLoading: true,
        )) {
    _loadInitialData();
  }

  void retryInitialLoad() {
    state = state.copyWith(
      isInitialLoading: true,
      errorMessage: null,
      isOffline: false,
    );
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    debugPrint('Loading initial data...');
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOffline = connectivityResult == ConnectivityResult.none;

    if (_isar != null) {
      final cachedBestsellers = await _loadFromCache('bestsellers');
      final cachedFiction = await _loadFromCache('fiction');
      final cachedScience = await _loadFromCache('science');
      final cachedHistory = await _loadFromCache('history');
      final cachedPhilosophy = await _loadFromCache('philosophy');

      if (cachedBestsellers.isNotEmpty) {
        state = state.copyWith(
          bestsellers: cachedBestsellers,
          categorizedBooks: {
            'fiction': cachedFiction,
            'science': cachedScience,
            'history': cachedHistory,
            'philosophy': cachedPhilosophy,
          },
          isLoadingFromCache: true,
          isInitialLoading: false,
        );
        debugPrint('Loaded books from cache.');
      }
    }

    if (isOffline) {
      state = state.copyWith(
        isOffline: true,
        isInitialLoading: false,
        isLoading: false,
      );
      return;
    }

    try {
      await fetchAndCacheInitialData();
      final bestsellers = await _loadFromCache('bestsellers');
      final fiction = await _loadFromCache('fiction');
      final science = await _loadFromCache('science');
      final history = await _loadFromCache('history');
      final philosophy = await _loadFromCache('philosophy');

      state = state.copyWith(
        bestsellers: bestsellers,
        categorizedBooks: {
          'fiction': fiction,
          'science': science,
          'history': history,
          'philosophy': philosophy,
        },
        isInitialLoading: false,
        isLoading: false,
        isLoadingFromCache: false,
      );
      debugPrint('Finished loading and caching initial data.');
    } catch (e) {
      debugPrint('Error loading initial data: $e');
      state = state.copyWith(
        isInitialLoading: false,
        isLoading: false,
        errorMessage: 'Failed to load books. Please try again.',
      );
    }
  }

  Future<void> fetchAndCacheInitialData() async {
    // 1. Fetch Bestsellers
    final bestsellers = await _repository.fetchBestsellers();
    await _saveToCache(bestsellers, 'bestsellers');
    debugPrint('Fetched and cached ${bestsellers.length} bestsellers.');

    // 2. Fetch for each category
    final categories = ['fiction', 'science', 'history', 'philosophy'];
    for (final category in categories) {
      final categoryBooks = await _repository.fetchBooksByTopic(category);
      await _saveToCache(categoryBooks['results'], category);
      debugPrint('Fetched and cached ${categoryBooks['results'].length} books for $category.');
    }
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
    if (_isar == null) return;

    final now = DateTime.now();
    final newBookIds = books.map((b) => b['id'] as int).toSet();

    await _isar!.writeTxn(() async {
      // Efficiently delete old entries for this query that are not in the new list
      final oldEntries = await _isar!.cachedBooks
          .where()
          .searchQueryEqualTo(query)
          .filter()
          .not()
          .anyOf(newBookIds, (q, int id) => q.bookIdEqualTo(id))
          .findAll();
      if (oldEntries.isNotEmpty) {
        await _isar!.cachedBooks.deleteAll(oldEntries.map((e) => e.id).toList());
      }

      for (final book in books) {
        // Check if a book with the same ID and query already exists
        final existing = await _isar!.cachedBooks
            .where()
            .bookIdEqualTo(book['id'])
            .filter()
            .searchQueryEqualTo(query)
            .findFirst();

        if (existing == null) {
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
            ..isBestseller = query == 'bestsellers' || (book['download_count'] ?? 0) > 10000;
          await _isar!.cachedBooks.put(cached);
        }
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

}
