import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/dom.dart' as dom;
import 'package:isar/isar.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/library/data/local_library_service.dart';
import 'package:visualit/features/reader/data/book_data.dart' as db;
import 'package:visualit/features/reader/data/toc_entry.dart';
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

  Future<void> _processFiles(List<PickedFileData> files) async {
    if (files.isEmpty) {
      print("ℹ️ [LibraryController] No new files to process.");
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
        print("  [LibraryController] Unzipping ${bytes.lengthInBytes} bytes...");
        final archive = ZipDecoder().decodeBytes(bytes);

        final containerFile = archive.findFile('META-INF/container.xml');
        if (containerFile == null) throw Exception('container.xml not found');
        final containerXml = XmlDocument.parse(String.fromCharCodes(containerFile.content));
        final opfPath = containerXml.findAllElements('rootfile').first.getAttribute('full-path');
        if (opfPath == null) throw Exception('OPF path not found in container.xml');
        print("  [LibraryController] Found OPF path: '$opfPath'");

        final opfFile = archive.findFile(opfPath);
        if (opfFile == null) throw Exception('OPF file not found at path: $opfPath');
        final opfXml = XmlDocument.parse(String.fromCharCodes(opfFile.content));
        final opfDir = p.dirname(opfPath);
        print("  [LibraryController] OPF directory is: '$opfDir'");

        final metadata = opfXml.findAllElements('metadata').first;
        final title = metadata.findAllElements('dc:title').firstOrNull?.innerText ?? p.basenameWithoutExtension(filePath);
        final author = metadata.findAllElements('dc:creator').firstOrNull?.innerText ?? 'Unknown Author';
        print("  [LibraryController] Parsed Metadata -> Title: '$title', Author: '$author'");

        final manifest = <String, String>{};
        print("  [LibraryController] Building manifest map...");
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
        String? coverId;

        print("  [LibraryController] Searching for cover via EPUB 3 method (properties='cover-image')...");
        for (final item in manifestItems) {
          if (item.getAttribute('properties')?.contains('cover-image') ?? false) {
            coverId = item.getAttribute('id');
            print("    ✅ Found cover ID: '$coverId'");
            break;
          }
        }

        if (coverId == null) {
          print("  [LibraryController] EPUB 3 cover not found. Searching for cover via EPUB 2 method (meta name='cover')...");
          for (final meta in metadata.findAllElements('meta')) {
            if (meta.getAttribute('name') == 'cover') {
              coverId = meta.getAttribute('content');
              print("    ✅ Found cover ID: '$coverId'");
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
              print("  [LibraryController] Successfully loaded cover image from '$coverPath' (${coverImageBytes.lengthInBytes} bytes).");
            } else {
              print("  ❌ [LibraryController] Cover ID was found, but the file at path '$coverPath' is missing from the archive.");
            }
          } else {
            print("  ❌ [LibraryController] Cover ID '$coverId' was found in metadata, but it's missing from the manifest.");
          }
        } else {
          print("  ⚠️ [LibraryController] Could not find a cover image reference in this EPUB.");
        }

        final spineItems = opfXml.findAllElements('itemref');
        final spine = spineItems.map((item) => item.getAttribute('idref')).whereType<String>().toList();
        print("  [LibraryController] Found ${spine.length} items in spine.");

        final List<db.ContentBlock> allBlocks = [];
        for (int i = 0; i < spine.length; i++) {
          final idref = spine[i];
          final chapterPath = manifest[idref];

          if (chapterPath == null) {
            print("    ⚠️ [LibraryController] Spine item '$idref' has no path in manifest. Skipping.");
            continue;
          }

          final chapterFile = archive.findFile(chapterPath);
          if (chapterFile == null) {
            print("    ❌ [LibraryController] Chapter file NOT FOUND in archive: '${chapterPath}'. Skipping.");
            continue;
          }

          final chapterContent = String.fromCharCodes(chapterFile.content);
          final document = html_parser.parse(chapterContent);
          final body = document.body;
          if (body == null) {
            print("    ⚠️ [LibraryController] Chapter '$chapterPath' has no <body> tag. Skipping.");
            continue;
          }

          final elements = body.querySelectorAll('p, h1, h2, h3, h4, h5, h6');

          for (int j = 0; j < elements.length; j++) {
            final element = elements[j];
            final textContent = element.text.replaceAll('\u00A0', ' ').trim();
            if (textContent.isNotEmpty) {
              final block = db.ContentBlock()
                ..bookId = bookId
                ..chapterIndex = i
                ..blockIndexInChapter = j
                ..src = chapterPath
                ..blockType = _getBlockType(element.localName)
                ..htmlContent = element.outerHtml
                ..textContent = textContent;
              allBlocks.add(block);
            }
          }
        }

        print("  ✅ [LibraryController] FINAL RESULT: Extracted a total of ${allBlocks.length} content blocks from all chapters.");
        if (allBlocks.isEmpty) {
          print("  ❌ [LibraryController] CRITICAL FAILURE: No content blocks were extracted from the entire book.");
        }

        // ======================= TOC PARSING LOGIC - START =======================
        print("\n  [LibraryController] Starting TOC Parsing...");
        List<TOCEntry> tocEntries = [];

        // Method 1: Look for EPUB 3 Navigation Document (nav.xhtml)
        final navItem = manifestItems.firstWhere(
              (item) => item.getAttribute('properties')?.contains('nav') ?? false,
          orElse: () => XmlElement(XmlName('')), // Return a dummy element if not found
        );

        if (navItem.name.local.isNotEmpty) {
          final navPath = manifest[navItem.getAttribute('id')];
          if (navPath != null) {
            final navFile = archive.findFile(navPath);
            if (navFile != null) {
              print("    ✅ Found EPUB 3 nav file at '$navPath'. Parsing...");
              final navContent = String.fromCharCodes(navFile.content);
              final navBasePath = p.dirname(navPath);
              tocEntries = _parseNavXhtml(navContent, navBasePath);
            }
          }
        }

        // Method 2: Fallback to EPUB 2 NCX file if no nav file was found
        if (tocEntries.isEmpty) {
          print("  [LibraryController] EPUB 3 nav not found. Looking for EPUB 2 NCX file...");
          final spineElement = opfXml.findAllElements('spine').firstOrNull;
          final ncxId = spineElement?.getAttribute('toc');
          if (ncxId != null) {
            final ncxPath = manifest[ncxId];
            if (ncxPath != null) {
              final ncxFile = archive.findFile(ncxPath);
              if (ncxFile != null) {
                print("    ✅ Found EPUB 2 NCX file at '$ncxPath'. Parsing...");
                final ncxContent = String.fromCharCodes(ncxFile.content);
                final ncxBasePath = p.dirname(ncxPath);
                tocEntries = _parseNcx(ncxContent, ncxBasePath);
              }
            }
          }
        }

        if (tocEntries.isNotEmpty) {
          print("  ✅ [LibraryController] Successfully parsed ${tocEntries.length} top-level TOC entries.");
        } else {
          print("  ⚠️ [LibraryController] Could not find or parse a TOC for this book.");
        }
        // ======================= TOC PARSING LOGIC - END =========================

        await _isar.writeTxn(() async {
          final bookToUpdate = await _isar.books.get(bookId);
          if (bookToUpdate != null) {
            bookToUpdate.title = title;
            bookToUpdate.author = author;
            bookToUpdate.coverImageBytes = coverImageBytes;
            bookToUpdate.status = db.ProcessingStatus.ready;
            bookToUpdate.toc = tocEntries; // Save the parsed TOC
            await _isar.books.put(bookToUpdate);
          }
          await _isar.contentBlocks.putAll(allBlocks);
        });
        print("  ✅ [LibraryController] Successfully saved book metadata and ${allBlocks.length} blocks. Status: ready.");

      } catch (e, s) {
        print("  ❌ [LibraryController] FATAL ERROR during processing for book ID $bookId: $e\n$s");
        await _isar.writeTxn(() async {
          final bookToUpdate = await _isar.books.get(bookId);
          if (bookToUpdate != null) {
            bookToUpdate.status = db.ProcessingStatus.error;
            await _isar.books.put(bookToUpdate);
            print("  [LibraryController] Updated book status to: error.");
          }
        });
      }
    }
    await loadBooksFromDb();
  }

  // Helper methods (_parseNavXhtml, _parseNcx, _getBlockType) remain the same
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
      default: return db.BlockType.unsupported;
    }
  }
}