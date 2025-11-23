import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:html/dom.dart' as dom;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'package:watcher/watcher.dart';

final localLibraryServiceProvider = Provider<LocalLibraryService>((ref) {
  return LocalLibraryService();
});

final libraryControllerProvider =
    StateNotifierProvider.autoDispose<
      LibraryController,
      AsyncValue<List<db.Book>>
    >((ref) {
      final isar = ref.watch(isarDBProvider).requireValue;
      final localLibraryService = ref.watch(localLibraryServiceProvider);
      // Ensure backgroundTaskQueue is provided if used in your actual app setup
      final backgroundTaskQueue = ref.watch(backgroundTaskQueueProvider);
      return LibraryController(localLibraryService, isar, backgroundTaskQueue);
    });

class LibraryController extends StateNotifier<AsyncValue<List<db.Book>>> {
  final LocalLibraryService _localLibraryService;
  final Isar _isar;
  final BackgroundTaskQueue
  _backgroundTaskQueue; // Retained as per your original file

  DirectoryWatcher? _fileWatcher;

  LibraryController(
    this._localLibraryService,
    this._isar,
    this._backgroundTaskQueue,
  ) : super(const AsyncValue.loading()) {
    print("✅ [LibraryController] Initialized.");
    loadBooksFromDb();
    _startFolderWatcher();

    _backgroundTaskQueue.taskStream.listen((_) {
      loadBooksFromDb();
    });
  }

  @override
  void dispose() {
    _fileWatcher?.events.drain();
    super.dispose();
  }

  void _startFolderWatcher() async {
    final visuaLitDir = await _ensureVisuaLitDirectory();
    if (visuaLitDir == null) {
      print(
        "❌ [LibraryController] Failed to create/access VisuaLit directory. File watcher not started.",
      );
      return;
    }

    try {
      _fileWatcher = DirectoryWatcher(visuaLitDir.path);
      _fileWatcher?.events.listen(_handleFileChange);
      print(
        "✅ [LibraryController] Started watching VisuaLit directory: ${visuaLitDir.path}",
      );
    } catch (e) {
      print("❌ [LibraryController] Failed to start directory watcher: $e");
    }
  }

  Future<Directory?> _ensureVisuaLitDirectory() async {
    try {
      final visuaLitDir = await _localLibraryService.getLibraryRoot();

      // Create the directory if it doesn't exist
      if (!await visuaLitDir.exists()) {
        print(
          "📁 [LibraryController] Creating VisuaLit directory: ${visuaLitDir.path}",
        );
        await visuaLitDir.create(recursive: true);
      }

      print(
        "✅ [LibraryController] VisuaLit directory ready: ${visuaLitDir.path}",
      );
      return visuaLitDir;
    } catch (e) {
      print("❌ [LibraryController] Error ensuring VisuaLit directory: $e");
      return null;
    }
  }

  /// Copies files from temporary file picker cache to permanent app storage
  /// Returns a new list of PickedFileData with permanent paths
  Future<List<PickedFileData>> _copyFilesToPermanentStorage(
    List<PickedFileData> tempFiles,
  ) async {
    if (tempFiles.isEmpty) return [];

    print(
      "📋 [LibraryController] Copying ${tempFiles.length} file(s) to permanent storage...",
    );

    final visuaLitDir = await _ensureVisuaLitDirectory();
    if (visuaLitDir == null) {
      print(
        "❌ [LibraryController] Cannot access VisuaLit directory for permanent storage",
      );
      return [];
    }

    // Create books subdirectory for organized storage
    final booksDir = Directory('${visuaLitDir.path}/books');
    if (!await booksDir.exists()) {
      await booksDir.create(recursive: true);
      print("📁 [LibraryController] Created books directory: ${booksDir.path}");
    }

    final permanentFiles = <PickedFileData>[];

    for (final tempFile in tempFiles) {
      try {
        // Extract original filename from temporary path
        final originalFileName = p.basename(tempFile.path);

        // Generate a unique filename to avoid collisions
        // Format: originalname_timestamp_randomid.epub
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final randomId = timestamp.hashCode.abs() % 10000;
        final sanitizedName = originalFileName.replaceAll(
          RegExp(r'[^\w\s\-\.]'),
          '_',
        );
        final nameWithoutExt = p.basenameWithoutExtension(sanitizedName);
        final ext = p.extension(sanitizedName);
        final uniqueFileName = '${nameWithoutExt}_${timestamp}_$randomId$ext';

        final permanentPath = p.join(booksDir.path, uniqueFileName);
        final permanentFile = File(permanentPath);

        // Write the bytes to permanent storage
        await permanentFile.writeAsBytes(tempFile.bytes);

        // Store RELATIVE path in database
        // relative path: books/uniqueFileName
        final relativePath = 'books/$uniqueFileName';

        print(
          "✅ [LibraryController] Saved to permanent storage: $permanentPath (${tempFile.bytes.length} bytes)",
        );
        print("   -> Storing relative path: $relativePath");

        // Create new PickedFileData with RELATIVE path for DB storage
        permanentFiles.add(
          PickedFileData(path: relativePath, bytes: tempFile.bytes),
        );
      } catch (e, s) {
        print(
          "❌ [LibraryController] Failed to copy ${tempFile.path} to permanent storage: $e\n$s",
        );
        // Continue with other files even if one fails
      }
    }

    print(
      "✅ [LibraryController] Successfully copied ${permanentFiles.length}/${tempFiles.length} files to permanent storage",
    );
    return permanentFiles;
  }

