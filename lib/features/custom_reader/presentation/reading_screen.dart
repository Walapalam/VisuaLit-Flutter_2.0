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
import 'package:visualit/features/custom_reader/application/css_parser_service.dart';
import 'package:visualit/features/custom_reader/application/epub_parser_service.dart';
import 'package:visualit/features/custom_reader/new_reading_controller.dart';
import 'package:visualit/features/custom_reader/model/new_reading_progress.dart';
import 'dart:developer';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/core/utils/responsive_helper.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:ui';
import 'package:visualit/features/custom_reader/presentation/widgets/custom_reading_settings_panel.dart';
import 'package:visualit/features/custom_reader/presentation/reading_preferences_controller.dart';
import 'package:visualit/features/custom_reader/presentation/widgets/book_visualization_overlay.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:visualit/features/custom_reader/presentation/widgets/reading_app_bar.dart';
import 'package:visualit/features/custom_reader/presentation/widgets/reading_navigation_bar.dart';
import 'package:visualit/features/custom_reader/presentation/widgets/settings_speed_dial.dart';
import 'package:visualit/features/custom_reader/presentation/widgets/visualization_speed_dial.dart';
import 'package:flutter/services.dart';
import 'package:visualit/core/services/isbn_lookup_service.dart';


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
  final CssParserService _cssParser = CssParserService();
  late PageController _pageController;
  final ScrollController _scrollController = ScrollController();

  NewReadingController? _readingController;
  Timer? _saveDebounceTimer;
  Timer? _hideOverlayTimer;

  EpubMetadata? _epubData;
  String? _epubPath;
  int _currentChapterIndex = 0;
  bool _isLoading = true;
  String? _error;
  bool _showOverlay = true;

  double _currentScrollOffset = 0.0;
  double? _pendingScrollOffset;

  bool _isLocked = false;

