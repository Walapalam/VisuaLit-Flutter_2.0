import 'dart:typed_data';
import 'dart:math' as math;
import 'package:archive/archive.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';
import 'package:visualit/core/models/parsed_book_dto.dart';
import 'package:visualit/core/models/content_block_schema.dart';

/// A service class for processing EPUB books.
/// This class is responsible for parsing EPUB files and returning a ParsedBookDTO.
class BookProcessor {
  /// Static method that can be called via compute() to process an EPUB file in an isolate.
  static Future<ParsedBookDTO> processEpub(Uint8List bytes) async {
    print("\n--- 📖 [BookProcessor] Processing EPUB in isolate ---");
    
    try {
      return await _parseEpub(bytes);
    } catch (e, stackTrace) {
      print("❌ [BookProcessor] Error processing EPUB: $e");
      print(stackTrace);
      rethrow; // Rethrow to be caught by the caller
    }
  }

  /// Parses an EPUB file and returns a ParsedBookDTO.
  static Future<ParsedBookDTO> _parseEpub(Uint8List bytes) async {
    final archive = ZipDecoder().decodeBytes(bytes);
    
    // Parse container.xml to find the OPF file
    final containerFile = archive.findFile('META-INF/container.xml');
    if (containerFile == null) throw Exception('container.xml not found');
    final containerXml = XmlDocument.parse(String.fromCharCodes(containerFile.content));
    final opfPath = containerXml.findAllElements('rootfile').first.getAttribute('full-path');
    if (opfPath == null) throw Exception('OPF path not found in container.xml');
    
    // Parse the OPF file
    final opfFile = archive.findFile(opfPath);
    if (opfFile == null) throw Exception('OPF file not found at path: $opfPath');
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
    print("  [BookProcessor] Parsed Metadata -> Title: '$title', Author: '$author', Publisher: '$publisher'");
    
    // Build manifest
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
    
    // Get spine (reading order)
    final spineItems = opfXml.findAllElements('itemref');
    final spine = spineItems.map((item) => item.getAttribute('idref')).whereType<String>().toList();
    
    // Parse chapters
    final chapters = <ParsedChapterDTO>[];
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
      
      // Extract chapter title
      final chapterTitle = document.querySelector('title')?.text ?? 
                          document.querySelector('h1')?.text ?? 
                          'Chapter ${i + 1}';
      
      // Process content blocks
      final blocks = <ParsedContentBlockDTO>[];
      int blockCounter = 0;
      
      _flattenAndParseElements(
        elements: body.children,
        targetBlockList: blocks,
        chapterPath: chapterPath,
        archive: archive,
        getNextBlockIndex: () => blockCounter++,
      );
      
      chapters.add(ParsedChapterDTO(
        index: i,
        title: chapterTitle,
        path: chapterPath,
        blocks: blocks,
      ));
      
      print("  ✅ [BookProcessor] Processed chapter $i with ${blocks.length} blocks");
    }
    
    // Parse TOC
    List<ParsedTOCEntryDTO> tocEntries = [];
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
    
    print("  ✅ [BookProcessor] FINAL RESULT: Extracted a total of ${chapters.fold(0, (sum, chapter) => sum + chapter.blocks.length)} content blocks from the entire book.");
    