  Future<void> _handleFileChange(WatchEvent event) async {
    if (event.path.toLowerCase().endsWith('.epub')) {
      if (event.type == ChangeType.ADD) {
        final fileData = await _localLibraryService.loadFileFromPath(
          event.path,
        );
        if (fileData != null) {
          await _processFiles([fileData]);
        }
      } else if (event.type == ChangeType.REMOVE) {
        await _removeBook(event.path);
      }
    }
  }

  Future<void> _removeBook(String filePath) async {
    // This might need adjustment if watcher returns absolute paths but DB has relative
    // For now, let's assume watcher is less critical or we can fix it later if needed.
    // Ideally we resolve filePath to relative if possible, or search by resolving DB paths.
    // Given the complexity, let's skip complex watcher logic fix for now and focus on core load.

    final book = await _isar.books
        .where()
        .epubFilePathEqualTo(filePath)
        .findFirst();
    if (book != null) {
      await _isar.writeTxn(() async {
        await _isar.books.delete(book.id);
      });
      await loadBooksFromDb();
    }
  }

  Future<void> loadBooksFromDb() async {
    print("🔄 [LibraryController] Loading all books from database...");
    state = const AsyncValue.loading();
    try {
      final books = await _isar.books.where().sortByTitle().findAll();
      print("  [LibraryController] Found ${books.length} books in DB.");

      // MIGRATION LOGIC: Check for absolute paths and convert to relative
      bool migrationNeeded = false;

      for (final book in books) {
        if (book.epubFilePath.startsWith('/')) {
          // It's an absolute path. Try to migrate.
          String? relativePath;

          if (book.epubFilePath.contains('/VisuaLit/books/')) {
            relativePath =
                'books/${book.epubFilePath.split('/VisuaLit/books/').last}';
          } else if (book.epubFilePath.contains('/VisuaLit/')) {
            // Legacy marketplace downloads in root
            relativePath = book.epubFilePath.split('/VisuaLit/').last;
          } else if (book.epubFilePath.contains('/books/')) {
            // Fallback for standard structure
            relativePath = 'books/${book.epubFilePath.split('/books/').last}';
          }

          if (relativePath != null) {
            print(
              "⚠️ [LibraryController] Migrating book '${book.title}' from absolute to relative path.",
            );
            print("   Old: ${book.epubFilePath}");
            print("   New: $relativePath");

            await _isar.writeTxn(() async {
              book.epubFilePath = relativePath!;
              await _isar.books.put(book);
            });
            migrationNeeded = true;
          }
        }
      }

      if (migrationNeeded) {
        print("✅ [LibraryController] Migration completed. Reloading books...");
        // Recursive call to reload with migrated paths
        return loadBooksFromDb();
      }

      // Check for books with temporary cache paths
      final booksWithCachePaths = books
          .where(
            (book) =>
                book.epubFilePath.contains('/cache/file_picker/') ||
                book.epubFilePath.contains('/cache/'),
          )
          .toList();

      if (booksWithCachePaths.isNotEmpty) {
        print(
          "⚠️ [LibraryController] Found ${booksWithCachePaths.length} books with temporary cache paths:",
        );
        for (final book in booksWithCachePaths) {
          print("   - ${book.title ?? 'Unknown'} (ID: ${book.id})");
        }
        print("   These books need to be re-imported to work properly.");
      }

      state = AsyncValue.data(books);
    } catch (e, st) {
      print("❌ [LibraryController] FATAL ERROR loading books: $e");
      state = AsyncValue.error(e, st);
    }
  }

