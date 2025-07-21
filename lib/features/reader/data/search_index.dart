import 'package:isar/isar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:collection/collection.dart';

// Note: The generated part file is not available yet
// part 'search_index.g.dart';

final searchIndexProvider = Provider<SearchIndex>((ref) {
  final isar = ref.watch(isarDBProvider).requireValue;
  return SearchIndex(isar);
});

// In-memory representation of search index entry
class SearchIndexEntry {
  String keyword;
  List<int> blockIds = [];

  SearchIndexEntry(this.keyword);
}

class SearchIndex {
  final Isar _isar;
  // Define common English stop words since direct access to english_words.stopWords is causing issues
  final Set<String> _stopWords = {
    'a', 'an', 'the', 'and', 'or', 'but', 'if', 'because', 'as', 'what',
    'which', 'this', 'that', 'these', 'those', 'then', 'just', 'so', 'than',
    'such', 'both', 'through', 'about', 'for', 'is', 'of', 'while', 'during',
    'to', 'from', 'in', 'on', 'at', 'by', 'with', 'about', 'against', 'between',
    'into', 'through', 'during', 'before', 'after', 'above', 'below', 'up',
    'down', 'out', 'off', 'over', 'under', 'again', 'further', 'then', 'once',
    'here', 'there', 'when', 'where', 'why', 'how', 'all', 'any', 'both',
    'each', 'few', 'more', 'most', 'other', 'some', 'such', 'no', 'nor', 'not',
    'only', 'own', 'same', 'so', 'than', 'too', 'very', 'can', 'will', 'just',
    'should', 'now'
  };

  // In-memory storage for search index entries
  final Map<String, SearchIndexEntry> _searchIndexEntries = {};

  SearchIndex(this._isar) {
    print("✅ [SearchIndex] Initialized.");
  }

  // Process a content block and add its words to the index
  Future<void> indexContentBlock(ContentBlock block) async {
    if (block.textContent == null || block.textContent!.isEmpty) {
      return;
    }

    // Tokenize the text
    final tokens = _tokenizeText(block.textContent!);
    block.tokenizedText = tokens;

    // Stem the tokens
    final stemmed = _stemWords(tokens);
    block.stemmedText = stemmed;

    // Update the block with tokenized and stemmed text
    await _isar.writeTxn(() async {
      await _isar.contentBlocks.put(block);
    });

    // Add each token to the index
    if (block.id != null) {
      await _addToIndex(stemmed, block.id!);
    }
  }

  // Tokenize text into words
  List<String> _tokenizeText(String text) {
    // Convert to lowercase and split by non-alphanumeric characters
    final words = text.toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty && !_stopWords.contains(word))
        .toList();

    return words;
  }

  // Stem words using a simple algorithm
  List<String> _stemWords(List<String> words) {
    // This is a very basic implementation
    // In a real app, you'd use a proper stemming library
    return words.map((word) {
      if (word.endsWith('ing')) return word.substring(0, word.length - 3);
      if (word.endsWith('ed')) return word.substring(0, word.length - 2);
      if (word.endsWith('s') && !word.endsWith('ss')) return word.substring(0, word.length - 1);
      return word;
    }).toList();
  }

  // Add a word to the index
  Future<void> _addToIndex(List<String> words, int blockId) async {
    for (final word in words) {
      var entry = _searchIndexEntries[word];

      if (entry == null) {
        entry = SearchIndexEntry(word);
        entry.blockIds = [blockId];
        _searchIndexEntries[word] = entry;
      } else if (!entry.blockIds.contains(blockId)) {
        entry.blockIds.add(blockId);
      }
    }
  }

  // Search for content blocks containing the given query
  Future<List<ContentBlock>> search(String query, {int? bookId}) async {
    final queryWords = _tokenizeText(query);
    final stemmedQuery = _stemWords(queryWords);

    if (stemmedQuery.isEmpty) {
      return [];
    }

    // Get all blocks that match any of the query words
    final blockIdSets = stemmedQuery.map((word) {
      final entry = _searchIndexEntries[word];
      return entry?.blockIds.toSet() ?? <int>{};
    }).toList();

    // Find blocks that match all query words (intersection of sets)
    Set<int> blockIds = <int>{};
    if (blockIdSets.isNotEmpty) {
      blockIds = blockIdSets.first;
      for (var i = 1; i < blockIdSets.length; i++) {
        blockIds = blockIds.intersection(blockIdSets[i] as Set<int>);
      }
    }

    if (blockIds.isEmpty) {
      return [];
    }

    // Retrieve the matching blocks
    final blocks = await _isar.contentBlocks
        .where()
        .anyOf(blockIds, (q, id) => q.idEqualTo(id))
        .filter()
        .optional(bookId != null, (q) => q.bookIdEqualTo(bookId!))
        .findAll();

    // Sort by relevance (number of query words in the block)
    blocks.sort((a, b) {
      final aMatches = (a.stemmedText?.isNotEmpty ?? false) 
          ? stemmedQuery.where((word) => a.stemmedText!.contains(word)).length 
          : 0;
      final bMatches = (b.stemmedText?.isNotEmpty ?? false) 
          ? stemmedQuery.where((word) => b.stemmedText!.contains(word)).length 
          : 0;
      return bMatches.compareTo(aMatches); // Descending order
    });

    return blocks;
  }

  // Get a snippet of text around the search term
  String getSnippet(ContentBlock block, String query, {int snippetLength = 100}) {
    if (block.textContent == null || block.textContent!.isEmpty) {
      return '';
    }

    final text = block.textContent!;
    final queryWords = _tokenizeText(query);

    // Find the first occurrence of any query word
    int startIndex = 0;
    for (final word in queryWords) {
      final index = text.toLowerCase().indexOf(word.toLowerCase());
      if (index != -1) {
        startIndex = index;
        break;
      }
    }

    // Calculate snippet boundaries
    final halfLength = snippetLength ~/ 2;
    final start = (startIndex - halfLength).clamp(0, text.length);
    final end = (startIndex + halfLength).clamp(0, text.length);

    // Extract the snippet
    var snippet = text.substring(start, end);

    // Add ellipsis if needed
    if (start > 0) snippet = '...$snippet';
    if (end < text.length) snippet = '$snippet...';

    return snippet;
  }
  // Get a book by its ID
  Future<Book?> getBookById(int bookId) async {
    return await _isar.books.get(bookId);
  }
}
