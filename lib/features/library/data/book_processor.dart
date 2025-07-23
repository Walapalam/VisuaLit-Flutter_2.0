import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:path/path.dart' as p;
import 'package:visualit/features/library/data/parsed_book_dto.dart';
import 'package:visualit/features/reader/data/book_data.dart' as db;
import 'package:visualit/features/reader/data/toc_entry.dart';
import 'package:xml/xml.dart';

/// This top-level function is the entry point for the background isolate.
/// It takes the raw bytes of an EPUB file and returns a structured DTO.
Future<ParsedBookDTO> processEpub(Uint8List fileBytes) async {
  print("ISO_PROC: Isolate started. Processing EPUB from bytes.");

  final archive = ZipDecoder().decodeBytes(fileBytes);

  // 1. Find and parse container.xml to get the OPF file path
  final containerFile = archive.findFile('META-INF/container.xml');
  if (containerFile == null) throw Exception('container.xml not found');
  final containerXml = XmlDocument.parse(utf8.decode(containerFile.content));
  final opfPath = containerXml.findAllElements('rootfile').first.getAttribute('full-path');
  if (opfPath == null) throw Exception('OPF path not found in container.xml');
  print("ISO_PROC: Found OPF path: $opfPath");

  // 2. Find and parse the .opf file
  final opfFile = archive.findFile(opfPath);
  if (opfFile == null) throw Exception('OPF file not found at path: $opfPath');
  final opfXml = XmlDocument.parse(utf8.decode(opfFile.content));
  final opfDir = p.dirname(opfPath);

  // 3. Extract Metadata
  final metadata = opfXml.findAllElements('metadata').first;
  final title = metadata.findAllElements('dc:title').firstOrNull?.innerText ?? 'Untitled';
  final author = metadata.findAllElements('dc:creator').firstOrNull?.innerText ?? 'Unknown Author';
  final publisher = metadata.findAllElements('dc:publisher').firstOrNull?.innerText;
  final language = metadata.findAllElements('dc:language').firstOrNull?.innerText;
  final pubDateStr = metadata.findAllElements('dc:date').firstOrNull?.innerText;
  final publicationDate = pubDateStr != null ? DateTime.tryParse(pubDateStr) : null;
  print("ISO_PROC: Parsed Metadata -> Title: '$title', Author: '$author'");

  // 4. Parse the Manifest (a map of file IDs to their paths)
  final manifest = <String, String>{};
  final manifestItems = opfXml.findAllElements('item');
  for (final item in manifestItems) {
    final id = item.getAttribute('id');
    final href = item.getAttribute('href');
    if (id != null && href != null) {
      manifest[id] = p.url.normalize(p.url.join(opfDir, href));
    }
  }

  // 5. Extract Cover Image
  Uint8List? coverImageBytes;
  String? coverId;
  for (final item in manifestItems) {
    if (item.getAttribute('properties')?.contains('cover-image') ?? false) {
      coverId = item.getAttribute('id');
      break;
    }
  }
  coverId ??= metadata.findAllElements('meta').firstWhere(
        (meta) => meta.getAttribute('name') == 'cover',
    orElse: () => XmlElement(XmlName('')),
  ).getAttribute('content');

  if (coverId != null && manifest[coverId] != null) {
    final coverFile = archive.findFile(manifest[coverId]!);
    if (coverFile != null) {
      coverImageBytes = coverFile.content as Uint8List;
      print("ISO_PROC: Found and extracted cover image.");
    }
  }

  // 6. Atomize Content by parsing the book's spine
  final spineItems = opfXml.findAllElements('itemref');
  final spine = spineItems.map((item) => item.getAttribute('idref')).whereType<String>().toList();
  final List<ParsedContentBlockDTO> allBlocks = [];

  for (int i = 0; i < spine.length; i++) {
    final chapterPath = manifest[spine[i]];
    if (chapterPath == null) continue;

    final chapterFile = archive.findFile(chapterPath);
    if (chapterFile == null) continue;

    final document = html_parser.parse(utf8.decode(chapterFile.content));
    if (document.body == null) continue;

    int blockCounter = 0;
    _flattenAndParseElements(
        elements: document.body!.children,
        targetBlockList: allBlocks,
        chapterIndex: i,
        chapterPath: chapterPath,
        archive: archive,
        getNextBlockIndex: () => blockCounter++);
  }
  print("ISO_PROC: Atomized content into ${allBlocks.length} blocks.");

  // 7. Parse Table of Contents (NCX or NAV)
  List<TOCEntry> tocEntries = [];
  final navItemId = manifestItems.firstWhere(
        (item) => item.getAttribute('properties')?.contains('nav') ?? false,
    orElse: () => XmlElement(XmlName('')),
  ).getAttribute('id');

  if (navItemId != null && manifest[navItemId] != null) {
    // Modern NAV parsing
    final navFile = archive.findFile(manifest[navItemId]!);
    if (navFile != null) {
      tocEntries = _parseNavXhtml(utf8.decode(navFile.content), p.dirname(manifest[navItemId]!));
    }
  } else {
    // Legacy NCX parsing
    final ncxId = opfXml.findAllElements('spine').firstOrNull?.getAttribute('toc');
    if (ncxId != null && manifest[ncxId] != null) {
      final ncxFile = archive.findFile(manifest[ncxId]!);
      if (ncxFile != null) {
        tocEntries = _parseNcx(utf8.decode(ncxFile.content), p.dirname(manifest[ncxId]!));
      }
    }
  }
  print("ISO_PROC: Parsed TOC with ${tocEntries.length} main entries.");


  // 8. Bundle everything into the DTO and return it
  print("ISO_PROC: Isolate finished. Returning ParsedBookDTO.");
  return ParsedBookDTO(
    title: title,
    author: author,
    publisher: publisher,
    language: language,
    publicationDate: publicationDate,
    coverImageBytes: coverImageBytes,
    toc: tocEntries,
    blocks: allBlocks,
  );
}