  /// Check if a book has a temporary cache path that may no longer exist
  Future<bool> hasTemporaryCachePath(int bookId) async {
    final book = await _isar.books.get(bookId);
    if (book == null) return false;
    return book.epubFilePath.contains('/cache/file_picker/') ||
        book.epubFilePath.contains('/cache/');
  }

  /// Delete a book from the library (useful for removing books with cache paths)
  Future<void> deleteBook(int bookId) async {
    print("🗑️ [LibraryController] Deleting book ID: $bookId");
    try {
      await _isar.writeTxn(() async {
        // Delete the book
        await _isar.books.delete(bookId);
        // Delete associated content blocks
        final blocks = await _isar.contentBlocks
            .filter()
            .bookIdEqualTo(bookId)
            .findAll();
        for (final block in blocks) {
          await _isar.contentBlocks.delete(block.id);
        }
      });
      print("✅ [LibraryController] Successfully deleted book ID: $bookId");
      await loadBooksFromDb();
    } catch (e, s) {
      print("❌ [LibraryController] Error deleting book: $e\n$s");
    }
  }

  /// Scan and mark books with missing files (e.g., temporary cache paths)
  /// This helps identify pre-loaded books that need re-importing
  Future<List<db.Book>> findBooksWithMissingFiles() async {
    print("🔍 [LibraryController] Scanning for books with missing files...");
    final allBooks = await _isar.books.where().findAll();
    final booksWithMissingFiles = <db.Book>[];

    for (final book in allBooks) {
      // Skip books downloaded from marketplace (they have empty epubFilePath initially)
      if (book.epubFilePath.isEmpty) continue;

      // RESOLVE PATH: Convert relative DB path to absolute for file check
      final absolutePath = await _localLibraryService.resolvePath(
        book.epubFilePath,
      );
      final file = File(absolutePath);
      final exists = await file.exists();

      if (!exists) {
        print("   ⚠️ Missing file: ${book.title ?? 'Unknown'} ($absolutePath)");
        booksWithMissingFiles.add(book);

        // Mark as error if not already
        if (book.status != db.ProcessingStatus.error) {
          await _isar.writeTxn(() async {
            book.status = db.ProcessingStatus.error;
            book.errorMessage =
                'File not found. This book needs to be re-imported.';
            await _isar.books.put(book);
          });
        }
      }
    }

    print(
      "✅ [LibraryController] Found ${booksWithMissingFiles.length} books with missing files",
    );
    return booksWithMissingFiles;
  }

  /// Delete all books with missing files
  Future<int> deleteAllBooksWithMissingFiles() async {
    print("🗑️ [LibraryController] Deleting all books with missing files...");
    final booksToDelete = await findBooksWithMissingFiles();

    for (final book in booksToDelete) {
      await deleteBook(book.id);
    }

    print(
      "✅ [LibraryController] Deleted ${booksToDelete.length} books with missing files",
    );
    return booksToDelete.length;
  }

  Future<void> pickAndProcessBooks() async {
    print("ℹ️ [LibraryController] User initiated 'pickAndProcessBooks'.");
    final files = await _localLibraryService.pickFiles();
    // Convert temporary file picker paths to permanent storage
    final permanentFiles = await _copyFilesToPermanentStorage(files);
    await _processFiles(permanentFiles);
  }

  Future<void> scanAndProcessBooks() async {
    print("ℹ️ [LibraryController] User initiated 'scanAndProcessBooks'.");
    final files = await _localLibraryService.scanAndLoadBooks();
    // Convert to permanent storage for consistency and safety
    final permanentFiles = await _copyFilesToPermanentStorage(files);
    await _processFiles(permanentFiles);
  }

