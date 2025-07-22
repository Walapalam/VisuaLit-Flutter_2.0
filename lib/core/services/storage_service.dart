import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:visualit/features/reader/data/new_models.dart';

/// A service for storing and retrieving data without using Isar.
/// This implementation uses JSON files stored in the application documents directory.
class StorageService {
  late final Future<Directory> _appDir;
  final Map<String, dynamic> _cache = {};
  int _nextId = 1;

  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  
  StorageService._internal() {
    _appDir = getApplicationDocumentsDirectory();
    _initialize();
  }

  Future<void> _initialize() async {
    // Load the next ID counter from storage
    try {
      final idFile = File('${(await _appDir).path}/id_counter.json');
      if (await idFile.exists()) {
        final String contents = await idFile.readAsString();
        final Map<String, dynamic> data = jsonDecode(contents);
        _nextId = data['nextId'] ?? 1;
      }
    } catch (e) {
      debugPrint('Error initializing StorageService: $e');
    }
  }

  Future<void> _saveIdCounter() async {
    try {
      final idFile = File('${(await _appDir).path}/id_counter.json');
      await idFile.writeAsString(jsonEncode({'nextId': _nextId}));
    } catch (e) {
      debugPrint('Error saving ID counter: $e');
    }
  }

  int _getNextId() {
    final id = _nextId;
    _nextId++;
    _saveIdCounter();
    return id;
  }

  // --- Book operations ---

  Future<List<Book>> getAllBooks() async {
    try {
      final booksDir = Directory('${(await _appDir).path}/books');
      if (!await booksDir.exists()) {
        await booksDir.create(recursive: true);
        return [];
      }

      final List<Book> books = [];
      await for (final entity in booksDir.list()) {
        if (entity is File && entity.path.endsWith('.json')) {
          final String contents = await entity.readAsString();
          final Map<String, dynamic> data = jsonDecode(contents);
          books.add(Book.fromJson(data));
        }
      }
      return books;
    } catch (e) {
      debugPrint('Error getting all books: $e');
      return [];
    }
  }

  Future<Book?> getBook(int id) async {
    try {
      final bookFile = File('${(await _appDir).path}/books/book_$id.json');
      if (!await bookFile.exists()) return null;

      final String contents = await bookFile.readAsString();
      final Map<String, dynamic> data = jsonDecode(contents);
      return Book.fromJson(data);
    } catch (e) {
      debugPrint('Error getting book $id: $e');
      return null;
    }
  }

  Future<int> saveBook(Book book) async {
    try {
      final booksDir = Directory('${(await _appDir).path}/books');
      if (!await booksDir.exists()) {
        await booksDir.create(recursive: true);
      }

      // If the book doesn't have an ID, assign one
      if (book.id <= 0) {
        book = Book(
          id: _getNextId(),
          epubFilePath: book.epubFilePath,
          title: book.title,
          author: book.author,
          coverImageBytes: book.coverImageBytes,
          publisher: book.publisher,
          language: book.language,
          publicationDate: book.publicationDate,
          status: book.status,
          lastReadPage: book.lastReadPage,
          lastReadTimestamp: book.lastReadTimestamp,
          toc: book.toc,
        );
      }

      final bookFile = File('${(await _appDir).path}/books/book_${book.id}.json');
      await bookFile.writeAsString(jsonEncode(book.toJson()));
      return book.id;
    } catch (e) {
      debugPrint('Error saving book: $e');
      return -1;
    }
  }