    return ParsedBookDTO(
      title: title,
      author: author,
      coverImageBytes: coverImageBytes,
      tocEntries: tocEntries,
      publisher: publisher,
      language: language,
      publicationDate: publicationDate,
      chapters: chapters,
    );
  }
  
  /// Recursively traverses the HTML DOM to flatten it into a list of ContentBlocks.
  static void _flattenAndParseElements({
    required List<dom.Element> elements,
    required List<ParsedContentBlockDTO> targetBlockList,
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
          chapterPath: chapterPath,
          archive: archive,
          getNextBlockIndex: getNextBlockIndex,
        );
        continue;
      }
      
      // If it's a content block we care about, we process it.
      if (blockType != BlockType.unsupported) {
        final textContent = element.text.replaceAll('\u00A0', ' ').trim();
        
        // We skip blocks that are just empty text, but we must allow image blocks
        // as they have no text content but are still valid.
        if (textContent.isEmpty && blockType != BlockType.img) {
          continue;
        }
        
        Uint8List? imageBytes;
        
        // Specifically handle image data extraction
        if (blockType == BlockType.img) {
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
              imageBytes = imageFile.content as Uint8List;
            } else {
              print("    ❌ [BookProcessor] Image file not found at path: '$imagePath'");
            }
          }
        }
        
        targetBlockList.add(ParsedContentBlockDTO(
          blockType: blockType,
          htmlContent: element.outerHtml,
          textContent: textContent,
          imageBytes: imageBytes,
        ));
      }
    }
  }
  
  /// Parses the navigation XHTML file to extract TOC entries.
  static List<ParsedTOCEntryDTO> _parseNavXhtml(String content, String basePath) {
    final document = html_parser.parse(content);
    final nav = document.querySelector('nav[epub\\:type="toc"]');
    if (nav == null) return [];
    final ol = nav.querySelector('ol');
    if (ol == null) return [];
    return _parseNavList(ol, basePath);
  }
  
  /// Recursively parses a navigation list to extract TOC entries.
  static List<ParsedTOCEntryDTO> _parseNavList(dom.Element listElement, String basePath) {
    final entries = <ParsedTOCEntryDTO>[];
    for (final item in listElement.children.where((e) => e.localName == 'li')) {
      final anchor = item.querySelector('a');
      if (anchor == null) continue;
      final href = anchor.attributes['href'] ?? '';
      final parts = href.split('#');
      final src = parts.length > 0 && parts[0].isNotEmpty ? parts[0] : null;
      final fragment = parts.length > 1 ? parts[1] : null;
      
      final nestedOl = item.querySelector('ol');
      final children = nestedOl != null ? _parseNavList(nestedOl, basePath) : <ParsedTOCEntryDTO>[];
      
      entries.add(ParsedTOCEntryDTO(
        title: anchor.text.trim(),
        src: src != null ? p.normalize(p.join(basePath, src)) : null,
        fragment: fragment,
        children: children,
      ));
    }
    return entries;
  }
  
  /// Parses the NCX file to extract TOC entries.
  static List<ParsedTOCEntryDTO> _parseNcx(String content, String basePath) {
    final document = XmlDocument.parse(content);
    final navMap = document.findAllElements('navMap').first;
    return _parseNavPoints(navMap.findElements('navPoint').toList(), basePath);
  }
  
  /// Recursively parses navigation points to extract TOC entries.
  static List<ParsedTOCEntryDTO> _parseNavPoints(List<XmlElement> navPoints, String basePath) {
    final entries = <ParsedTOCEntryDTO>[];
    for (final navPoint in navPoints) {
      final navLabel = navPoint.findElements('navLabel').first.findElements('text').first.innerText;
      final contentSrc = navPoint.findElements('content').first.getAttribute('src') ?? '';
      final parts = contentSrc.split('#');
      final src = parts.length > 0 && parts[0].isNotEmpty ? parts[0] : null;
      final fragment = parts.length > 1 ? parts[1] : null;
      
      final children = navPoint.findElements('navPoint').toList();
      final childEntries = children.isNotEmpty ? _parseNavPoints(children, basePath) : <ParsedTOCEntryDTO>[];
      
      entries.add(ParsedTOCEntryDTO(
        title: navLabel.trim(),
        src: src != null ? p.normalize(p.join(basePath, src)) : null,
        fragment: fragment,
        children: childEntries,
      ));
    }
    return entries;
  }
  
  /// Determines the block type based on the HTML tag name.
  static BlockType _getBlockType(String? tagName) {
    switch (tagName?.toLowerCase()) {
      case 'p': return BlockType.p;
      case 'h1': return BlockType.h1;
      case 'h2': return BlockType.h2;
      case 'h3': return BlockType.h3;
      case 'h4': return BlockType.h4;
      case 'h5': return BlockType.h5;
      case 'h6': return BlockType.h6;
      case 'img': return BlockType.img;
      case 'image': return BlockType.img;
      case 'svg': return BlockType.img;
      default: return BlockType.unsupported;
    }
  }
}