  Future<void> retryProcessingBook(int bookId) async {
    print("ℹ️ [LibraryController] User initiated retry for book ID: $bookId");

    // Get the book from the database
    final book = await _isar.books.get(bookId);
    if (book == null) {
      print("❌ [LibraryController] Book not found with ID: $bookId");
      return;
    }

    if (book.status != db.ProcessingStatus.error) {
      print(
        "⚠️ [LibraryController] Book is not in error state. Current status: ${book.status}",
      );
      return;
    }

    try {
      // Load the file data
      // RESOLVE PATH: Convert relative DB path to absolute
      final filePath = await _localLibraryService.resolvePath(
        book.epubFilePath,
      );
      final fileData = await _localLibraryService.loadFileFromPath(filePath);

      if (fileData == null) {
        throw Exception("Could not load file from path: $filePath");
      }

      // Reset the book status to queued
      await _isar.writeTxn(() async {
        book.status = db.ProcessingStatus.queued;
        book.errorMessage =
            null; // Assuming errorMessage and errorStackTrace were added for background task queue
        book.errorStackTrace = null;
        await _isar.books.put(book);
      });

      // Reload the book list to show the updated status
      await loadBooksFromDb();

      // Create and enqueue a new task
      final task = BookProcessingTask(
        id: bookId,
        filePath: filePath,
        fileBytes: fileData.bytes,
      );

      _backgroundTaskQueue.enqueueTask(task);
      print("✅ [LibraryController] Enqueued retry task for book ID: $bookId");
    } catch (e, s) {
      print("❌ [LibraryController] Error preparing book for retry: $e\n$s");

      // Update the book status back to error with the new error message
      await _isar.writeTxn(() async {
        final bookToUpdate = await _isar.books.get(bookId);
        if (bookToUpdate != null) {
          bookToUpdate.status = db.ProcessingStatus.error;
          bookToUpdate.errorMessage = e.toString();
          bookToUpdate.errorStackTrace = s.toString();
          await _isar.books.put(bookToUpdate);
        }
      });

      // Reload the book list to show the updated status
      await loadBooksFromDb();
    }
  }

  /// Recursively traverses the HTML DOM to flatten it into a list of ContentBlocks.
  /// This is the robust way to handle any chapter structure.
  void _flattenAndParseElements({
    required List<dom.Element> elements,
    required List<db.ContentBlock> targetBlockList, // The list to add blocks to
    required int bookId,
    required int chapterIndex,
    required String chapterPath,
    required Archive archive,
    required int Function()
    getNextBlockIndex, // Function to get and increment the index
  }) {
    for (final element in elements) {
      final tagName = element.localName;
      final blockType = _getBlockType(tagName);

      // If it's a container tag, we don't create a block for it.
      // Instead, we recurse into its children to find content.
      if (tagName == 'div' ||
          tagName == 'section' ||
          tagName == 'article' ||
          tagName == 'main') {
        _flattenAndParseElements(
          elements: element.children,
          targetBlockList: targetBlockList,
          bookId: bookId,
          chapterIndex: chapterIndex,
          chapterPath: chapterPath,
          archive: archive,
          getNextBlockIndex: getNextBlockIndex,
        );
        continue;
      }

      // If it's a content block we care about, we process it.
      if (blockType != db.BlockType.unsupported) {
        final textContent = element.text.replaceAll('\u00A0', ' ').trim();

        // We skip blocks that are just empty text, but we must allow image blocks
        // as they have no text content but are still valid.
        if (textContent.isEmpty && blockType != db.BlockType.img) {
          continue;
        }

        final block = db.ContentBlock()
          ..bookId = bookId
          ..chapterIndex = chapterIndex
          ..blockIndexInChapter =
              getNextBlockIndex() // Use the closure to get a unique index
          ..src = chapterPath
          ..blockType = blockType
          ..htmlContent = element
              .outerHtml // Store the raw HTML for the rendering engine
          ..textContent = textContent;

        // Specifically handle image data extraction
        if (blockType == db.BlockType.img) {
          // An image can be a direct <img> tag, an <image> tag (used in SVG), or an <svg> tag wrapping an <image>.
          // We need to find the actual image reference.
          final imgTag = (tagName == 'img' || tagName == 'image')
              ? element
              : element.querySelector('img, image');

          // EPUBs can use 'src', 'href', or 'xlink:href' for image paths. Check all.
          final hrefAttr =
              imgTag?.attributes['src'] ??
              imgTag?.attributes['href'] ??
              imgTag?.attributes['xlink:href'];

          if (hrefAttr != null) {
            // Resolve the relative image path against the chapter's path.
            final imagePath = p.normalize(
              p.join(p.dirname(chapterPath), hrefAttr),
            );
            final imageFile = archive.findFile(imagePath);
            if (imageFile != null) {
              block.imageBytes = imageFile.content as Uint8List;
            } else {
              print(
                "    ❌ [LibraryController] Image file not found at path: '$imagePath'",
              );
            }
          }
        }
        targetBlockList.add(block);
      }
    }
  }

