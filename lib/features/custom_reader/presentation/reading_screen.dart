// dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import the services package
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:flutter_html_svg/flutter_html_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/epub_parser_service.dart';
import 'package:isar/isar.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:html/parser.dart' as html_parser;
import 'package:csslib/parser.dart' as css_parser;
import 'package:csslib/visitor.dart';
import 'package:visualit/features/custom_reader/application/epub_parser_service.dart';
import 'package:visualit/features/custom_reader/new_reading_controller.dart';
import 'package:visualit/features/custom_reader/model/new_reading_progress.dart';
import 'dart:developer';

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
  late PageController _pageController;
  final ScrollController _scrollController = ScrollController();

  NewReadingController? _readingController;
  Timer? _saveDebounceTimer;

  EpubMetadata? _epubData;
  String? _epubPath;
  int _currentChapterIndex = 0;
  bool _isLoading = true;
  String? _error;
  bool _showOverlay = true;
  double _currentScrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeController();
    //_loadBookAndEpub();
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
      });

      // We'll handle navigation to the correct chapter elsewhere
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeController() async {
    try {
      setState(() {
        _isLoading = true;
      });

      log('Initializing reading controller for bookId: ${widget.bookId}', name: '_ReadingScreenState');
      final isar = await ref.read(isarInstanceProvider.future);
      _readingController = NewReadingController(isar);

      // Load book data first
      await _loadBookAndEpub();

      // Then load reading progress
      final progress = await _readingController!.loadProgress(widget.bookId);

      if (progress != null) {
        _currentChapterIndex = _getChapterIndexFromHref(progress.lastChapterHref);
        _currentScrollOffset = progress.lastScrollOffset;
        log('Restored progress: ChapterIndex=$_currentChapterIndex, ScrollOffset=$_currentScrollOffset',
            name: '_ReadingScreenState');
      }

      // Initialize PageController with the correct starting page
      _pageController = PageController(initialPage: _currentChapterIndex);

      // Complete initialization
      setState(() {
        _isLoading = false;
      });

      // Important: Jump to correct scroll position AFTER the state update has been applied
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_currentScrollOffset);
        }
      });

      _scrollController.addListener(_onScroll);
    } catch (e) {
      log('Error initializing controller: $e', name: '_ReadingScreenState', error: e);
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onScroll() {
    _currentScrollOffset = _scrollController.hasClients ? _scrollController.offset : 0.0;
    _saveDebounceTimer?.cancel();
    _saveDebounceTimer = Timer(const Duration(seconds: 1), () {
      log('Scroll detected. Saving progress...', name: '_ReadingScreenState');
      _saveProgress(bookIndex: widget.bookId, chapterIndex: _currentChapterIndex, scrollOffset: _currentScrollOffset);
    });
  }

  int _getChapterIndexFromHref(String href) {
    if (_epubData == null) return 0;

    final index = _epubData!.chapters.indexWhere((chapter) => chapter.href == href);
    return index >= 0 ? index : 0;
  }

  String _getChapterHrefFromIndex(int index) {
    return _epubData?.chapters[index].href ?? '';
  }

  Future<void> _saveProgress({required int bookIndex, required int chapterIndex, required double scrollOffset}) async {
    log('Saving progress: BookId=$bookIndex, ChapterIndex=$chapterIndex, ScrollOffset=$scrollOffset', name: '_ReadingScreenState');
    if (_readingController != null && _epubData != null) {
      final chapterHref = _getChapterHrefFromIndex(chapterIndex);
      if (chapterHref.isNotEmpty) {
        await _readingController!.saveProgress(bookIndex, chapterHref, scrollOffset);
      } else {
        log('Warning: Could not save progress - invalid chapter href', name: '_ReadingScreenState');
      }
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

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        // Save progress before navigating away
        await _saveProgress(
          bookIndex: widget.bookId,
          chapterIndex: _currentChapterIndex,
          scrollOffset: _currentScrollOffset,
        );

        if (mounted) {
          context.go("/home");
        }
      },
      child: Scaffold(
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
                    _currentScrollOffset = 0.0;
                  });
                  _saveProgress(
                    bookIndex: widget.bookId,
                    chapterIndex: _currentChapterIndex,
                    scrollOffset: _currentScrollOffset,
                  );

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
                            TableHtmlExtension(),
                            SvgHtmlExtension()
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
    ),);
  }

  Widget _buildNavigationBar() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.black.withOpacity(0.8),
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
    final selectorStyles = <String, Style>{};

    for (final cssPath in cssFiles.values) {
      final cssContent = File(cssPath).readAsStringSync();
      final stylesheet = css_parser.parse(cssContent);

      for (final rule in stylesheet.topLevels.whereType<RuleSet>()) {
        final selectorGroup = rule.selectorGroup;
        if (selectorGroup == null) continue;

        for (final selector in selectorGroup.selectors) {
          final selectorText = selector.simpleSelectorSequences.map((seq) {
            final s = seq.simpleSelector;
            if (s is ClassSelector) return '.${s.name}';
            if (s is IdSelector) return '#${s.name}';
            return s.name ?? '';
          }).join('');

          // Compound/descendant selectors
          final fullSelector = selector.simpleSelectorSequences.map((seq) {
            final s = seq.simpleSelector;
            if (s is ClassSelector) return '.${s.name}';
            if (s is IdSelector) return '#${s.name}';
            return s.name ?? '';
          }).join(' ');

          // Parse declarations
          Color? color;
          FontSize? fontSize;
          FontWeight? fontWeight;
          Color? backgroundColor;
          TextAlign? textAlign;
          double? margin;
          double? padding;

          for (final decl in rule.declarationGroup.declarations) {
            if (decl is Declaration) {
              switch (decl.property) {
                case 'color':
                  color = _parseCssColor(decl.expression.toString());
                  break;
                case 'font-size':
                  fontSize = _parseCssFontSize(decl.expression.toString());
                  break;
                case 'font-weight':
                  fontWeight = _parseCssFontWeight(decl.expression.toString());
                  break;
                case 'background-color':
                  backgroundColor = _parseCssColor(decl.expression.toString());
                  break;
                case 'text-align':
                  textAlign = _parseCssTextAlign(decl.expression.toString());
                  break;
                case 'margin':
                  margin = _parseCssSpacing(decl.expression.toString());
                  break;
                case 'padding':
                  padding = _parseCssSpacing(decl.expression.toString());
                  break;
              }
            }
          }

          selectorStyles[fullSelector] = Style(
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
            backgroundColor: backgroundColor,
            textAlign: textAlign,
            margin: margin != null ? Margins.all(margin) : null,
            padding: padding != null ? HtmlPaddings.all(padding) : null,
          );
        }
      }
    }

    // Merge selectorStyles into styles, prioritizing specificity
    styles.addAll(selectorStyles);

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


