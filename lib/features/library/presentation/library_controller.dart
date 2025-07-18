import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/dom.dart' as dom;
import 'package:isar/isar.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/library/data/local_library_service.dart';
import 'package:visualit/features/reader/data/book_data.dart' as db;
import 'package:visualit/features/reader/data/toc_entry.dart';
import 'package:visualit/features/reader/data/chapter_content.dart';
import 'package:visualit/features/reader/data/book_image.dart';
import 'package:visualit/features/reader/data/book_styling.dart';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:path/path.dart' as p;

final localLibraryServiceProvider = Provider<LocalLibraryService>((ref) {
  return LocalLibraryService();
});

final libraryControllerProvider = StateNotifierProvider.autoDispose<LibraryController, AsyncValue<List<db.Book>>>(
        (ref) {
      final isar = ref.watch(isarDBProvider).requireValue;
      final localLibraryService = ref.watch(localLibraryServiceProvider);
      return LibraryController(localLibraryService, isar);
    }
);

class LibraryController extends StateNotifier<AsyncValue<List<db.Book>>> {
  final LocalLibraryService _localLibraryService;
  final Isar _isar;

  LibraryController(this._localLibraryService, this._isar) : super(const AsyncValue.loading()) {
    print("✅ [LibraryController] Initialized.");
    loadBooksFromDb();
  }

