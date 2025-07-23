import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/dom.dart' as dom;
import 'package:isar/isar.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/library/data/background_task_queue.dart';
import 'package:visualit/features/library/data/book_processing_task.dart';
import 'package:visualit/features/library/data/local_library_service.dart';
import 'package:visualit/features/reader/data/book_data.dart' as db;
import 'package:visualit/features/reader/data/toc_entry.dart';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart'; // <-- Added for debugPrint

final localLibraryServiceProvider = Provider<LocalLibraryService>((ref) {
  return LocalLibraryService();
});

final libraryControllerProvider = StateNotifierProvider.autoDispose<LibraryController, AsyncValue<List<db.Book>>>(
        (ref) {
      final isar = ref.watch(isarDBProvider).requireValue;
      final localLibraryService = ref.watch(localLibraryServiceProvider);
      final backgroundTaskQueue = ref.watch(backgroundTaskQueueProvider);
      return LibraryController(localLibraryService, isar, backgroundTaskQueue);
    }
);

class LibraryController extends StateNotifier<AsyncValue<List<db.Book>>> {
  final LocalLibraryService _localLibraryService;
  final Isar _isar;
  final BackgroundTaskQueue _backgroundTaskQueue;

  LibraryController(this._localLibraryService, this._isar, this._backgroundTaskQueue) : super(const AsyncValue.loading()) {
    debugPrint("✅ [LibraryController] Initialized.");
    loadBooksFromDb();

    _backgroundTaskQueue.taskStream.listen((_) {
      loadBooksFromDb();
    });
  }

