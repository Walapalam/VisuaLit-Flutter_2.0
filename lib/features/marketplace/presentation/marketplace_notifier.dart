// lib/features/marketplace/presentation/marketplace_notifier.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:visualit/features/marketplace/data/marketplace_repository.dart';
import '../data/cached_book.dart';
import 'dart:math';

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
  final List<String> loadedCategories;

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
    this.loadedCategories = const [],
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
    List<String>? loadedCategories,
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
      loadedCategories: loadedCategories ?? this.loadedCategories,
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
      loadedCategories: [],
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
        // Build categorized map and dedupe/shuffle so the same book doesn't appear in multiple shelves
        final rawCategorized = {
          'bestsellers': List<dynamic>.from(cachedBestsellers),
          'fiction': List<dynamic>.from(cachedFiction),
          'science': List<dynamic>.from(cachedScience),
          'history': List<dynamic>.from(cachedHistory),
          'philosophy': List<dynamic>.from(cachedPhilosophy),
        };

        final shuffled = _dedupeAndShuffleCategorized(rawCategorized, ['bestsellers', 'fiction', 'science', 'history', 'philosophy']);

        final loaded = <String>[];
        shuffled.forEach((k, v) {
          if (v.isNotEmpty) loaded.add(k);
        });

        state = state.copyWith(
          bestsellers: shuffled['bestsellers']!,
          categorizedBooks: {
            'fiction': shuffled['fiction']!,
            'science': shuffled['science']!,
            'history': shuffled['history']!,
            'philosophy': shuffled['philosophy']!,
          },
          isLoadingFromCache: true,
          isInitialLoading: false,
          loadedCategories: loaded,
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

      // Final dedupe & shuffle across all categories before assigning
      final finalCategorized = _dedupeAndShuffleCategorized({
        'bestsellers': List<dynamic>.from(bestsellers),
        'fiction': List<dynamic>.from(fiction),
        'science': List<dynamic>.from(science),
        'history': List<dynamic>.from(history),
        'philosophy': List<dynamic>.from(philosophy),
      }, ['bestsellers', 'fiction', 'science', 'history', 'philosophy']);

      state = state.copyWith(
        bestsellers: finalCategorized['bestsellers']!,
        categorizedBooks: {
          'fiction': finalCategorized['fiction']!,
          'science': finalCategorized['science']!,
          'history': finalCategorized['history']!,
          'philosophy': finalCategorized['philosophy']!,
        },
        isInitialLoading: false,
        isLoading: false,
        isLoadingFromCache: false,
        loadedCategories: ['bestsellers', 'fiction', 'science', 'history', 'philosophy'],
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
      // Update UI immediately for this category so the shelf appears before moving on
      final updatedCategorized = Map<String, List<dynamic>>.from(state.categorizedBooks);
      updatedCategorized[category] = categoryBooks['results'];

      // Dedupe & shuffle across known categories including bestsellers
      final deduped = _dedupeAndShuffleCategorized(updatedCategorized, ['bestsellers', 'fiction', 'science', 'history', 'philosophy']);

      final updatedLoaded = List<String>.from(state.loadedCategories);
      if (!updatedLoaded.contains(category)) updatedLoaded.add(category);

      state = state.copyWith(
        categorizedBooks: deduped,
        loadedCategories: updatedLoaded,
        isLoadingFromCache: true,
      );
      debugPrint('Fetched and cached ${categoryBooks['results'].length} books for $category.');
    }
  }

  Future<List<dynamic>> _loadFromCache(String query) async {
    if (_isar == null) return [];

    final expiredDate = DateTime.now().subtract(_cacheExpiry);
    final cached = await _isar.cachedBooks
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

    await _isar.writeTxn(() async {
      // Efficiently delete old entries for this query that are not in the new list
      final oldEntries = await _isar.cachedBooks
          .where()
          .searchQueryEqualTo(query)
          .filter()
          .not()
          .anyOf(newBookIds, (q, int id) => q.bookIdEqualTo(id))
          .findAll();
      if (oldEntries.isNotEmpty) {
        await _isar.cachedBooks.deleteAll(oldEntries.map((e) => e.id).toList());
      }

      for (final book in books) {
        // Upsert: if existing record present for (bookId, query) update it; otherwise insert
        final existing = await _isar.cachedBooks
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
          await _isar.cachedBooks.put(cached);
        } else {
          // Update fields on existing record to refresh cache
          existing.title = book['title'] ?? existing.title;
          existing.author = book['authors']?.isNotEmpty == true ? book['authors'][0]['name'] : existing.author;
          existing.coverUrl = book['formats']?['image/jpeg'] ?? existing.coverUrl;
          existing.downloadUrl = book['formats']?['application/epub+zip'] ?? existing.downloadUrl;
          existing.language = book['languages']?.isNotEmpty == true ? book['languages'][0] : existing.language;
          existing.subjects = List<String>.from(book['subjects'] ?? existing.subjects ?? []);
          existing.cachedAt = now;
          existing.rawData = json.encode(book);
          existing.searchQuery = query.isEmpty ? null : query;
          existing.downloadCount = book['download_count'] ?? existing.downloadCount;
          existing.isBestseller = query == 'bestsellers' || (book['download_count'] ?? 0) > 10000;

          await _isar.cachedBooks.put(existing);
        }
      }
    });
  }


  Future<void> _clearOldCache() async {
    if (_isar == null) return;

    final expiredDate = DateTime.now().subtract(_cacheExpiry);
    await _isar.writeTxn(() async {
      await _isar.cachedBooks
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

  void clearSearch() {
    // Simply clear the search query and books - keep existing bestsellers and categories
    state = state.copyWith(
      searchQuery: '',
      books: [],
      nextUrl: 'https://gutendex.com/books/',
      isLoading: false,
      isLoadingFromCache: false,
      errorMessage: null,
    );
  }

  // Helper: dedupe books across categories and shuffle each category's list.
  // Uses improved randomization to fairly distribute books across categories
  Map<String, List<dynamic>> _dedupeAndShuffleCategorized(Map<String, List<dynamic>> input, List<String> order) {
    final out = <String, List<dynamic>>{};
    final seen = <int>{};
    final rng = Random();

    // First, shuffle the order of categories to make distribution more fair
    final shuffledOrder = List<String>.from(order);
    shuffledOrder.shuffle(rng);

    // Create a map to track which books belong to multiple categories
    final bookCategories = <int, List<String>>{};

    // Build a mapping of which categories each book belongs to
    for (final category in input.keys) {
      final books = input[category] ?? [];
      for (final book in books) {
        try {
          final id = (book['id'] is int) ? book['id'] as int : int.parse(book['id'].toString());
          bookCategories.putIfAbsent(id, () => []).add(category);
        } catch (_) {
          // Skip books without valid IDs
        }
      }
    }

    // Now process books, giving priority to books that appear in fewer categories
    final bookAssignments = <int, String>{}; // Track which category each book is assigned to

    // Sort books by how many categories they appear in (fewer categories = higher priority)
    final bookPriorities = bookCategories.entries.toList()
      ..sort((a, b) => a.value.length.compareTo(b.value.length));

    // Assign books to categories, prioritizing books that appear in fewer categories
    for (final entry in bookPriorities) {
      final bookId = entry.key;
      final categories = entry.value;

      if (!bookAssignments.containsKey(bookId)) {
        // Randomly choose one of the categories this book belongs to
        final availableCategories = categories.where((cat) => order.contains(cat)).toList();
        if (availableCategories.isNotEmpty) {
          availableCategories.shuffle(rng);
          bookAssignments[bookId] = availableCategories.first;
        }
      }
    }

    // Now build the output lists based on assignments
    for (final category in order) {
      final books = List<dynamic>.from(input[category] ?? []);
      final assigned = <dynamic>[];

      for (final book in books) {
        try {
          final id = (book['id'] is int) ? book['id'] as int : int.parse(book['id'].toString());
          if (bookAssignments[id] == category) {
            assigned.add(book);
          }
        } catch (_) {
          // Add books without valid IDs as-is
          assigned.add(book);
        }
      }

      // Shuffle the final list for this category
      assigned.shuffle(rng);
      out[category] = assigned;
    }

    // Handle any categories not in the order list
    for (final category in input.keys) {
      if (!out.containsKey(category)) {
        final books = List<dynamic>.from(input[category] ?? []);
        final assigned = <dynamic>[];

        for (final book in books) {
          try {
            final id = (book['id'] is int) ? book['id'] as int : int.parse(book['id'].toString());
            if (bookAssignments[id] == category) {
              assigned.add(book);
            }
          } catch (_) {
            assigned.add(book);
          }
        }

        assigned.shuffle(rng);
        out[category] = assigned;
      }
    }

    // Ensure all categories exist in output, even if empty
    for (final category in order) {
      out.putIfAbsent(category, () => []);
    }

    return out;
  }
}