  Future<void> loadBooksFromDb() async {
    print("🔄 [LibraryController] Loading all books from database...");
    state = const AsyncValue.loading();
    try {
      final books = await _isar.books.where().sortByTitle().findAll();
      print("  [LibraryController] Found ${books.length} books in DB.");
      state = AsyncValue.data(books);
    } catch (e, st) {
      print("❌ [LibraryController] FATAL ERROR loading books: $e");
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> pickAndProcessBooks() async {
    print("ℹ️ [LibraryController] User initiated 'pickAndProcessBooks'.");
    final files = await _localLibraryService.pickFiles();
    await _processFiles(files);
  }

  Future<void> scanAndProcessBooks() async {
    print("ℹ️ [LibraryController] User initiated 'scanAndProcessBooks'.");
    final files = await _localLibraryService.scanAndLoadBooks();
    await _processFiles(files);
  }

  // EPUB View handles content rendering directly, so we don't need to extract content blocks
  // This method has been removed as it's no longer needed for EPUB View rendering

  Future<void> _processFiles(List<PickedFileData> files) async {
    if (files.isEmpty) {
      await loadBooksFromDb();
      return;
    }

    print("⏳ [LibraryController] Starting to process ${files.length} file(s).");

    for (final fileData in files) {
      final filePath = fileData.path;
      print("\n--- 📖 Processing Book: $filePath ---");

      final existingBook = await _isar.books.where().epubFilePathEqualTo(filePath).findFirst();
      if (existingBook != null) {
        print("  ⚠️ [LibraryController] Book already exists in DB. Skipping.");
        continue;
      }

      final newBook = db.Book()
        ..epubFilePath = filePath
        ..status = db.ProcessingStatus.processing;

      final bookId = await _isar.writeTxn(() async => await _isar.books.put(newBook));
      print("  ✅ [LibraryController] Created initial book entry with ID: $bookId, status: processing");
      await loadBooksFromDb();

      try {
        final bytes = fileData.bytes;
        final archive = ZipDecoder().decodeBytes(bytes);

        final containerFile = archive.findFile('META-INF/container.xml');
        if (containerFile == null) throw Exception('container.xml not found');
        final containerXml = XmlDocument.parse(String.fromCharCodes(containerFile.content));
        final rootfiles = containerXml.findAllElements('rootfile');
        if (rootfiles.isEmpty) throw Exception('No rootfile element found in container.xml');
        final opfPath = rootfiles.first.getAttribute('full-path');
        if (opfPath == null) throw Exception('OPF path not found in container.xml');

        final opfFile = archive.findFile(opfPath);
        if (opfFile == null) throw Exception('OPF file not found at path: $opfPath');
        final opfXml = XmlDocument.parse(String.fromCharCodes(opfFile.content));
        final opfDir = p.dirname(opfPath);

        final metadataElements = opfXml.findAllElements('metadata');
        if (metadataElements.isEmpty) throw Exception('No metadata element found in OPF file');
        final metadata = metadataElements.first;
        final title = metadata.findAllElements('dc:title').firstOrNull?.innerText ?? p.basenameWithoutExtension(filePath);
        final author = metadata.findAllElements('dc:creator').firstOrNull?.innerText ?? 'Unknown Author';
        final publisher = metadata.findAllElements('dc:publisher').firstOrNull?.innerText;
        final language = metadata.findAllElements('dc:language').firstOrNull?.innerText;
        final pubDateStr = metadata.findAllElements('dc:date').firstOrNull?.innerText;
        final publicationDate = pubDateStr != null ? DateTime.tryParse(pubDateStr) : null;

        // Extract ISBN from metadata
        String? isbn;
        final identifiers = metadata.findAllElements('dc:identifier');
        for (final identifier in identifiers) {
          final scheme = identifier.getAttribute('opf:scheme')?.toLowerCase();
          if (scheme == 'isbn' || identifier.innerText.toLowerCase().contains('isbn')) {
            isbn = identifier.innerText.replaceAll(RegExp(r'[^\d]'), '');
            break;
          }
        }

        print("  [LibraryController] Parsed Metadata -> Title: '$title', Author: '$author', Publisher: '$publisher', ISBN: '$isbn'");

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
          if (item.getAttribute('properties')?.contains('cover-image') ?? false) {
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
          if(coverPath != null) {
            final coverFile = archive.findFile(coverPath);
            if (coverFile != null) {
              coverImageBytes = coverFile.content as Uint8List;
            }
          }
        }

        final spineItems = opfXml.findAllElements('itemref');
        final spine = spineItems.map((item) => item.getAttribute('idref')).whereType<String>().toList();

        // Extract chapter content
        List<ChapterContent> chapters = [];
        for (final spineItemId in spine) {
          final path = manifest[spineItemId];
          if (path != null) {
            final file = archive.findFile(path);
            if (file != null) {
              final content = String.fromCharCodes(file.content);
              final document = html_parser.parse(content);

              // Extract text content
              final textContent = document.body?.text ?? '';

              // Create chapter content
              final chapter = ChapterContent(
                title: p.basenameWithoutExtension(path),
                src: path,
                textContent: textContent,
                htmlContent: content,
                bookId: bookId, // Set the bookId for the relationship
              );

              chapters.add(chapter);
              print("  ✅ [LibraryController] Extracted content for chapter: ${chapter.title}");
            }
          }
        }

        // Extract images (other than cover)
        List<BookImage> images = [];
        for (final item in manifestItems) {
          final href = item.getAttribute('href');
          final mediaType = item.getAttribute('media-type');

          if (href != null && mediaType != null && 
              mediaType.startsWith('image/') && 
              manifest[coverId] != p.url.normalize(p.url.join(opfDir, href))) {

            final imagePath = p.url.normalize(p.url.join(opfDir, href));
            final imageFile = archive.findFile(imagePath);

            if (imageFile != null) {
              final image = BookImage(
                src: imagePath,
                name: p.basename(href),
                mimeType: mediaType,
                imageBytes: imageFile.content as Uint8List,
              );

              images.add(image);
              print("  ✅ [LibraryController] Extracted image: ${image.name}");
            }
          }
        }

        // Extract styling information
        List<StyleSheet> styleSheets = [];
        for (final item in manifestItems) {
          final href = item.getAttribute('href');
          final mediaType = item.getAttribute('media-type');

          if (href != null && mediaType != null && 
              (mediaType == 'text/css' || href.endsWith('.css'))) {

            final cssPath = p.url.normalize(p.url.join(opfDir, href));
            final cssFile = archive.findFile(cssPath);

            if (cssFile != null) {
              final styleSheet = StyleSheet(
                href: cssPath,
                content: String.fromCharCodes(cssFile.content),
              );

              styleSheets.add(styleSheet);
              print("  ✅ [LibraryController] Extracted stylesheet: ${styleSheet.href}");
            }
          }
        }

        final bookStyling = BookStyling(styleSheets: styleSheets);

        print("  ✅ [LibraryController] EPUB file processed successfully.");
        print("  ℹ️ [LibraryController] Book contains ${spine.length} spine items, ${chapters.length} chapters, ${images.length} images, and ${styleSheets.length} stylesheets.");

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
              final navContent = String.fromCharCodes(navFile.content);
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
                final ncxContent = String.fromCharCodes(ncxFile.content);
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
            bookToUpdate.isbn = isbn;

            // Save the extracted content
            bookToUpdate.images = images;
            bookToUpdate.styling = bookStyling;

            // Save the book first
            await _isar.books.put(bookToUpdate);

            // Save chapters separately and link them to the book
            // We'll handle chapters differently to avoid issues with IsarLinks

            // Save each chapter and link it to the book
            for (final chapter in chapters) {
              // Save the chapter to get an ID
              final chapterId = await _isar.chapterContents.put(chapter);

              // Get the saved chapter and link it to the book
              final savedChapter = await _isar.chapterContents.get(chapterId);
              if (savedChapter != null) {
                await bookToUpdate.chapters.add(savedChapter);
              }
            }

            // Save the book again to update the links
            await _isar.books.put(bookToUpdate);

            print("  ✅ [LibraryController] Saved book with ${chapters.length} chapters, ${images.length} images, and ${bookStyling.styleSheets.length} stylesheets.");
          }
        });
        print("  ✅ [LibraryController] Successfully saved book metadata. Status: ready.");

      } catch (e, s) {
        print("  ❌ [LibraryController] FATAL ERROR during processing for book ID $bookId: $e\n$s");
        await _isar.writeTxn(() async {
          final bookToUpdate = await _isar.books.get(bookId);
          if (bookToUpdate != null) {
            bookToUpdate.status = db.ProcessingStatus.error;
            await _isar.books.put(bookToUpdate);
          }
        });
      }
    }
    await loadBooksFromDb();
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
      final src = parts.isNotEmpty && parts[0].isNotEmpty ? parts[0] : null;
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
    final navMaps = document.findAllElements('navMap');
    if (navMaps.isEmpty) return [];
    final navMap = navMaps.first;
    return _parseNavPoints(navMap.findElements('navPoint').toList(), basePath);
  }

  List<TOCEntry> _parseNavPoints(List<XmlElement> navPoints, String basePath) {
    final entries = <TOCEntry>[];
    for (final navPoint in navPoints) {
      // Safely extract navLabel
      final navLabels = navPoint.findElements('navLabel');
      if (navLabels.isEmpty) continue;
      final textElements = navLabels.first.findElements('text');
      if (textElements.isEmpty) continue;
      final navLabel = textElements.first.innerText;

      // Safely extract contentSrc
      final contentElements = navPoint.findElements('content');
      if (contentElements.isEmpty) continue;
      final contentSrc = contentElements.first.getAttribute('src') ?? '';
      final parts = contentSrc.split('#');
      final src = parts.isNotEmpty && parts[0].isNotEmpty ? parts[0] : null;
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

}