  Future<void> loadBooksFromDb() async {
    debugPrint("🔄 [LibraryController] Loading all books from database...");
    state = const AsyncValue.loading();
    try {
      final books = await _isar.books.where().sortByTitle().findAll();
      debugPrint("  [LibraryController] Found ${books.length} books in DB.");
      state = AsyncValue.data(books);
    } catch (e, st) {
      debugPrint("❌ [LibraryController] FATAL ERROR loading books: $e");
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> pickAndProcessBooks() async {
    debugPrint("ℹ️ [LibraryController] User initiated 'pickAndProcessBooks'.");
    final files = await _localLibraryService.pickFiles();
    await _queueFilesForProcessing(files);
  }

  Future<void> scanAndProcessBooks() async {
    debugPrint("ℹ️ [LibraryController] User initiated 'scanAndProcessBooks'.");
    final files = await _localLibraryService.scanAndLoadBooks();
    await _queueFilesForProcessing(files);
  }

  Future<void> addBookFromCart(Map<String, dynamic> fileData) async {
    // Convert the map to PickedFileData
    final pickedFile = PickedFileData(
      path: fileData['id'].toString(), // Or generate a file path if needed
      bytes: fileData['fileBytes'] as Uint8List,
    );
    debugPrint("ℹ️ [LibraryController] Adding book from cart: ${pickedFile.path}");
    await _queueFilesForProcessing([pickedFile]);
  }

  Future<void> retryProcessingBook(int bookId) async {
    debugPrint("ℹ️ [LibraryController] User initiated retry for book ID: $bookId");

    final book = await _isar.books.get(bookId);
    if (book == null) {
      debugPrint("❌ [LibraryController] Book not found with ID: $bookId");
      return;
    }

    if (book.status != db.ProcessingStatus.error) {
      debugPrint("⚠️ [LibraryController] Book is not in error state. Current status: ${book.status}");
      return;
    }

    try {
      final filePath = book.epubFilePath;
      final fileData = await _localLibraryService.loadFileFromPath(filePath);

      if (fileData == null) {
        throw Exception("Could not load file from path: $filePath");
      }

      await _isar.writeTxn(() async {
        book.status = db.ProcessingStatus.queued;
        book.errorMessage = null;
        book.errorStackTrace = null;
        await _isar.books.put(book);
      });

      await loadBooksFromDb();

      final task = BookProcessingTask(
        id: bookId,
        filePath: filePath,
        fileBytes: fileData.bytes,
      );

      _backgroundTaskQueue.enqueueTask(task);
      debugPrint("✅ [LibraryController] Enqueued retry task for book ID: $bookId");

    } catch (e, s) {
      debugPrint("❌ [LibraryController] Error preparing book for retry: $e\n$s");
      await _isar.writeTxn(() async {
        final bookToUpdate = await _isar.books.get(bookId);
        if (bookToUpdate != null) {
          bookToUpdate.status = db.ProcessingStatus.error;
          bookToUpdate.errorMessage = e.toString();
          bookToUpdate.errorStackTrace = s.toString();
          await _isar.books.put(bookToUpdate);
        }
      });
      await loadBooksFromDb();
    }
  }

  Future<void> _queueFilesForProcessing(List<PickedFileData> files) async {
    if (files.isEmpty) {
      await loadBooksFromDb();
      return;
    }

    debugPrint("⏳ [LibraryController] Starting to queue ${files.length} file(s) for background processing.");

    for (final fileData in files) {
      final filePath = fileData.path;
      debugPrint("\n--- 📖 Preparing Book for Queue: $filePath ---");

      final existingBook = await _isar.books.where().epubFilePathEqualTo(filePath).findFirst();
      if (existingBook != null) {
        debugPrint("  ⚠️ [LibraryController] Book already exists in DB. Skipping.");
        continue;
      }

      final newBook = db.Book()
        ..epubFilePath = filePath
        ..status = db.ProcessingStatus.queued;

      final bookId = await _isar.writeTxn(() async => await _isar.books.put(newBook));
      debugPrint("  ✅ [LibraryController] Created initial book entry with ID: $bookId, status: queued");

      final task = BookProcessingTask(
        id: bookId,
        filePath: filePath,
        fileBytes: fileData.bytes,
      );

      _backgroundTaskQueue.enqueueTask(task);
      debugPrint("  ✅ [LibraryController] Enqueued book processing task for ID: $bookId");
    }

    await loadBooksFromDb();
  }

  void _flattenAndParseElements({
    required List<dom.Element> elements,
    required List<db.ContentBlock> targetBlockList,
    required int bookId,
    required int chapterIndex,
    required String chapterPath, // Added chapterPath
    required Archive archive,
    required int Function() getNextBlockIndex,
  }) {
    for (final element in elements) {
      final tagName = element.localName;
      final blockType = _getBlockType(tagName);

      if (tagName == 'div' || tagName == 'section' || tagName == 'article' || tagName == 'main') {
        _flattenAndParseElements(
          elements: element.children,
          targetBlockList: targetBlockList,
          bookId: bookId,
          chapterIndex: chapterIndex,
          chapterPath: chapterPath, // Pass chapterPath
          archive: archive,
          getNextBlockIndex: getNextBlockIndex,
        );
        continue;
      }

      if (blockType != db.BlockType.unsupported) {
        final textContent = element.text.replaceAll('\u00A0', ' ').trim();

        if (textContent.isEmpty && blockType != db.BlockType.img) {
          continue;
        }

        final block = db.ContentBlock()
          ..bookId = bookId
          ..chapterIndex = chapterIndex
          ..blockIndexInChapter = getNextBlockIndex()
          ..src = chapterPath
          ..blockType = blockType
          ..htmlContent = element.outerHtml
          ..textContent = textContent;

        if (blockType == db.BlockType.img) {
          // Image byte extraction is now primarily handled by BookProcessor
        }
        targetBlockList.add(block);
      }
    }
  }

  List<TOCEntry> _parseNavXhtml(String content, String basePath) {
    final document = html_parser.parse(content);
    final nav = document.querySelector('nav[epub\\:type="toc"]');
    if (nav == null) return [];
    final ol = nav.querySelector('ol');
    if (ol == null) return [];
    return _parseNavList(ol, basePath);
  }

  List<TOCEntry> _parseNavList(dom.Element listElement, String basePath) {
    final entries = <TOCEntry>[];
    for (final item in listElement.children.where((e) => e.localName == 'li')) {
      final anchor = item.querySelector('a');
      if (anchor == null) continue;
      final href = anchor.attributes['href'] ?? '';
      final parts = href.split('#');
      final src = parts.length > 0 && parts[0].isNotEmpty ? parts[0] : null;
      final fragment = parts.length > 1 ? parts[1] : null;
      final entry = TOCEntry()
        ..title = anchor.text.trim()
        ..src = src != null ? p.normalize(p.join(basePath, src)) : null
        ..fragment = fragment;
      final nestedOl = item.querySelector('ol');
      if (nestedOl != null) {
        entry.children = _parseNavList(nestedOl, basePath);
      }
      entries.add(entry);
    }
    return entries;
  }

  List<TOCEntry> _parseNcx(String content, String basePath) {
    final document = XmlDocument.parse(content);
    final navMap = document.findAllElements('navMap').first;
    return _parseNavPoints(navMap.findElements('navPoint').toList(), basePath);
  }

  List<TOCEntry> _parseNavPoints(List<XmlElement> navPoints, String basePath) {
    final entries = <TOCEntry>[];
    for (final navPoint in navPoints) {
      final navLabel = navPoint.findElements('navLabel').first.findElements('text').first.innerText;
      final contentSrc = navPoint.findElements('content').first.getAttribute('src') ?? '';
      final parts = contentSrc.split('#');
      final src = parts.length > 0 && parts[0].isNotEmpty ? parts[0] : null;
      final fragment = parts.length > 1 ? parts[1] : null;
      final entry = TOCEntry()
        ..title = navLabel.trim()
        ..src = src != null ? p.normalize(p.join(basePath, src)) : null
        ..fragment = fragment;
      final children = navPoint.findElements('navPoint').toList();
      if (children.isNotEmpty) {
        entry.children = _parseNavPoints(children, basePath);
      }
      entries.add(entry);
    }
    return entries;
  }

  Future<void> _processChapter({
    required List<String> spine,
    required int i,
    required Map<String, String> manifest,
    required Archive archive,
    required int bookId,
    required List<db.ContentBlock> allBlocks,
  }) async {
    final idref = spine[i];
    final chapterPath = manifest[idref];
    if (chapterPath == null) return;

    final chapterFile = archive.findFile(chapterPath);
    if (chapterFile == null) return;

    final chapterContent = String.fromCharCodes(chapterFile.content);
    final document = html_parser.parse(chapterContent);
    final body = document.body;
    if (body == null) return;

    int blockCounter = 0;

    _flattenAndParseElements(
      elements: body.children,
      targetBlockList: allBlocks,
      bookId: bookId,
      chapterIndex: i,
      chapterPath: chapterPath, // Pass chapterPath
      archive: archive,
      getNextBlockIndex: () => blockCounter++,
    );

    debugPrint("  ✅ [LibraryController] Processed chapter $i with ${blockCounter} blocks");
  }

  db.BlockType _getBlockType(String? tagName) {
    switch (tagName?.toLowerCase()) {
      case 'p': return db.BlockType.p;
      case 'h1': return db.BlockType.h1;
      case 'h2': return db.BlockType.h2;
      case 'h3': return db.BlockType.h3;
      case 'h4': return db.BlockType.h4;
      case 'h5': return db.BlockType.h5;
      case 'h6': return db.BlockType.h6;
      case 'img': return db.BlockType.img;
      case 'image': return db.BlockType.img;
      case 'svg': return db.BlockType.img;
      default: return db.BlockType.unsupported;
    }
  }
}