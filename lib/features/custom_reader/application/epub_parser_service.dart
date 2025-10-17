import 'dart:io';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';

class Chapter {
  final String id;
  final String title;
  final String href;
  final String content;

  Chapter({
    required this.id,
    required this.title,
    required this.href,
    required this.content,
  });
}

class EpubMetadata {
  final String title;
  final String author;
  final List<Chapter> chapters;

  EpubMetadata({
    required this.title,
    required this.author,
    required this.chapters,
  });
}

class EpubParserService {
  Future<EpubMetadata> parseEpub(String epubPath) async {
    final bytes = await File(epubPath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    // Step 1: Parse container.xml to find OPF file
    final containerFile = archive.findFile('META-INF/container.xml');
    if (containerFile == null) {
      throw Exception('Invalid EPUB: Missing container.xml');
    }

    final containerXml =
    XmlDocument.parse(safeDecode(containerFile.content));
    final opfPath =
    containerXml.findAllElements('rootfile').first.getAttribute('full-path')!;

    // Step 2: Parse OPF file
    final opfFile = archive.findFile(opfPath);
    if (opfFile == null) throw Exception('Invalid EPUB: Missing OPF file');

    final opfXml = XmlDocument.parse(safeDecode(opfFile.content));
    final opfDir = p.dirname(opfPath);

    // Extract metadata
    final metadataElement = opfXml.findAllElements('metadata').first;
    final title = metadataElement.findElements('dc:title').first.text;
    final author = metadataElement.findElements('dc:creator').first.text;

    // Extract manifest items (id -> href map)
    final manifestItems = <String, String>{};
    for (final item in opfXml.findAllElements('item')) {
      final id = item.getAttribute('id')!;
      final href = item.getAttribute('href')!;
      // Make href relative to the root of the EPUB, not the OPF file
      manifestItems[id] = p.join(opfDir, href);
    }

    // TODO: Step 2.5: Find and Parse the Navigation file (toc.ncx or nav.xhtml)
    // 1. Find the TOC file path from the manifest. Look for an item with properties="nav" or an item with id="ncx" or "toc".
    // 2. Parse this file to create a map of chapter hrefs to chapter titles.
    // Example: Map<String, String> chapterTitles = parseToc(tocFileContent);
    Map<String, String> _parseToc(Archive archive, XmlDocument opfXml, String opfDir) {
      final chapterTitles = <String, String>{};

      // Try to find navigation file
      String? tocPath;

      // Look for EPUB 3 nav file first
      for (final item in opfXml.findAllElements('item')) {
        final properties = item.getAttribute('properties');
        if (properties != null && properties.contains('nav')) {
          tocPath = p.join(opfDir, item.getAttribute('href')!);
          break;
        }
      }

      // Fallback to EPUB 2 NCX file
      if (tocPath == null) {
        final spineElement = opfXml.findAllElements('spine').first;
        final tocId = spineElement.getAttribute('toc');
        if (tocId != null) {
          for (final item in opfXml.findAllElements('item')) {
            if (item.getAttribute('id') == tocId) {
              tocPath = p.join(opfDir, item.getAttribute('href')!);
              break;
            }
          }
        }
      }

      if (tocPath != null) {
        final tocFile = archive.findFile(tocPath);
        if (tocFile != null) {
          final tocContent = safeDecode(tocFile.content);
          final tocXml = XmlDocument.parse(tocContent);

          // Parse EPUB 3 nav file
          for (final navElement in tocXml.findAllElements('nav')) {
            final epubType = navElement.getAttribute('epub:type');
            if (epubType == 'toc') {
              for (final link in navElement.findAllElements('a')) {
                final href = link.getAttribute('href');
                final title = link.text.trim();
                if (href != null && title.isNotEmpty) {
                  chapterTitles[p.join(opfDir, href)] = title;
                }
              }
            }
          }

          // Parse EPUB 2 NCX file
          for (final navPoint in tocXml.findAllElements('navPoint')) {
            final textElement = navPoint.findElements('navLabel').first.findElements('text').first;
            final contentElement = navPoint.findElements('content').first;
            final title = textElement.text.trim();
            final href = contentElement.getAttribute('src');
            if (href != null && title.isNotEmpty) {
              chapterTitles[p.join(opfDir, href)] = title;
            }
          }
        }
      }

      return chapterTitles;
    }

    final chapterTitles = _parseToc(archive, opfXml, opfDir);

    // Extract spine order (the reading order)
    final spineItems =
    opfXml.findAllElements('itemref').map((item) => item.getAttribute('idref')!).toList();

    // Step 3: Load chapter content in spine order
    final chapters = <Chapter>[];
    for (int i = 0; i < spineItems.length; i++) {
      final itemId = spineItems[i];
      final fullPath = manifestItems[itemId]!;

      final chapterFile = archive.findFile(fullPath);
      if (chapterFile != null) {
        final content = safeDecode(chapterFile.content);

        // Use the parsed title if available, otherwise fallback to a placeholder
        final chapterTitle = chapterTitles[fullPath] ?? 'Chapter ${i + 1}';

        chapters.add(Chapter(
          id: itemId,
          title: chapterTitle,
          href: fullPath,
          content: content,
        ));
      }
    }

    return EpubMetadata(
      title: title,
      author: author,
      chapters: chapters,
    );
  }

  String safeDecode(List<int> bytes) {
    try {
      var s = utf8.decode(bytes);
      if (s.isNotEmpty && s.codeUnitAt(0) == 0xFEFF) {
        s = s.substring(1);
      }
      return s;
    } catch (_) {
      // Fallback for non-UTF8 encoded files
      return latin1.decode(bytes);
    }
  }
}