// Add to _ReadingScreenState in reading_screen.dart
  bool _isSettingsOverlayVisible = false;
  bool _isVisualizationOverlayVisible = false;
  String? _activeSettingsCategory; // null, 'text', 'theme', or 'layout'
  String? _currentBookIsbn; // Store fetched ISBN for visualization requests

  @override
  void initState() {
    super.initState();
    _initializeController();
    _startHideOverlayTimer();
    //_loadBookAndEpub();
    // Ensure the system UI is visible when the screen is first loaded
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  // Method to toggle the overlay and system UI
  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
      if (_showOverlay) {
        _startHideOverlayTimer();
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
      } else {
        _cancelHideOverlayTimer();
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      }
    });
  }

  void _startHideOverlayTimer() {
    _cancelHideOverlayTimer();
    _hideOverlayTimer = Timer(const Duration(seconds: 5), _hideOverlay);
  }

  void _cancelHideOverlayTimer() {
    _hideOverlayTimer?.cancel();
  }

  void _resetHideOverlayTimer() {
    _cancelHideOverlayTimer();
    _startHideOverlayTimer();
  }

  void _hideOverlay() {
    setState(() {
      if (_showOverlay) {
        _showOverlay = false;
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

      // Fetch ISBN for visualization requests
      await _fetchBookIsbn();

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

      // // DEBUG: Add scroll controller listener to log position changes
      // _scrollController.addListener(() {
      //   log('ScrollController position: ${_scrollController.offset}', name: '_ReadingScreenState');
      // });

      // IMPORTANT: We need a longer delay to ensure both the PageView and ScrollView are ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Give more time for the PageView to settle on the correct page
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_scrollController.hasClients && mounted) {
            log('Attempting to apply scroll offset: $_currentScrollOffset', name: '_ReadingScreenState');

            try {
              // If the scroll position is valid, jump to it
              if (_currentScrollOffset > 0 &&
                  _currentScrollOffset < _scrollController.position.maxScrollExtent) {
                _scrollController.jumpTo(_currentScrollOffset);
                log('Jump to scroll offset successful: $_currentScrollOffset', name: '_ReadingScreenState');
              } else {
                log('Invalid scroll offset: $_currentScrollOffset (max: ${_scrollController.position.maxScrollExtent})',
                    name: '_ReadingScreenState');
              }
            } catch (e) {
              log('Error applying scroll offset: $e', name: '_ReadingScreenState');
            }
          } else {
            log('ScrollController has no clients when trying to restore position', name: '_ReadingScreenState');
          }
        });
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

  String injectCssAndAdjustStyles(String htmlContent, List<String> cssContents) {
    final cssBlock = cssContents.map((css) => '<style>$css</style>').join('\n');
    htmlContent = htmlContent.replaceFirst(
      '</head>',
      '$cssBlock\n</head>',
    );
    htmlContent = htmlContent.replaceAllMapped(
      RegExp(r'(<img[^>]*class="(?:calibre11|calibre12)"[^>]*>)'),
          (match) => '<div style="text-align:center;">${match.group(1)}</div>',
    );
    htmlContent = htmlContent.replaceAll(
      '<p ',
      '<p style="text-align:justify;" ',
    );
    return htmlContent;
  }

  Future<void> _restoreReadingProgress() async {
    try {
      // Add null check to ensure _readingController is not null
      if (_readingController == null) {
        log('Cannot restore reading progress: _readingController is null', name: '_ReadingScreenState');
        return;
      }

      final progress = await _readingController!.loadProgress(widget.bookId);
      if (progress != null && _epubData != null) {
        // Find the chapter index from href
        int chapterIndex = _epubData!.chapters.indexWhere(
                (chapter) => chapter.href == progress.lastChapterHref);

        if (chapterIndex >= 0) {
          setState(() {
            _currentChapterIndex = chapterIndex;
            // Store the scroll offset to be applied when the page is built
            _pendingScrollOffset = progress.lastScrollOffset;
          });

          log('Restored progress: ChapterIndex=$chapterIndex, ScrollOffset=${progress.lastScrollOffset}',
              name: '_ReadingScreenState');

          // Change the page - this will trigger the itemBuilder
          _pageController.jumpToPage(chapterIndex);
        }
      }
    } catch (e) {
      log('Error restoring reading progress: $e', name: '_ReadingScreenState');
    }
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      _currentScrollOffset = _scrollController.offset;
      if (_showOverlay) {
        _resetHideOverlayTimer();
      }

      // Cancel previous debounce timer
      _saveDebounceTimer?.cancel();

      // Schedule a new save with debouncing
      _saveDebounceTimer = Timer(const Duration(seconds: 1), () {
        log('Debounced save triggered. ScrollOffset=$_currentScrollOffset', name: '_ReadingScreenState');
        _saveProgress(
            bookIndex: widget.bookId,
            chapterIndex: _currentChapterIndex,
            scrollOffset: _currentScrollOffset
        );
      });
    }
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

    return WillPopScope(
      onWillPop: () async {
        await _saveProgress(
          bookIndex: widget.bookId,
          chapterIndex: _currentChapterIndex,
          scrollOffset: _currentScrollOffset,
        );
        if (mounted) {
          context.go("/home");
        }
        return false; // Prevent default pop (backgrounding)
      },
      child: Scaffold(
      body: Stack(
        children: [
          // Chapter content with tap to toggle overlay
          Positioned.fill(
            child: Listener(
              onPointerMove: (_) {
                if (_showOverlay) {
                  _resetHideOverlayTimer();
                }
              },
              child: GestureDetector(
                onTap: _isLocked ? null : _toggleOverlay, // Use the new toggle method
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _epubData?.chapters.length ?? 0,
                onPageChanged: (index) {
                  setState(() {
                    _currentChapterIndex = index;
                    // Don't reset _currentScrollOffset to 0.0 here
                  });

                  log("PageView changed to chapter index: $index, Current Scroll Offset: $_currentScrollOffset", name: '_ReadingScreenState');

                  // Save progress when chapter changes
                  _saveProgress(
                    bookIndex: widget.bookId,
                    chapterIndex: _currentChapterIndex,
                    scrollOffset: 0.0, // Starting at the top of the new chapter
                  );

                  _currentScrollOffset = 0.0;
                  // Debug log
                  log('Page changed to chapter $index, resetting scroll to 0.0', name: '_ReadingScreenState');
                },
                itemBuilder: (context, index) {
                  final chapter = _epubData!.chapters[index];
                  debugPrint('Rendering chapter $index: ${chapter.href}');
                  final prefs = ref.watch(readingPreferencesProvider);

                  // Parse CSS styles as fallback
                  Map<String, Style> htmlStyles = _cssParser.parseCssToHtmlStyles(_epubData!.cssFiles);

                  if (prefs.fontSize != 18.0 || prefs.fontFamily != 'Georgia' || prefs.lineHeight != 1.6 || prefs.brightness != 1.0) {
                    // Base style with preferences
                    final baseStyle = prefs.baseTextStyle.copyWith(
                      color: prefs.textColor,
                    );

                    // Override common tags
                    htmlStyles['body'] = Style(
                      fontSize: FontSize(prefs.fontSize),
                      fontFamily: prefs.fontFamily,
                      color: prefs.textColor,
                      lineHeight: LineHeight(prefs.lineHeight),
                      textAlign: TextAlign.justify,
                    );
                    htmlStyles['p'] = htmlStyles['body'] ?? Style();
                    for (int i = 1; i <= 6; i++) {
                      htmlStyles['h$i'] = Style(
                        fontSize: FontSize(prefs.getStyleForHeading(i).fontSize ?? prefs.fontSize),
                        fontFamily: prefs.fontFamily,
                        color: prefs.textColor,
                        fontWeight: prefs.getStyleForHeading(i).fontWeight,
                        lineHeight: LineHeight(prefs.lineHeight),
                        textAlign: TextAlign.center,
                      );
                    }
                  }

                  // Create a local controller variable
                  ScrollController chapterScrollController;

                  // If this is the current chapter being restored, use a special approach
                  if (index == _currentChapterIndex) {
                    // Use the main scroll controller
                    chapterScrollController = _scrollController;

                    // Use a post-frame callback to set the scroll position after the widget is built
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (chapterScrollController.hasClients) {
                        log('Applying scroll offset: $_currentScrollOffset to chapter $index', name: '_ReadingScreenState');
                        try {
                          // Apply the saved scroll position
                          chapterScrollController.jumpTo(_currentScrollOffset);
                        } catch (e) {
                          log('Error applying scroll offset: $e', name: '_ReadingScreenState');
                        }
                      } else {
                        log('ScrollController has no clients in post-frame callback', name: '_ReadingScreenState');
                      }
                    });
                  } else {
                    // For non-active chapters, use a separate controller
                    chapterScrollController = ScrollController();
                  }

                  return Container(
                    color: prefs.pageColor,
                    padding: EdgeInsets.only(
                      left: 2.0,//prefs.leftPadding,
                      right: 2.0, //prefs.rightPadding,
                      top: 0.0,
                      bottom: prefs.bottomPadding,
                    ),
                    child: SingleChildScrollView(
                    controller: chapterScrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 100.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Html(
                          data: chapter.content, // Use processed content with local file URIs
                          style: htmlStyles,
                          extensions: [
                            // Existing img tag extension
                            TagExtension(
                              tagsToExtend: {"img"},
                              builder: (context) {
                                final src = context.attributes['src'];
                                if (src != null && src.isNotEmpty) {
                                  return _buildImageWidget(src, _epubData!.chapters[_currentChapterIndex].href);
                                }
                                return const SizedBox.shrink();
                              },
                            ),

                            // NEW: Separate SVG image extension
                            TagExtension(
                              tagsToExtend: {"image"},
                              builder: (context) {
                                print('DEBUG: Processing SVG image element');
                                print('DEBUG: All attributes: ${context.attributes}');

                                // Get the href from xlink:href or href attribute
                                final xlinkHref = context.attributes['xlink:href'];
                                final href = context.attributes['href'];
                                final imageRef = xlinkHref ?? href;

                                print('DEBUG: xlink:href=$xlinkHref, href=$href, final=$imageRef');

                                if (imageRef != null && imageRef.isNotEmpty) {
                                  print('DEBUG: Building SVG image widget for: $imageRef');
                                  return _buildImageWidget(imageRef, _epubData!.chapters[_currentChapterIndex].href);
                                }

                                print('DEBUG: No valid href found in SVG image element');
                                return const SizedBox.shrink();
                              },
                            ),

                            ImageExtension(
                              builder: (extensionContext) {
                                final src = extensionContext.attributes['src'];
                                if (src != null && src.isNotEmpty) {
                                  return _buildImageWidget(src, _epubData!.chapters[_currentChapterIndex].href);
                                }
                                return const SizedBox.shrink();
                              },
                            ),

                            TableHtmlExtension(),

                            TagExtension(
                              tagsToExtend: {"svg"},
                              builder: (context) {
                                print('DEBUG: Processing SVG element with attributes: ${context.attributes}');

                                // Get the raw SVG content
                                final element = context.element;
                                if (element != null) {
                                  print('DEBUG: Full SVG element HTML: ${element.outerHtml}');
                                  print('DEBUG: SVG children count: ${element.children.length}');

                                  // Check each child element
                                  for (int i = 0; i < element.children.length; i++) {
                                    final child = element.children[i];
                                    print('DEBUG: SVG child $i: tag=${child.localName}, attributes=${child.attributes}');

                                    if (child.localName == 'image') {
                                      // print(child.attributes.entries.last.value);
                                      final xlinkHref = child.attributes.entries.last.value;
                                      final href = child.attributes['href'];
                                      final imageRef = xlinkHref ?? href;

                                      print('DEBUG: Found image child with href: $imageRef');

                                      if (imageRef != null && imageRef.isNotEmpty) {
                                        return _buildImageWidget(imageRef, _epubData!.chapters[_currentChapterIndex].href);
                                      }
                                    }
                                  }
                                }

                                return const SizedBox.shrink();
                              },
                            ),

                            SvgHtmlExtension(
                              networkSchemas: ["https", "http", "file"],
                              extension: "svg",
                              dataEncoding: "base64",
                              dataMimeType: "image/svg+xml",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),);
                },
              ),
            ),
          ),),
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
                child: ReadingAppBar(
                  bookTitle: _epubData?.title ?? 'Unknown',
                  chapterTitle: _currentChapterIndex < (_epubData?.chapters.length ?? 0)
                      ? _epubData!.chapters[_currentChapterIndex].title
                      : 'Chapter ${_currentChapterIndex + 1}',
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
                  child: ReadingNavigationBar(
                    onPreviousChapter: _currentChapterIndex > 0
                        ? () {
                      _cancelHideOverlayTimer();
                      _previousChapter();
                    }
                        : null,
                    onNextChapter: _currentChapterIndex < (_epubData?.chapters.length ?? 0) - 1
                        ? () {
                      _cancelHideOverlayTimer();
                      _nextChapter();
                    }
                        : null,
                    onChapterListTap: () {
                      _cancelHideOverlayTimer();
                      _showChapterBottomSheet();
                    },
                    currentChapterIndex: _currentChapterIndex,
                    totalChapters: _epubData?.chapters.length ?? 0,
                    settingsSpeedDial: SettingsSpeedDial(
                      isLocked: _isLocked,
                      onToggleLock: () {
                        _cancelHideOverlayTimer();
                        setState(() => _isLocked = !_isLocked);
                      },
                      onShowSettingsPanel: _showSettingsPanel,
                      onShowBookmark: () {
                        _cancelHideOverlayTimer();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Bookmark added')),
                        );
                      },
                      onShare: () {
                        _cancelHideOverlayTimer();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Share feature coming soon')),
                        );
                      },
                      onSearch: () {
                        _cancelHideOverlayTimer();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Search feature coming soon')),
                        );
                      },
                      isVisible: _showOverlay,
                    ),
                    visualizationSpeedDial: VisualizationSpeedDial(
                      isVisible: _showOverlay,
                      onToggleVisualization: _showBookOverviewDialog,
                      onAdjustVisualization: () {
                        _cancelHideOverlayTimer();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Visualization settings coming soon')),
                        );
                      },
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
            ),
          ),

          if (_isSettingsOverlayVisible)
            GestureDetector(
              onTap: _hideSettingsPanel,
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: Colors.transparent,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          if (_isSettingsOverlayVisible)
            CustomReadingSettingsPanel(
              category: 'text',
              onBack: _hideSettingsPanel,
              scrollController: ScrollController(), // <-- provide a controller
            ),
          if (_isVisualizationOverlayVisible)
            Positioned(
              top: 130, // Adjust based on your app bar height
              left: 0,
              right: 0,
              bottom: 80, // Adjust based on your navigation bar height
              child: BookVisualizationOverlay(
                bookTitleForLookup: _epubData?.title ?? 'Unknown',
                localBookISBN: _currentBookIsbn, // Pass the fetched ISBN
                localChapterNumber: () {
                  final chapterNum = _epubData?.chapters[_currentChapterIndex].chapterNumber ?? (_currentChapterIndex + 1);
                  print('📖 DEBUG: Using uniform chapter number for backend: $chapterNum (Index: $_currentChapterIndex)');
                  return chapterNum;
                }(),
                localChapterContent: _epubData?.chapters[_currentChapterIndex].content ?? '',
                onClose: _hideVisualizationOverlay,
              ),
            ),
        ],
      ),
    ),);
  }

  Widget _buildImageWidget(String src, String chapterHref) {
    print('Building image widget for src: $src');

    // Handle file:// URIs
    if (src.startsWith('file://')) {
      final filePath = Uri.parse(src).toFilePath();
      if (File(filePath).existsSync()) {
        return Center(
          child: Image.file(
            File(filePath),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorWidget('Image failed to load');
            },
          ),
        );
      }
    }

    // Skip external URLs and data URIs
    if (src.startsWith('data:') ||
        src.startsWith('http:') ||
        src.startsWith('https:')) {
      return const SizedBox.shrink();
    }

    // Handle relative paths
    final chapterDir = p.dirname(chapterHref);
    String resolvedPath;

    if (src.startsWith('../')) {
      resolvedPath = p.normalize(p.join(chapterDir, src));
    } else if (src.startsWith('./')) {
      resolvedPath = p.normalize(p.join(chapterDir, src.substring(2)));
    } else if (!src.startsWith('/')) {
      resolvedPath = p.normalize(p.join(chapterDir, src));
    } else {
      resolvedPath = src.substring(1);
    }

    resolvedPath = resolvedPath.replaceAll(r'\', '/');
    print('Resolved image path: $resolvedPath');

    final localFile = _epubData!.images[resolvedPath];
    if (localFile != null && File(localFile).existsSync()) {
      return Center(
        child: Image.file(
          File(localFile),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorWidget('Image failed to load');
          },
        ),
      );
    }

    print('Image not found for path: $resolvedPath');
    return _buildErrorWidget('Image not found');
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.broken_image),
          Text(message),
        ],
      ),
    );
  }

  void _showChapterBottomSheet() {
    _cancelHideOverlayTimer();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Make the sheet itself transparent
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.6,
        expand: false,
        builder: (context, scrollController) => Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // _buildNavigationBar(backgroundColor: Colors.transparent),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.9), // Your desired background color
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _epubData?.chapters.length ?? 0,
                    itemBuilder: (context, index) {
                      final chapter = _epubData!.chapters[index];
                      return ListTile(
                        title: Text(
                          chapter.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: _currentChapterIndex == index
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: _currentChapterIndex == index
                            ? Icon(Icons.check_circle, color: Colors.blue)
                            : null,
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
              )
            ],
          ),
        ),
      ),
    );
  }


  void _showAdvancedSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => CustomReadingSettingsPanel(
          category: 'advanced',
          onBack: () => Navigator.pop(context),
          scrollController: scrollController, // <-- add this
        ),
      ),
    );
  }


  void _showSettingsPanel() {
    _cancelHideOverlayTimer();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true, // Allow dismissal by tapping outside
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.40,
        minChildSize: 0.40,
        maxChildSize: 0.70,
        expand: true, // Locks the sheet at 55% height
        builder: (context, scrollController) => CustomReadingSettingsPanel(
          category: 'text',
          onBack: () => Navigator.pop(context),
          scrollController: scrollController,
        ),
      ),
    );
  }

  Future<void> _fetchBookIsbn() async {
    if (_epubData?.title != null && _epubData!.title.isNotEmpty) {
      try {
        print('📚 DEBUG: Fetching ISBN for book: "${_epubData!.title}"');
        _currentBookIsbn = await IsbnLookupService.lookupIsbnByTitle(_epubData!.title);
        print('📚 DEBUG: Fetched ISBN: $_currentBookIsbn');
        setState(() {}); // Update UI with fetched ISBN
      } catch (e) {
        print('📚 DEBUG: Failed to fetch ISBN: $e');
        _currentBookIsbn = null;
      }
    } else {
      print('📚 DEBUG: No book title available for ISBN lookup');
    }
  }

  void _showBookOverviewDialog() {
    setState(() {
      _isVisualizationOverlayVisible = true;
    });
  }

  void _hideVisualizationOverlay() {
    setState(() {
      _isVisualizationOverlayVisible = false;
    });
  }

  void _hideSettingsPanel() {
    setState(() {
      _isSettingsOverlayVisible = false;
    });
  }


  void _showBookOverview() {
    // Will implement this method to show book info/visualization
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Book Overview'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${_epubData?.title ?? "Unknown"}'),
            const SizedBox(height: 8),
            Text('Author: ${_epubData?.author ?? "Unknown"}'),
            const SizedBox(height: 8),
            Text('${_epubData?.chapters.length ?? 0} chapters'),
          ],
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

  void _previousChapter() {
    _cancelHideOverlayTimer();
    if (_currentChapterIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextChapter() {
    _cancelHideOverlayTimer();
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

  @override
  void dispose() {
    _hideOverlayTimer?.cancel();
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
