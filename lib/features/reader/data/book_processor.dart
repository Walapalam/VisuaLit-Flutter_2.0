import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';
import 'package:visualit/features/reader/data/parsed_book_dto.dart';
import 'package:visualit/features/reader/data/toc_entry.dart';
import 'package:visualit/features/reader/data/book_data.dart' show BlockType;

/// Processes EPUB files in an isolate
class BookProcessor {
  /// Static method to process an EPUB file in an isolate
  /// 
  /// This method is designed to be called via Flutter's compute function:
  /// ```dart
  /// final ParsedBookDTO dto = await compute(BookProcessor.processEpub, fileBytes);
  /// ```
  static ParsedBookDTO processEpub(Uint8List fileBytes) {
    // Decode the EPUB file (which is a ZIP archive)
    final archive = ZipDecoder().decodeBytes(fileBytes);
    
    // Parse container.xml to find the OPF file
    final containerFile = archive.findFile('META-INF/container.xml');
    if (containerFile == null) {
      throw Exception('container.xml not found');
    }
    
    final containerXml = XmlDocument.parse(String.fromCharCodes(containerFile.content));
    final opfPath = containerXml.findAllElements('rootfile').first.getAttribute('full-path');
    if (opfPath == null) {
      throw Exception('OPF path not found in container.xml');
    }
    
    // Parse the OPF file
    final opfFile = archive.findFile(opfPath);
    if (opfFile == null) {
      throw Exception('OPF file not found at path: $opfPath');
    }
    
    final opfXml = XmlDocument.parse(String.fromCharCodes(opfFile.content));
    final opfDir = p.dirname(opfPath);
    
    // Extract metadata
    final metadata = opfXml.findAllElements('metadata').first;
    final title = metadata.findAllElements('dc:title').firstOrNull?.innerText ?? 'Unknown Title';
    final author = metadata.findAllElements('dc:creator').firstOrNull?.innerText ?? 'Unknown Author';
    final publisher = metadata.findAllElements('dc:publisher').firstOrNull?.innerText;
    final language = metadata.findAllElements('dc:language').firstOrNull?.innerText;
    final pubDateStr = metadata.findAllElements('dc:date').firstOrNull?.innerText;
    final publicationDate = pubDateStr != null ? DateTime.tryParse(pubDateStr) : null;
    
    // Build the manifest (mapping of IDs to file paths)
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
    
    // Extract cover image
    Uint8List? coverImageBytes;
    String? coverId;
    
    // Look for cover-image property
    for (final item in manifestItems) {
      if (item.getAttribute('properties')?.contains('cover-image') ?? false) {
        coverId = item.getAttribute('id');
        break;
      }
    }
    
    // If not found, look for meta tag with name="cover"
    if (coverId == null) {
      for (final meta in metadata.findAllElements('meta')) {
        if (meta.getAttribute('name') == 'cover') {
          coverId = meta.getAttribute('content');
          break;
        }
      }
    }
    
    // Extract cover image bytes
    if (coverId != null) {
      final coverPath = manifest[coverId];
      if (coverPath != null) {
        final coverFile = archive.findFile(coverPath);
        if (coverFile != null) {
          coverImageBytes = coverFile.content as Uint8List;
        }
      }
    }
    
    // Get the spine (reading order)
    final spineItems = opfXml.findAllElements('itemref');
    final spine = spineItems
        .map((item) => item.getAttribute('idref'))
        .whereType<String>()
        .toList();
    
    // Process each chapter in the spine
    final List<ParsedContentBlockDTO> allBlocks = [];
    for (int i = 0; i < spine.length; i++) {
      final idref = spine[i];
      final chapterPath = manifest[idref];
      if (chapterPath == null) continue;
      
      final chapterFile = archive.findFile(chapterPath);
      if (chapterFile == null) continue;
      
      final chapterContent = String.fromCharCodes(chapterFile.content);
      final document = html_parser.parse(chapterContent);
      final body = document.body;
      if (body == null) continue;
      
      int blockCounter = 0;
      
      // Process the chapter body
      _flattenAndParseElements(
        elements: body.children,
        targetBlockList: allBlocks,
        chapterIndex: i,
        chapterPath: chapterPath,
        archive: archive,
        getNextBlockIndex: () => blockCounter++,
      );
    }
    
    // Parse the Table of Contents
    List<TOCEntry> tocEntries = [];
    
    // First try to find the nav document (EPUB3)
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
    
    // If no TOC found in nav, try NCX (EPUB2)
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
    
    // Return the parsed book data
    return ParsedBookDTO(
      title: title,
      author: author,
      coverImageBytes: coverImageBytes,
      publisher: publisher,
      language: language,
      publicationDate: publicationDate,
      toc: tocEntries,
      contentBlocks: allBlocks,
    );
  }
  
