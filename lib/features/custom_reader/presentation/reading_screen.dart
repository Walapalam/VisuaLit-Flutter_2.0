// dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import the services package
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/epub_parser_service.dart';
import 'package:isar/isar.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:html/parser.dart' as html_parser;
import 'package:csslib/parser.dart' as css_parser;
import 'package:csslib/visitor.dart';

class ReadingScreen extends ConsumerStatefulWidget {
  final int bookId;

  const ReadingScreen({
    Key? key,
    required this.bookId,
  }) : super(key: key);

  @override
  ConsumerState<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends ConsumerState<ReadingScreen> {
  final EpubParserService _epubParser = EpubParserService();
  final PageController _pageController = PageController(initialPage: 0);

  EpubMetadata? _epubData;
  String? _epubPath;
  int _currentChapterIndex = 0;
  bool _isLoading = true;
  String? _error;
  bool _showOverlay = true;

  @override
  void initState() {
    super.initState();
    _loadBookAndEpub();
    // Ensure the system UI is visible when the screen is first loaded
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  // Method to toggle the overlay and system UI
  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
      if (_showOverlay) {
        // Show status bar and navigation bar
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
      } else {
        // Hide status bar and navigation bar for immersive mode
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      }
    });
  }

  Future<void> _loadBookAndEpub() async {
    try {
      // Use the app-wide Isar provider instead of opening Isar here
      final isar = await ref.read(isarInstanceProvider.future);
      final book = await isar.books.get(widget.bookId);

      if (book == null || book.epubFilePath.isEmpty) {
        setState(() {
          _error = 'Book not found or invalid file path';
          _isLoading = false;
        });
        return;
      }

      _epubPath = book.epubFilePath;
      final epubData = await _epubParser.parseEpub(_epubPath!);

      setState(() {
        _epubData = epubData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text('Error loading EPUB: $_error'),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Chapter content with tap to toggle overlay
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleOverlay, // Use the new toggle method
              child: PageView.builder(
                controller: _pageController,
                itemCount: _epubData?.chapters.length ?? 0,
                onPageChanged: (index) {
                  setState(() {
                    _currentChapterIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final chapter = _epubData!.chapters[index];
                  // _debugPrintChapterCssLinks(chapter);
                  // _debugPrintChapterCssContents(chapter, _epubData!.cssFiles);
                  debugPrint('Rendering chapter $index: ${chapter.href}');
                  final processedContent = chapter.content;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Html(
                          data: processedContent, // Use processed content with local file URIs
                          style: _parseCssToHtmlStyles(_epubData!.cssFiles),
                          extensions: [
                            TagExtension(
                              tagsToExtend: {"img"}, // Set of strings, not single string
                              builder: (context) {
                                final src = context.attributes['src'];

                                if (src == null || src.isEmpty) {
                                  return const SizedBox.shrink();
                                }

                                print('TagExtension processing src: $src');

                                // Handle file:// URIs (which your rewriteImageSrcs creates)
                                if (src.startsWith('file://')) {
                                  final filePath = Uri.parse(src).toFilePath();
                                  if (File(filePath).existsSync()) {
                                    return Image.file(
                                      File(filePath),
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: double.infinity,
                                          height: 200,
                                          color: Colors.grey[300],
                                          child: const Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.broken_image),
                                              Text('Image failed to load'),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  }
                                }

                                // Handle relative paths as fallback
                                if (!src.startsWith('http') && !src.startsWith('data:')) {
                                  final chapterDir = p.dirname(chapter.href);
                                  final resolvedPath = p.normalize(p.join(chapterDir, src)).replaceAll('\\', '/');
                                  final lookupPath = resolvedPath.startsWith('/') ? resolvedPath.substring(1) : resolvedPath;
                                  final localFile = _epubData!.images[lookupPath];

                                  if (localFile != null && File(localFile).existsSync()) {
                                    return Image.file(
                                      File(localFile),
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: double.infinity,
                                          height: 200,
                                          color: Colors.grey[300],
                                          child: const Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.broken_image),
                                              Text('Image failed to load'),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  }
                                }

                                // Fallback for unhandled images
                                return Container(
                                  width: double.infinity,
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.broken_image),
                                      Text('Image not found'),
                                    ],
                                  ),
                                );
                              },
                            ),
                            ImageExtension(
                              builder: (extensionContext) {
                                final element = extensionContext.element;
                                final src = element?.attributes['src'];
                                if (src != null && src.startsWith('file://')) {
                                  print(">>> IMAGE EXTENSION: Attempting to render file: $src");
                                  final file = File.fromUri(Uri.parse(src));
                                  if (file.existsSync()) {
                                    return Image.file(
                                      file,
                                      key: ValueKey(src), // Add a key for debugging
                                      width: double.infinity,
                                      fit: BoxFit.fitWidth,
                                      errorBuilder: (context, error, stackTrace) {
                                        print(">>> IMAGE EXTENSION ERROR: Error loading image file: $src, Error: $error");
                                        return Container(
                                          width: double.infinity,
                                          height: 100,
                                          color: Colors.red.withOpacity(0.3),
                                          child: Center(child: Text("Image failed to load\n$error", textAlign: TextAlign.center)),
                                        );
                                      },
                                    );
                                  } else {
                                    print(">>> IMAGE EXTENSION ERROR: File does not exist at path: ${file.path}");
                                    return const Icon(Icons.error, color: Colors.orange);
                                  }
                                }
                                // Let the default handler deal with other images (network, assets, etc.)
                                return const Icon(Icons.image, color: Colors.grey);
                              },
                            ),
                            TableHtmlExtension(

                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          // Overlay AppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: !_showOverlay,
              child: AnimatedOpacity(
                opacity: _showOverlay ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go("/home"),
                  ),
                  title: Text(_epubData?.title ?? 'Reader'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.list),
                      onPressed: _showChapterList,
                    ),
                  ],
                  backgroundColor: Colors.black.withOpacity(0.8),
                  elevation: 0,
                ),
              ),
            ),
          ),
          // Overlay navigation bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              ignoring: !_showOverlay,
              child: AnimatedOpacity(
                opacity: _showOverlay ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: SafeArea(
                  child: _buildNavigationBar(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.black.withOpacity(0.8), // Added for better visibility
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _currentChapterIndex > 0 ? _previousChapter : null,
          ),
          Text(
            'Chapter ${_currentChapterIndex + 1} of ${_epubData?.chapters.length ?? 0}',
            style: const TextStyle(color: Colors.white),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: _currentChapterIndex < (_epubData?.chapters.length ?? 0) - 1
                ? _nextChapter
                : null,
          ),
        ],
      ),
    );
  }

  void _previousChapter() {
    if (_currentChapterIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextChapter() {
    if (_currentChapterIndex < (_epubData?.chapters.length ?? 1) - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showChapterList() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chapters'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _epubData?.chapters.length ?? 0,
            itemBuilder: (context, index) {
              final chapter = _epubData!.chapters[index];
              return ListTile(
                title: Text(chapter.title),
                onTap: () {
                  Navigator.pop(context);
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _debugPrintChapterCssLinks(EpubChapter chapter) {
    final document = html_parser.parse(chapter.content);
    final cssLinks = document.head?.querySelectorAll('link[rel="stylesheet"]') ?? [];
    if (cssLinks.isNotEmpty) {
      print('DEBUG: CSS links for chapter "${chapter.title}":');
      for (final link in cssLinks) {
        final href = link.attributes['href'];
        print('DEBUG:   href="$href"');
      }
    } else {
      print('DEBUG: No CSS links found in chapter "${chapter.title}".');
    }
  }

  void _debugPrintChapterCssContents(EpubChapter chapter, Map<String, String> allCssFiles) {
    final document = html_parser.parse(chapter.content);
    final cssLinks = document.head?.querySelectorAll('link[rel="stylesheet"]') ?? [];
    final chapterDir = p.dirname(chapter.href);

    for (final link in cssLinks) {
      final href = link.attributes['href'];
      if (href == null) continue;
      // Resolve relative path
      final resolvedPath = p.normalize(p.join(chapterDir, href)).replaceAll('\\', '/');
      final lookupPath = resolvedPath.startsWith('/') ? resolvedPath.substring(1) : resolvedPath;
      final cssFilePath = allCssFiles[lookupPath];
      if (cssFilePath != null && File(cssFilePath).existsSync()) {
        final cssContent = File(cssFilePath).readAsStringSync();
        print('DEBUG: CSS content for "$href" in chapter "${chapter.title}":\n$cssContent\n');
      } else {
        print('DEBUG: CSS file not found for "$href" (resolved: $lookupPath)');
      }
    }
  }

  Map<String, Style> _parseCssToHtmlStyles(Map<String, String> cssFiles) {
    final styles = <String, Style>{};
    for (final cssPath in cssFiles.values) {
      final cssContent = File(cssPath).readAsStringSync();
      final stylesheet = css_parser.parse(cssContent);
      for (final rule in stylesheet.topLevels.whereType<RuleSet>()) {
        final selectorGroup = rule.selectorGroup;
        if (selectorGroup == null) continue;
        for (final selector in selectorGroup.selectors) {
          final name = selector.simpleSelectorSequences.first.simpleSelector.name;
          Color? color;
          FontSize? fontSize;
          for (final decl in rule.declarationGroup.declarations) {
            if (decl is Declaration) {
              if (decl.property == 'color') {
                color = _parseCssColor(decl.expression.toString());
              }
              if (decl.property == 'font-size') {
                fontSize = _parseCssFontSize(decl.expression.toString());
              }
            }
          }
          styles[name] = Style(color: color, fontSize: fontSize);
        }
      }
    }
    return styles;
  }

  // Helper to parse CSS color strings
  Color? _parseCssColor(String value) {
    value = value.trim();
    if (value.startsWith('#')) {
      final hex = value.substring(1);
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 3) {
        final r = hex[0] * 2, g = hex[1] * 2, b = hex[2] * 2;
        return Color(int.parse('FF$r$g$b', radix: 16));
      }
    }
    // Add more named color support if needed
    return null;
  }

// Helper to parse CSS font-size strings
  FontSize? _parseCssFontSize(String value) {
    value = value.trim();
    if (value.endsWith('px')) {
      final numStr = value.replaceAll('px', '');
      final size = double.tryParse(numStr);
      if (size != null) return FontSize(size);
    }
    if (value.endsWith('em')) {
      final numStr = value.replaceAll('em', '');
      final size = double.tryParse(numStr);
      if (size != null) return FontSize(size * 16); // 1em = 16px default
    }
    final size = double.tryParse(value);
    if (size != null) return FontSize(size);
    return null;
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Restore the system UI when the screen is disposed
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }
}