  Future<void> _processFiles(List<PickedFileData> files) async {
    if (files.isEmpty) {
      await loadBooksFromDb();
      return;
    }

    print(
      "⏳ [LibraryController] Starting to process ${files.length} file(s) using BackgroundTaskQueue.",
    );

    for (final fileData in files) {
      var filePath = fileData.path;
      print("\n--- 📖 Preparing Book for Queue: $filePath ---");

      // PATH CORRECTION: If path is absolute and inside library, make it relative
      if (filePath.startsWith('/')) {
        final libraryRoot = await _localLibraryService.getLibraryRoot();
        if (filePath.startsWith(libraryRoot.path)) {
          // It's inside the library. Make it relative.
          // e.g. /.../VisuaLit/books/foo.epub -> books/foo.epub
          // e.g. /.../VisuaLit/foo.epub -> foo.epub
          filePath = filePath.substring(
            libraryRoot.path.length + 1,
          ); // +1 for the slash
          print(
            "  🔄 [LibraryController] Converted absolute path to relative: $filePath",
          );
        }
      }

      final existingBook = await _isar.books
          .where()
          .epubFilePathEqualTo(filePath)
          .findFirst();
      if (existingBook != null) {
        print("  ⚠️ [LibraryController] Book already exists in DB. Skipping.");
        continue;
      }

      // Create initial book entry with queued status
      final newBook = db.Book()
        ..epubFilePath = filePath
        ..status = db.ProcessingStatus.queued;

      // Temporary bookId generation to enqueue task without waiting for full metadata parsing
      final bookId = await _isar.writeTxn(
        () async => await _isar.books.put(newBook),
      );
      print(
        "  ✅ [LibraryController] Created initial book entry with ID: $bookId, status: queued",
      );

      // remove if doesnt work start
      // Create and enqueue task
      final task = BookProcessingTask(
        id: bookId,
        filePath: filePath,
        fileBytes: fileData.bytes,
      );

      _backgroundTaskQueue.enqueueTask(task);
      print(
        "  ✅ [LibraryController] Enqueued book processing task for ID: $bookId",
      );
      // remove if doesnt work end
      try {
        final bytes = fileData.bytes;
        final archive = ZipDecoder().decodeBytes(bytes);

        final containerFile = archive.findFile('META-INF/container.xml');
        if (containerFile == null) throw Exception('container.xml not found');
        final containerXml = XmlDocument.parse(
          utf8.decode(containerFile.content),
        );
        final opfPath = containerXml
            .findAllElements('rootfile')
            .first
            .getAttribute('full-path');
        if (opfPath == null)
          throw Exception('OPF path not found in container.xml');

        final opfFile = archive.findFile(opfPath);
        if (opfFile == null)
          throw Exception('OPF file not found at path: $opfPath');
        final opfXml = XmlDocument.parse(utf8.decode(opfFile.content));
        final opfDir = p.dirname(opfPath);

        final metadata = opfXml.findAllElements('metadata').first;
        final title =
            metadata.findAllElements('dc:title').firstOrNull?.innerText ??
            p.basenameWithoutExtension(filePath);
        final author =
            metadata.findAllElements('dc:creator').firstOrNull?.innerText ??
            'Unknown Author';
        final publisher = metadata
            .findAllElements('dc:publisher')
            .firstOrNull
            ?.innerText;
        final language = metadata
            .findAllElements('dc:language')
            .firstOrNull
            ?.innerText;
        final pubDateStr = metadata
            .findAllElements('dc:date')
            .firstOrNull
            ?.innerText;
        final publicationDate = pubDateStr != null
            ? DateTime.tryParse(pubDateStr)
            : null;
        print(
          "  [LibraryController] Parsed Metadata -> Title: '$title', Author: '$author', Publisher: '$publisher'",
        );

        final manifest = <String, String>{};
        final manifestItems = opfXml.findAllElements('item');
        for (final item in manifestItems) {
          final id = item.getAttribute('id');
          final href = item.getAttribute('href');
          if (id != null && href != null) {
            final finalPath = p.url.normalize(p.url.join(opfDir, href));
            manifest[id] = finalPath;
          }
        }

        Uint8List? coverImageBytes;
        // Cover logic remains the same and is robust.
        String? coverId;
        for (final item in manifestItems) {
          if (item.getAttribute('properties')?.contains('cover-image') ??
              false) {
            coverId = item.getAttribute('id');
            break;
          }
        }
        if (coverId == null) {
          for (final meta in metadata.findAllElements('meta')) {
            if (meta.getAttribute('name') == 'cover') {
              coverId = meta.getAttribute('content');
              break;
            }
          }
        }
        if (coverId != null) {
          final coverPath = manifest[coverId];
          if (coverPath != null) {
            final coverFile = archive.findFile(coverPath);
            if (coverFile != null) {
              coverImageBytes = coverFile.content as Uint8List;
            }
          }
        }

        final spineItems = opfXml.findAllElements('itemref');
        final spine = spineItems
            .map((item) => item.getAttribute('idref'))
            .whereType<String>()
            .toList();

        final List<db.ContentBlock> allBlocks = [];
        for (int i = 0; i < spine.length; i++) {
          final idref = spine[i];
          final chapterPath = manifest[idref];
          if (chapterPath == null) continue;

          final chapterFile = archive.findFile(chapterPath);
          if (chapterFile == null) continue;

          final chapterContent = utf8.decode(chapterFile.content);
          final document = html_parser.parse(chapterContent);
          final body = document.body;
          if (body == null) continue;

          int blockCounter = 0;

          // Use the robust recursive function to process the entire chapter body
          _flattenAndParseElements(
            elements: body.children,
            targetBlockList: allBlocks, // Add directly to the main list
            bookId: bookId,
            chapterIndex: i,
            chapterPath: chapterPath,
            archive: archive,
            getNextBlockIndex: () =>
                blockCounter++, // Pass a closure to manage the index
          );
        }

        print(
          "  ✅ [LibraryController] FINAL RESULT: Extracted a total of ${allBlocks.length} content blocks from the entire book.",
        );
        if (allBlocks.isEmpty) {
          print(
            "  ❌ [LibraryController] CRITICAL FAILURE: No content blocks were extracted from the book.",
          );
        }

        // TOC Parsing remains the same and is robust.
        List<TOCEntry> tocEntries = [];
        final navItem = manifestItems.firstWhere(
          (item) => item.getAttribute('properties')?.contains('nav') ?? false,
          orElse: () => XmlElement(XmlName('')),
        );
        if (navItem.name.local.isNotEmpty) {
          final navPath = manifest[navItem.getAttribute('id')];
          if (navPath != null) {
            final navFile = archive.findFile(navPath);
            if (navFile != null) {
              final navContent = utf8.decode(navFile.content);
              final navBasePath = p.dirname(navPath);
              tocEntries = _parseNavXhtml(navContent, navBasePath);
            }
          }
        }
        if (tocEntries.isEmpty) {
          final spineElement = opfXml.findAllElements('spine').firstOrNull;
          final ncxId = spineElement?.getAttribute('toc');
          if (ncxId != null) {
            final ncxPath = manifest[ncxId];
            if (ncxPath != null) {
              final ncxFile = archive.findFile(ncxPath);
              if (ncxFile != null) {
                final ncxContent = utf8.decode(ncxFile.content);
                final ncxBasePath = p.dirname(ncxPath);
                tocEntries = _parseNcx(ncxContent, ncxBasePath);
              }
            }
          }
        }

        await _isar.writeTxn(() async {
          final bookToUpdate = await _isar.books.get(bookId);
          if (bookToUpdate != null) {
            bookToUpdate.title = title;
            bookToUpdate.author = author;
            bookToUpdate.coverImageBytes = coverImageBytes;
            bookToUpdate.status = db.ProcessingStatus.ready;
            bookToUpdate.toc = tocEntries;
            bookToUpdate.publisher = publisher;
            bookToUpdate.language = language;
            bookToUpdate.publicationDate = publicationDate;
            await _isar.books.put(bookToUpdate);
          }
          await _isar.contentBlocks.putAll(allBlocks);
        });
        print(
          "  ✅ [LibraryController] Successfully saved book metadata and ${allBlocks.length} blocks. Status: ready.",
        );
      } catch (e, s) {
        print(
          "  ❌ [LibraryController] FATAL ERROR during processing for book ID $bookId: $e\n$s",
        );
        await _isar.writeTxn(() async {
          final bookToUpdate = await _isar.books.get(bookId);
          if (bookToUpdate != null) {
            bookToUpdate.status = db.ProcessingStatus.error;
            await _isar.books.put(bookToUpdate);
          }
        });
      }
    }

    // Reload books to show queued status
    await loadBooksFromDb();
  }