  Future<bool> deleteBook(int id) async {
    try {
      final bookFile = File('${(await _appDir).path}/books/book_$id.json');
      if (await bookFile.exists()) {
        await bookFile.delete();
        
        // Also delete all content blocks and highlights for this book
        await _deleteContentBlocksForBook(id);
        await _deleteHighlightsForBook(id);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting book $id: $e');
      return false;
    }
  }

  // --- ContentBlock operations ---

  Future<List<ContentBlock>> getContentBlocksForBook(int bookId) async {
    try {
      final blocksDir = Directory('${(await _appDir).path}/blocks/book_$bookId');
      if (!await blocksDir.exists()) {
        return [];
      }

      final List<ContentBlock> blocks = [];
      await for (final entity in blocksDir.list()) {
        if (entity is File && entity.path.endsWith('.json')) {
          final String contents = await entity.readAsString();
          final Map<String, dynamic> data = jsonDecode(contents);
          blocks.add(ContentBlock.fromJson(data));
        }
      }
      
      // Sort blocks by chapterIndex and blockIndexInChapter
      blocks.sort((a, b) {
        final chapterComparison = (a.chapterIndex ?? 0).compareTo(b.chapterIndex ?? 0);
        if (chapterComparison != 0) return chapterComparison;
        return (a.blockIndexInChapter ?? 0).compareTo(b.blockIndexInChapter ?? 0);
      });
      
      return blocks;
    } catch (e) {
      debugPrint('Error getting content blocks for book $bookId: $e');
      return [];
    }
  }

  Future<int> saveContentBlock(ContentBlock block) async {
    try {
      if (block.bookId == null) {
        throw Exception('ContentBlock must have a bookId');
      }

      final blocksDir = Directory('${(await _appDir).path}/blocks/book_${block.bookId}');
      if (!await blocksDir.exists()) {
        await blocksDir.create(recursive: true);
      }

      // If the block doesn't have an ID, assign one
      if (block.id <= 0) {
        block = ContentBlock(
          id: _getNextId(),
          bookId: block.bookId,
          chapterIndex: block.chapterIndex,
          blockIndexInChapter: block.blockIndexInChapter,
          src: block.src,
          blockType: block.blockType,
          htmlContent: block.htmlContent,
          textContent: block.textContent,
          imageBytes: block.imageBytes,
        );
      }

      final blockFile = File('${blocksDir.path}/block_${block.id}.json');
      await blockFile.writeAsString(jsonEncode(block.toJson()));
      return block.id;
    } catch (e) {
      debugPrint('Error saving content block: $e');
      return -1;
    }
  }

  Future<bool> _deleteContentBlocksForBook(int bookId) async {
    try {
      final blocksDir = Directory('${(await _appDir).path}/blocks/book_$bookId');
      if (await blocksDir.exists()) {
        await blocksDir.delete(recursive: true);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting content blocks for book $bookId: $e');
      return false;
    }
  }

  // --- Highlight operations ---

  Future<List<Highlight>> getHighlightsForBook(int bookId) async {
    try {
      final highlightsDir = Directory('${(await _appDir).path}/highlights/book_$bookId');
      if (!await highlightsDir.exists()) {
        return [];
      }

      final List<Highlight> highlights = [];
      await for (final entity in highlightsDir.list()) {
        if (entity is File && entity.path.endsWith('.json')) {
          final String contents = await entity.readAsString();
          final Map<String, dynamic> data = jsonDecode(contents);
          highlights.add(Highlight.fromJson(data));
        }
      }
      return highlights;
    } catch (e) {
      debugPrint('Error getting highlights for book $bookId: $e');
      return [];
    }
  }

  Future<int> saveHighlight(Highlight highlight) async {
    try {
      final highlightsDir = Directory('${(await _appDir).path}/highlights/book_${highlight.bookId}');
      if (!await highlightsDir.exists()) {
        await highlightsDir.create(recursive: true);
      }

      // If the highlight doesn't have an ID, assign one
      if (highlight.id <= 0) {
        highlight = Highlight(
          id: _getNextId(),
          bookId: highlight.bookId,
          chapterIndex: highlight.chapterIndex,
          blockIndexInChapter: highlight.blockIndexInChapter,
          text: highlight.text,
          startOffset: highlight.startOffset,
          endOffset: highlight.endOffset,
          color: highlight.color,
          timestamp: highlight.timestamp,
          note: highlight.note,
        );
      }

      final highlightFile = File('${highlightsDir.path}/highlight_${highlight.id}.json');
      await highlightFile.writeAsString(jsonEncode(highlight.toJson()));
      return highlight.id;
    } catch (e) {
      debugPrint('Error saving highlight: $e');
      return -1;
    }
  }

  Future<bool> deleteHighlight(int id, int bookId) async {
    try {
      final highlightFile = File('${(await _appDir).path}/highlights/book_$bookId/highlight_$id.json');
      if (await highlightFile.exists()) {
        await highlightFile.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting highlight $id: $e');
      return false;
    }
  }

  Future<bool> _deleteHighlightsForBook(int bookId) async {
    try {
      final highlightsDir = Directory('${(await _appDir).path}/highlights/book_$bookId');
      if (await highlightsDir.exists()) {
        await highlightsDir.delete(recursive: true);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting highlights for book $bookId: $e');
      return false;
    }
  }

  // --- Stream support for real-time updates ---

  final Map<String, StreamController<List<dynamic>>> _streamControllers = {};

  Stream<List<Book>> watchAllBooks() {
    const key = 'all_books';
    if (!_streamControllers.containsKey(key)) {
      _streamControllers[key] = StreamController<List<Book>>.broadcast();
      
      // Initial data
      getAllBooks().then((books) {
        if (_streamControllers.containsKey(key)) {
          (_streamControllers[key] as StreamController<List<Book>>).add(books);
        }
      });
    }
    return (_streamControllers[key] as StreamController<List<Book>>).stream;
  }

  Stream<List<Highlight>> watchHighlightsForBook(int bookId) {
    final key = 'highlights_$bookId';
    if (!_streamControllers.containsKey(key)) {
      _streamControllers[key] = StreamController<List<Highlight>>.broadcast();
      
      // Initial data
      getHighlightsForBook(bookId).then((highlights) {
        if (_streamControllers.containsKey(key)) {
          (_streamControllers[key] as StreamController<List<Highlight>>).add(highlights);
        }
      });
    }
    return (_streamControllers[key] as StreamController<List<Highlight>>).stream;
  }

  // Call this method after saving a book to update any active streams
  void _notifyBookChanged(Book book) {
    const key = 'all_books';
    if (_streamControllers.containsKey(key)) {
      getAllBooks().then((books) {
        (_streamControllers[key] as StreamController<List<Book>>).add(books);
      });
    }
  }

  // Call this method after saving a highlight to update any active streams
  void _notifyHighlightChanged(Highlight highlight) {
    final key = 'highlights_${highlight.bookId}';
    if (_streamControllers.containsKey(key)) {
      getHighlightsForBook(highlight.bookId).then((highlights) {
        (_streamControllers[key] as StreamController<List<Highlight>>).add(highlights);
      });
    }
  }

  // Clean up resources
  void dispose() {
    for (final controller in _streamControllers.values) {
      controller.close();
    }
    _streamControllers.clear();
  }
}