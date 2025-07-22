import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/data/search_index.dart';


final searchServiceProvider = Provider<SearchService>((ref) {
  final searchIndex = ref.watch(searchIndexProvider);
  return SearchService(searchIndex);
});

class SearchResult {
  final ContentBlock block;
  final String snippet;
  final Book book;

  SearchResult({
    required this.block,
    required this.snippet,
    required this.book,
  });
}

class SearchService {
  final SearchIndex _searchIndex;

  SearchService(this._searchIndex);

  Future<List<SearchResult>> search(String query, {int? bookId}) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final blocks = await _searchIndex.search(query, bookId: bookId);

    // Get book details for each block
    final results = <SearchResult>[];
    for (final block in blocks) {
      if (block.bookId == null) continue;
      Book? book;
      try {
        book = await _searchIndex.getBookById(block.bookId!);
      } catch (e) {
        // Optionally log or handle the error
        continue;
      }
      if (book != null) {
        final snippet = _searchIndex.getSnippet(block, query);
        results.add(SearchResult(
          block: block,
          snippet: snippet,
          book: book,
        ));
      }
    }

    return results;
  }

  // Group search results by book
  Map<Book, List<SearchResult>> groupResultsByBook(List<SearchResult> results) {
    final groupedResults = <Book, List<SearchResult>>{};

    for (final result in results) {
      if (!groupedResults.containsKey(result.book)) {
        groupedResults[result.book] = [];
      }
      groupedResults[result.book]!.add(result);
    }

    return groupedResults;
  }

  // Group search results by chapter
  Map<int, List<SearchResult>> groupResultsByChapter(List<SearchResult> results) {
    final groupedResults = <int, List<SearchResult>>{};

    for (final result in results) {
      final chapterIndex = result.block.chapterIndex ?? 0;
      if (!groupedResults.containsKey(chapterIndex)) {
        groupedResults[chapterIndex] = [];
      }
      groupedResults[chapterIndex]!.add(result);
    }

    return groupedResults;
  }
}

// Search state management
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<SearchResult>>((ref) async {
  final searchService = ref.watch(searchServiceProvider);
  final query = ref.watch(searchQueryProvider);

  if (query.trim().isEmpty) {
    return [];
  }

  return searchService.search(query);
});

// Selected book filter
final selectedBookFilterProvider = StateProvider<int?>((ref) => null);

// Filtered search results
final filteredSearchResultsProvider = Provider<AsyncValue<List<SearchResult>>>((ref) {
  final resultsAsync = ref.watch(searchResultsProvider);
  final selectedBookId = ref.watch(selectedBookFilterProvider);

  return resultsAsync.when(
    data: (results) {
      if (selectedBookId == null) {
        return AsyncValue.data(results);
      }

      final filtered = results.where((result) => result.book.id == selectedBookId).toList();
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});