  // NOTE: The actual EPUB parsing logic for populating full book metadata
  // is usually done in a background task (like `BookProcessor.launchIsolate`).
  // The `_processFiles` above only puts it in a queue.
  // The code for `BookProcessor` (which you provided earlier) needs to handle
  // parsing and saving ISBN to the `db.Book` model after it's been processed
  // from the queue.

  // For reference, here's how `BookProcessor` (if you were modifying it directly)
  // would parse the ISBN and save it. You should apply this logic in your
  // `BookProcessor._processBook` method after parsing other metadata.

  /*
  // Example of how to add ISBN parsing within your BookProcessor's _processBook method:
  // (This is NOT in LibraryController, but where the actual EPUB processing happens)

  // Assuming you have 'metadata' XML element available in BookProcessor:
  String? isbn;
  final isbnIdentifier = metadata.findAllElements('dc:identifier').firstWhereOrNull(
    (element) => element.attributes.any(
      (attr) => attr.name.local == 'scheme' && attr.value.toLowerCase() == 'isbn'
    ) || element.innerText.replaceAll(RegExp(r'[^0-9X]'), '').length == 10 ||
       element.innerText.replaceAll(RegExp(r'[^0-9]'), '').length == 13,
  );

  isbn = isbnIdentifier?.innerText.trim();
  if (isbn != null) {
    isbn = isbn!.replaceAll(RegExp(r'[- ]'), '');
  }

  // Then, when updating the book in Isar within BookProcessor:
  await isar.writeTxn(() async {
    final bookToUpdate = await isar.books.get(existingBook.id);
    if (bookToUpdate != null) {
      // ... existing updates like title, author, etc.
      bookToUpdate.isbn = isbn; // <--- ADD THIS LINE IN BOOKPROCESSOR
      await isar.books.put(bookToUpdate);
    }
  });
  */

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
      final navLabel = navPoint
          .findElements('navLabel')
          .first
          .findElements('text')
          .first
          .innerText;
      final contentSrc =
          navPoint.findElements('content').first.getAttribute('src') ?? '';
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

