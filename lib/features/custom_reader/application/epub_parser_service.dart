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
  final int chapterNumber; // Uniform chapter number (1-based index)

  EpubChapter({
    required this.id,
    required this.title,
    required this.href,
    required this.content,
    required this.chapterNumber,
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

    // In your parseEpub method, after building the manifest, add this:
    final svgImageRefs = <String>{};

// Check all HTML/XHTML files for SVG image references
    for (final entry in manifestMediaTypeByHref.entries) {
      final epubHref = entry.key;
      final mediaType = entry.value.toLowerCase();

      if (mediaType.contains('html') || mediaType.contains('xhtml')) {
        final archiveFile = findFile(archive, epubHref);
        if (archiveFile != null) {
          final content = safeDecode(archiveFile.content as List<int>);
          final refs = _extractSvgImageReferences(content);

          // Resolve relative paths
          final chapterDir = p.dirname(epubHref);
          for (final ref in refs) {
            String resolvedRef;
            if (ref.startsWith('../')) {
              resolvedRef = p.normalize(p.join(chapterDir, ref));
            } else if (ref.startsWith('./')) {
              resolvedRef = p.normalize(p.join(chapterDir, ref.substring(2)));
            } else if (!ref.startsWith('/')) {
              resolvedRef = p.normalize(p.join(chapterDir, ref));
            } else {
              resolvedRef = ref.substring(1);
            }
            resolvedRef = resolvedRef.replaceAll(r'\', '/');
            svgImageRefs.add(resolvedRef);
          }
        }
      }
    }

    print('DEBUG: SVG image references found: ${svgImageRefs.length}');
    for (final ref in svgImageRefs) {
      print('DEBUG: SVG ref: $ref');
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

      bool shouldExtract = mediaType.startsWith('image/') ||
          _looksLikeImage(epubHref) ||
          svgImageRefs.contains(epubHref);

      if (shouldExtract) {
        print('DEBUG: Extracting image: $epubHref (reason: ${mediaType.startsWith('image/') ? 'manifest' : svgImageRefs.contains(epubHref) ? 'svg-ref' : 'extension'})');

        final archiveFile = findFile(archive, epubHref);
        if (archiveFile != null) {
          final filename = p.basename(epubHref);
          final localPath = p.join(extractDir.path, filename);
          final outFile = File(localPath);
          await outFile.writeAsBytes(archiveFile.content as List<int>);
          images[epubHref] = outFile.path;
          print('DEBUG: Successfully extracted to: $localPath');
        } else {
          print('DEBUG: Archive file not found for: $epubHref');
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
    print('📖 DEBUG: Starting chapter parsing from EPUB spine');
    for (int i = 0; i < spineItems.length; i++) {
      final itemId = spineItems[i];
      final fullPath = manifestHrefById[itemId];
      if (fullPath == null) continue;

      final chapterFile = findFile(archive, fullPath);
      if (chapterFile != null) {
        final content = safeDecode(chapterFile.content as List<int>);
        final chapterTitle = chapterTitles[fullPath] ?? 'Chapter ${i + 1}';
        final chapterNum = i + 1;
        print('📖 DEBUG: Parsed Chapter #$chapterNum - Title: "$chapterTitle"');
        chapters.add(EpubChapter(
          id: itemId,
          title: chapterTitle,
          href: fullPath,
          content: content,
          chapterNumber: chapterNum, // 1-based chapter numbering
        ));
      }
    }
    print('📖 DEBUG: Completed parsing ${chapters.length} chapters with uniform numbering');

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

    print('DEBUG: ----- Rewriting images for chapter: $chapterHref -----');
    print('DEBUG: Found ${imageElements.length} image tags.');

    for (final img in imageElements) {
      final attributes = img.attributes;
      if (attributes == null) continue;

      final rawSrc = attributes['src'];
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

      // Get the directory of the chapter file
      final chapterDir = p.dirname(chapterHref);

      // Resolve the relative path properly
      String resolvedPath;
      if (rawSrc.startsWith('../')) {
        // Handle relative paths that go up directories
        resolvedPath = p.normalize(p.join(chapterDir, rawSrc));
      } else if (rawSrc.startsWith('./')) {
        // Handle current directory relative paths
        resolvedPath = p.normalize(p.join(chapterDir, rawSrc.substring(2)));
      } else if (!rawSrc.startsWith('/')) {
        // Handle relative paths in same directory
        resolvedPath = p.normalize(p.join(chapterDir, rawSrc));
      } else {
        // Handle absolute paths (remove leading slash)
        resolvedPath = rawSrc.substring(1);
      }

      // Normalize path separators
      resolvedPath = resolvedPath.replaceAll(r'\', '/');

      print('DEBUG: Chapter dir: "$chapterDir"');
      print('DEBUG: Resolved path: "$resolvedPath"');

      final localFile = images[resolvedPath];

      if (localFile != null && File(localFile).existsSync()) {
        final fileUri = Uri.file(localFile).toString();
        print('DEBUG: SUCCESS - Replacing with file URI: $fileUri');
        attributes['src'] = fileUri;
      } else {
        print('DEBUG: FAILED - No local file found for resolved path "$resolvedPath"');
        if (images.isNotEmpty) {
          print('DEBUG: Available image keys: ${images.keys.join(", ")}');
        }
      }
    }

    final result = document.outerHtml;
    print('DEBUG: ----- Finished rewriting for chapter: $chapterHref -----\n');
    return result;
  }

  Set<String> _extractSvgImageReferences(String content) {
    final imageRefs = <String>{};

    try {
      print('DEBUG: Parsing content for SVG references, content length: ${content.length}');

      // Try XML parsing first for proper SVG namespace handling
      try {
        final xmlDoc = XmlDocument.parse(content);

        // Look for image elements in SVG namespace
        final svgImages = xmlDoc.findAllElements('image');
        for (final img in svgImages) {
          final xlinkHref = img.getAttribute('xlink:href');
          final href = img.getAttribute('href');

          final imageRef = xlinkHref ?? href;
          if (imageRef != null && imageRef.isNotEmpty && _looksLikeImage(imageRef)) {
            print('DEBUG: Found SVG image reference via XML: $imageRef');
            imageRefs.add(imageRef);
          }
        }

      } catch (xmlError) {
        print('DEBUG: XML parsing failed, trying HTML parser: $xmlError');

        // Fallback to HTML parsing
        final document = html_parser.parse(content);

        // Check if content contains SVG at all
        if (content.contains('<svg') || content.contains('image')) {
          print('DEBUG: Content contains SVG or image tags');

          // Find all image elements
          final allImages = document.querySelectorAll('image');
          for (final img in allImages) {
            final xlinkHref = img.attributes['xlink:href'];
            final href = img.attributes['href'];

            final imageRef = xlinkHref ?? href;
            if (imageRef != null && imageRef.isNotEmpty && _looksLikeImage(imageRef)) {
              print('DEBUG: Found image element reference via HTML: $imageRef');
              imageRefs.add(imageRef);
            }
          }

          // Also check SVG image elements
          final svgImages = document.querySelectorAll('svg image');
          for (final img in svgImages) {
            final xlinkHref = img.attributes['xlink:href'];
            final href = img.attributes['href'];

            final imageRef = xlinkHref ?? href;
            if (imageRef != null && imageRef.isNotEmpty && _looksLikeImage(imageRef)) {
              print('DEBUG: Found SVG image reference via HTML: $imageRef');
              imageRefs.add(imageRef);
            }
          }
        }
      }

      print('DEBUG: Total SVG image references found: ${imageRefs.length}');
      for (final ref in imageRefs) {
        print('DEBUG: - $ref');
      }

    } catch (e) {
      print('ERROR: Exception in _extractSvgImageReferences: $e');
    }

    return imageRefs;
  }


  bool _looksLikeImage(String path) {
    final ext = p.extension(path).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.svg'].contains(ext);
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