  /// Recursively traverses the HTML DOM to flatten it into a list of ContentBlocks
  static void _flattenAndParseElements({
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
      
      // If it's a container tag, we don't create a block for it.
      // Instead, we recurse into its children to find content.
      if (tagName == 'div' || tagName == 'section' || tagName == 'article' || tagName == 'main') {
        _flattenAndParseElements(
          elements: element.children,
          targetBlockList: targetBlockList,
          chapterIndex: chapterIndex,
          chapterPath: chapterPath,
          archive: archive,
          getNextBlockIndex: getNextBlockIndex,
        );
        continue;
      }
      
      // If it's a content block we care about, we process it.
      if (blockType != 'unsupported') {
        final textContent = element.text.replaceAll('\u00A0', ' ').trim();
        
        // We skip blocks that are just empty text, but we must allow image blocks
        // as they have no text content but are still valid.
        if (textContent.isEmpty && blockType != 'img') {
          continue;
        }
        
        final block = ParsedContentBlockDTO(
          chapterIndex: chapterIndex,
          blockIndexInChapter: getNextBlockIndex(),
          src: chapterPath,
          blockType: blockType,
          htmlContent: element.outerHtml,
          textContent: textContent,
          imageBytes: null, // Will be set below for images
        );
        
        // Specifically handle image data extraction
        if (blockType == 'img') {
          // An image can be a direct <img> tag, an <image> tag (used in SVG), or an <svg> tag wrapping an <image>.
          // We need to find the actual image reference.
          final imgTag = (tagName == 'img' || tagName == 'image')
              ? element
              : element.querySelector('img, image');
          
          // EPUBs can use 'src', 'href', or 'xlink:href' for image paths. Check all.
          final hrefAttr = imgTag?.attributes['src'] ?? 
                          imgTag?.attributes['href'] ?? 
                          imgTag?.attributes['xlink:href'];
          
          if (hrefAttr != null) {
            // Resolve the relative image path against the chapter's path.
            final imagePath = p.normalize(p.join(p.dirname(chapterPath), hrefAttr));
            final imageFile = archive.findFile(imagePath);
            if (imageFile != null) {
              targetBlockList.add(ParsedContentBlockDTO(
                chapterIndex: block.chapterIndex,
                blockIndexInChapter: block.blockIndexInChapter,
                src: block.src,
                blockType: block.blockType,
                htmlContent: block.htmlContent,
                textContent: block.textContent,
                imageBytes: imageFile.content as Uint8List,
              ));
              continue; // Skip adding the original block
            }
          }
        }
        
        targetBlockList.add(block);
      }
    }
  }
  
  /// Parses the EPUB3 navigation document
  static List<TOCEntry> _parseNavXhtml(String content, String basePath) {
    final document = html_parser.parse(content);
    final nav = document.querySelector('nav[epub\\:type="toc"]');
    if (nav == null) return [];
    final ol = nav.querySelector('ol');
    if (ol == null) return [];
    return _parseNavList(ol, basePath);
  }
  
  /// Parses a navigation list from the EPUB3 navigation document
  static List<TOCEntry> _parseNavList(dom.Element listElement, String basePath) {
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
  
  /// Parses the EPUB2 NCX file
  static List<TOCEntry> _parseNcx(String content, String basePath) {
    final document = XmlDocument.parse(content);
    final navMap = document.findAllElements('navMap').first;
    return _parseNavPoints(navMap.findElements('navPoint').toList(), basePath);
  }
  
  /// Parses navigation points from the EPUB2 NCX file
  static List<TOCEntry> _parseNavPoints(List<XmlElement> navPoints, String basePath) {
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
  
  /// Converts HTML tag names to BlockType strings
  static String _getBlockType(String? tagName) {
    switch (tagName?.toLowerCase()) {
      case 'p': return 'p';
      case 'h1': return 'h1';
      case 'h2': return 'h2';
      case 'h3': return 'h3';
      case 'h4': return 'h4';
      case 'h5': return 'h5';
      case 'h6': return 'h6';
      case 'img': return 'img';
      case 'image': return 'img';
      case 'svg': return 'img';
      default: return 'unsupported';
    }
  }
}