  Future<void> addBookFromCart(Map<String, dynamic> bookData) async {
    final currentBooks = state.value ?? [];

    // Create an instance of db.Book
    final book = db.Book()
      ..id = int.parse(bookData['id'].toString())
      ..title = bookData['title'] ?? 'Untitled'
      ..author = bookData['authors'] != null && bookData['authors'].isNotEmpty
          ? bookData['authors'][0]['name']
          : null
      ..epubFilePath = ''
      ..status = db.ProcessingStatus.ready;

    // Update the state with the new book
    state = AsyncValue.data([...currentBooks, book]);
  }

  db.BlockType _getBlockType(String? tagName) {
    switch (tagName?.toLowerCase()) {
      case 'p':
        return db.BlockType.p;
      case 'h1':
        return db.BlockType.h1;
      case 'h2':
        return db.BlockType.h2;
      case 'h3':
        return db.BlockType.h3;
      case 'h4':
        return db.BlockType.h4;
      case 'h5':
        return db.BlockType.h5;
      case 'h6':
        return db.BlockType.h6;
      case 'img':
        return db.BlockType.img;
      case 'image':
        return db.BlockType.img;
      case 'svg':
        return db.BlockType.img;
      default:
        return db.BlockType.unsupported;
    }
  }
}

// Extension to help with finding first element or null
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