// Helper for font-weight
  FontWeight? _parseCssFontWeight(String value) {
    value = value.trim();
    switch (value) {
      case 'bold':
      case '700':
        return FontWeight.bold;
      case 'normal':
      case '400':
        return FontWeight.normal;
      case '300':
        return FontWeight.w300;
      case '500':
        return FontWeight.w500;
      case '900':
        return FontWeight.w900;
      default:
        return null;
    }
  }

// Helper for text-align
  TextAlign? _parseCssTextAlign(String value) {
    value = value.trim();
    switch (value) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      case 'left':
        return TextAlign.left;
      case 'justify':
        return TextAlign.justify;
      default:
        return null;
    }
  }

// Helper for margin/padding
  double? _parseCssSpacing(String value) {
    value = value.trim();
    if (value.endsWith('px')) {
      return double.tryParse(value.replaceAll('px', ''));
    }
    if (value.endsWith('em')) {
      final size = double.tryParse(value.replaceAll('em', ''));
      if (size != null) return size * 16;
    }
    return double.tryParse(value);
  }

  @override
  void dispose() {
    // First, cancel any pending debounced saves
    _saveDebounceTimer?.cancel();

    // Force a final save with the current position
    if (_readingController != null && !_isLoading) {
      _saveProgress(
        bookIndex: widget.bookId,
        chapterIndex: _currentChapterIndex,
        scrollOffset: _currentScrollOffset,
      );
    }

    // Then dispose of controllers
    _scrollController.dispose();
    _pageController.dispose();

    // Reset system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);

    super.dispose();
  }
}
