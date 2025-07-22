import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/library/data/local_library_service.dart';
import 'package:visualit/features/reader/data/book_data.dart' as db;
import 'package:visualit/features/reader/data/toc_entry.dart';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
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

  /// Recursively traverses the HTML DOM to flatten it into a list of ContentBlocks.
  /// This is the robust way to handle any chapter structure.
  void _flattenAndParseElements({
    required List<dom.Element> elements,
    required List<db.ContentBlock> targetBlockList, // The list to add blocks to
    required int bookId,
    required int chapterIndex,
    required String chapterPath,
    required Archive archive,
    required int Function() getNextBlockIndex, // Function to get and increment the index
  }) {
    for (final element in elements) {
      final tagName = element.localName;
      final blockType = _getBlockType(tagName);

      // If it's a container tag, we don't create a block for it.
      // Instead, we recurse into its children to find content.
      if (tagName == 'div' || tagName == 'section' || tagName == 'article' || tagName == 'main') {
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
          ..blockIndexInChapter = getNextBlockIndex() // Use the closure to get a unique index
          ..src = chapterPath
          ..blockType = blockType
          ..htmlContent = element.outerHtml // Store the raw HTML for the rendering engine
          ..textContent = textContent;

        // Specifically handle image data extraction
        if (blockType == db.BlockType.img) {
          // An image can be a direct <img> tag, an <image> tag (used in SVG), or an <svg> tag wrapping an <image>.
          // We need to find the actual image reference.
          final imgTag = (tagName == 'img' || tagName == 'image')
              ? element
              : element.querySelector('img, image');

          // EPUBs can use 'src', 'href', or 'xlink:href' for image paths. Check all.
          final hrefAttr = imgTag?.attributes['src'] ?? imgTag?.attributes['href'] ?? imgTag?.attributes['xlink:href'];

          if (hrefAttr != null) {
            // Resolve the relative image path against the chapter's path.
            final imagePath = p.normalize(p.join(p.dirname(chapterPath), hrefAttr));
            final imageFile = archive.findFile(imagePath);
            if (imageFile != null) {
              block.imageBytes = imageFile.content as Uint8List;
            } else {
              print("    ❌ [LibraryController] Image file not found at path: '$imagePath'");
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
        final containerXml = XmlDocument.parse(utf8.decode(containerFile.content));
        final opfPath = containerXml.findAllElements('rootfile').first.getAttribute('full-path');
        if (opfPath == null) throw Exception('OPF path not found in container.xml');

        final opfFile = archive.findFile(opfPath);
        if (opfFile == null) throw Exception('OPF file not found at path: $opfPath');
        final opfXml = XmlDocument.parse(utf8.decode(opfFile.content));
        final opfDir = p.dirname(opfPath);

        final metadata = opfXml.findAllElements('metadata').first;
        final title = metadata.findAllElements('dc:title').firstOrNull?.innerText ?? p.basenameWithoutExtension(filePath);
        final author = metadata.findAllElements('dc:creator').firstOrNull?.innerText ?? 'Unknown Author';
        final publisher = metadata.findAllElements('dc:publisher').firstOrNull?.innerText;
        final language = metadata.findAllElements('dc:language').firstOrNull?.innerText;
        final pubDateStr = metadata.findAllElements('dc:date').firstOrNull?.innerText;
        final publicationDate = pubDateStr != null ? DateTime.tryParse(pubDateStr) : null;
        print("  [LibraryController] Parsed Metadata -> Title: '$title', Author: '$author', Publisher: '$publisher'");

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
            getNextBlockIndex: () => blockCounter++, // Pass a closure to manage the index
          );
        }

        print("  ✅ [LibraryController] FINAL RESULT: Extracted a total of ${allBlocks.length} content blocks from the entire book.");
        if (allBlocks.isEmpty) {
          print("  ❌ [LibraryController] CRITICAL FAILURE: No content blocks were extracted from the book.");
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
        print("  ✅ [LibraryController] Successfully saved book metadata and ${allBlocks.length} blocks. Status: ready.");

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
      case 'image': return db.BlockType.img;
      case 'svg': return db.BlockType.img;
      default: return db.BlockType.unsupported;
    }
  }
}