// --- All helper methods are now private static methods within this file ---

void _flattenAndParseElements({
  required List<dom.Element> elements,
  required List<ParsedContentBlockDTO> targetBlockList,
  required int chapterIndex,
  required String chapterPath,
  required Archive archive,
  required int Function() getNextBlockIndex,
}) {
  for (final element in elements) {
    final tagName = element.localName;
    final blockType = _getBlockType(tagName);

    if (['div', 'section', 'article', 'main'].contains(tagName)) {
      _flattenAndParseElements(
          elements: element.children,
          targetBlockList: targetBlockList,
          chapterIndex: chapterIndex,
          chapterPath: chapterPath,
          archive: archive,
          getNextBlockIndex: getNextBlockIndex);
      continue;
    }

    if (blockType != db.BlockType.unsupported) {
      final textContent = element.text.replaceAll('\u00A0', ' ').trim();
      if (textContent.isEmpty && blockType != db.BlockType.img) {
        continue;
      }

      Uint8List? imageBytes;
      if (blockType == db.BlockType.img) {
        final imgTag = (['img', 'image'].contains(tagName)) ? element : element.querySelector('img, image');
        final hrefAttr = imgTag?.attributes['src'] ?? imgTag?.attributes['href'] ?? imgTag?.attributes['xlink:href'];
        if (hrefAttr != null) {
          final imagePath = p.normalize(p.join(p.dirname(chapterPath), hrefAttr));
          final imageFile = archive.findFile(imagePath);
          if (imageFile != null) {
            imageBytes = imageFile.content as Uint8List;
          }
        }
      }

      targetBlockList.add(ParsedContentBlockDTO(
        chapterIndex: chapterIndex,
        blockIndexInChapter: getNextBlockIndex(),
        src: chapterPath,
        blockType: blockType,
        htmlContent: element.outerHtml,
        textContent: textContent,
        imageBytes: imageBytes,
      ));
    }
  }
}

// _parseNavXhtml, _parseNcx, and _getBlockType helpers remain the same as in your previous version
// but are now part of this file's private scope.

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
  final navMap = document.findAllElements('navMap').first;
  return _parseNavPoints(navMap.findElements('navPoint').toList(), basePath);
}

List<TOCEntry> _parseNavPoints(List<XmlElement> navPoints, String basePath) {
  final entries = <TOCEntry>[];
  for (final navPoint in navPoints) {
    final navLabel = navPoint.findElements('navLabel').first.findElements('text').first.innerText;
    final contentSrc = navPoint.findElements('content').first.getAttribute('src') ?? '';
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