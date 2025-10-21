import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as html_dom;

// Renamed to EpubChapter for clarity
class EpubChapter {
  final String id;
  final String title;
  final String href; // full path inside EPUB (normalized)
  final String content;

  EpubChapter({
    required this.id,
    required this.title,
    required this.href,
    required this.content,
  });
}

class EpubMetadata {
  final String title;
  final String author;
  final List<EpubChapter> chapters;
  final Map<String, String> images;
  final Map<String, String> cssFiles;

  EpubMetadata({
    required this.title,
    required this.author,
    required this.chapters,
    required this.images,
    Map<String, String>? cssFiles,
  }) : cssFiles = cssFiles ?? {};
}

class EpubParserService {
  Future<EpubMetadata> parseEpub(String epubPath) async {
    final bytes = await File(epubPath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    // Helper to find a file by normalized name in the archive
    ArchiveFile? findFile(Archive archive, String path) {
      final normPath = p.normalize(path).replaceAll(r'\', '/');
      try {
        return archive.files.firstWhere((f) => p.normalize(f.name).replaceAll(r'\', '/') == normPath);
      } catch (_) {
        return null;
      }
    }

    // Step 1: Parse container.xml to find OPF file
    final containerFile = findFile(archive, 'META-INF/container.xml');
    if (containerFile == null) {
      throw Exception('Invalid EPUB: Missing container.xml');
    }

    final containerXml =
    XmlDocument.parse(safeDecode(containerFile.content as List<int>));
    final opfPath =
    containerXml.findAllElements('rootfile').first.getAttribute('full-path')!;

    // Step 2: Parse OPF file
    final opfFile = findFile(archive, opfPath);
    if (opfFile == null) throw Exception('Invalid EPUB: Missing OPF file');

    final opfXml = XmlDocument.parse(safeDecode(opfFile.content as List<int>));
    final opfDir = p.dirname(opfPath);

    // Extract metadata
    final metadataElement = opfXml.findAllElements('metadata').first;
    final title = metadataElement.findElements('dc:title').first.text;
    final author = metadataElement.findElements('dc:creator').first.text;

    // Build manifest id -> href and href -> media-type maps
    final manifestHrefById = <String, String>{};
    final manifestMediaTypeByHref = <String, String>{};
    for (final item in opfXml.findAllElements('item')) {
      final id = item.getAttribute('id');
      final href = item.getAttribute('href');
      final mediaType = item.getAttribute('media-type') ?? '';
      if (id != null && href != null) {
        final fullHref = p.normalize(p.join(opfDir, href)).replaceAll(r'\', '/');
        manifestHrefById[id] = fullHref;
        manifestMediaTypeByHref[fullHref] = mediaType;
      }
    }

    // Extract images into a temp dir and build an epubHref -> localFilePath map
    final tempDir = await getTemporaryDirectory();
    final extractDir = Directory(p.join(tempDir.path,
        'epub_images_${DateTime.now().millisecondsSinceEpoch}'));
    await extractDir.create(recursive: true);

    final images = <String, String>{};
    for (final entry in manifestMediaTypeByHref.entries) {
      final epubHref = entry.key;
      final mediaType = entry.value.toLowerCase();
      if (mediaType.startsWith('image/') || _looksLikeImage(epubHref)) {
        final archiveFile = findFile(archive, epubHref);
        if (archiveFile != null) {
          final filename = p.basename(epubHref);
          final localPath = p.join(extractDir.path, filename);
          final outFile = File(localPath);
          await outFile.writeAsBytes(archiveFile.content as List<int>);
          images[epubHref] = outFile.path;
        }
      }
    }

    // Parse TOC to get titles
    final chapterTitles = _parseToc(archive, opfXml, opfDir, findFile);

    // Extract spine order (the reading order)
    final spineItems =
    opfXml.findAllElements('itemref').map((item) => item.getAttribute('idref')!).toList();

    // Step 3: Load chapter content in spine order
    final chapters = <EpubChapter>[];
    for (int i = 0; i < spineItems.length; i++) {
      final itemId = spineItems[i];
      final fullPath = manifestHrefById[itemId];
      if (fullPath == null) continue;

      final chapterFile = findFile(archive, fullPath);
      if (chapterFile != null) {
        final content = safeDecode(chapterFile.content as List<int>);
        final chapterTitle = chapterTitles[fullPath] ?? 'Chapter ${i + 1}';
        chapters.add(EpubChapter(
          id: itemId,
          title: chapterTitle,
          href: fullPath,
          content: content,
        ));
      }
    }

    final cssFiles = <String, String>{};
    for (final entry in manifestMediaTypeByHref.entries) {
      final epubHref = entry.key;
      final mediaType = entry.value.toLowerCase();
      if (mediaType == 'text/css' || p.extension(epubHref).toLowerCase() == '.css') {
        final archiveFile = findFile(archive, epubHref);
        if (archiveFile != null) {
          final filename = p.basename(epubHref);
          final localPath = p.join(extractDir.path, filename);
          final outFile = File(localPath);
          await outFile.writeAsBytes(archiveFile.content as List<int>);
          cssFiles[epubHref] = outFile.path;
        }
      }
    }

    return EpubMetadata(
      title: title,
      author: author,
      chapters: chapters,
      images: images,
      cssFiles: cssFiles,
    );
  }

  Map<String, String> _parseToc(Archive archive, XmlDocument opfXml,
      String opfDir, ArchiveFile? Function(Archive, String) findFile) {
    final chapterTitles = <String, String>{};
    String? tocPath;

    // Find the NCX file in the manifest
    for (final item in opfXml.findAllElements('item')) {
      if (item.getAttribute('media-type') == 'application/x-dtbncx+xml') {
        tocPath = item.getAttribute('href');
        if (tocPath != null && !p.isAbsolute(tocPath)) {
          tocPath = p.normalize(p.join(opfDir, tocPath));
        }
        break;
      }
    }

    if (tocPath == null) return chapterTitles;

    final tocFile = findFile(archive, tocPath);
    if (tocFile == null) return chapterTitles;

    final tocXml = XmlDocument.parse(utf8.decode(tocFile.content as List<int>));
    for (final navPoint in tocXml.findAllElements('navPoint')) {
      final label = navPoint.findElements('navLabel').first.findElements('text').first.text;
      final contentElem = navPoint.findElements('content').first;
      final src = contentElem.getAttribute('src');
      if (src != null) {
        // Remove anchor if present
        final srcPath = src.split('#').first;
        final normalizedSrc = p.normalize(srcPath);
        chapterTitles[normalizedSrc] = label;
      }
    }
    return chapterTitles;
  }

  // FINAL, ROBUST METHOD: Uses Uri.resolve for path manipulation.
  static String rewriteImageSrcs(
      String content, String chapterHref, Map<String, String> images) {
    final html_dom.Document document = html_parser.parse(content);
    final imageElements = document.querySelectorAll('img');
    final chapterUri = Uri.parse(chapterHref);

    print('DEBUG: ----- Rewriting images for chapter: $chapterHref -----');
    print('DEBUG: Found ${imageElements.length} image tags.');

    for (final img in imageElements) {
      final rawSrc = img.attributes['src'];
      if (rawSrc == null || rawSrc.isEmpty) continue;

      print('DEBUG: Processing raw src: "$rawSrc"');

      // Skip fully qualified URLs and data URIs
      if (rawSrc.startsWith('data:') ||
          rawSrc.startsWith('http:') ||
          rawSrc.startsWith('https:') ||
          rawSrc.startsWith('file:')) {
        print('DEBUG: Skipping absolute/data URI.');
        continue;
      }

      // Use Uri.resolve to correctly handle relative paths (e.g., "../")
      // and decode any URL-encoded characters.
      final resolvedUri = chapterUri.resolve(rawSrc);
      final resolvedPath = p.normalize(resolvedUri.path).replaceAll(r'\', '/');

      print('DEBUG: Resolved path: "$resolvedPath"');

      // The resolved path may have a leading '/', which our image map keys don't.
      final lookupPath = resolvedPath.startsWith('/') ? resolvedPath.substring(1) : resolvedPath;

      print('DEBUG: Look up path: "$lookupPath"');

      final localFile = images[lookupPath];

      if (localFile != null && File(localFile).existsSync()) {
        final fileUri = Uri.file(localFile).toString();
        print('DEBUG: SUCCESS - Replacing with file URI: $fileUri');
        img.attributes['src'] = fileUri;
      } else {
        print('DEBUG: FAILED - No local file found for lookup path "$lookupPath"');
        if(images.isNotEmpty) {
          print('DEBUG: Available image keys: ${images.keys.join(", ")}');
        }
      }
    }

    final result = document.outerHtml;
    print('DEBUG: ----- Finished rewriting for chapter: $chapterHref -----\n');
    return result;
  }

  bool _looksLikeImage(String href) {
    final ext = p.extension(href).toLowerCase();
    return [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.svg',
      '.webp',
      '.bmp'
    ].contains(ext);
  }

  String safeDecode(List<int> bytes) {
    try {
      var s = utf8.decode(bytes, allowMalformed: true);
      if (s.isNotEmpty && s.codeUnitAt(0) == 0xFEFF) {
        s = s.substring(1);
      }
      return s;
    } catch (_) {
      return latin1.decode(bytes, allowInvalid: true);
    }
  }
}

