import 'dart:async';
import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:visualit/features/custom_reader/new_reading_controller.dart';
import 'package:visualit/features/custom_reader/application/epub_parser_service.dart';
import 'package:visualit/features/custom_reader/application/css_parser_service.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/custom_reader/presentation/reading_preferences_controller.dart';
import 'package:visualit/features/custom_reader/presentation/widgets/apple_reading_settings_dialog.dart';
import 'package:visualit/features/custom_reader/presentation/widgets/book_visualization_overlay.dart';
import 'package:visualit/features/custom_reader/presentation/widgets/chapter_content.dart';

import 'package:visualit/features/custom_reader/presentation/widgets/reading_navigation_bar.dart';
import 'package:visualit/features/custom_reader/presentation/widgets/settings_speed_dial.dart';
import 'package:visualit/features/custom_reader/presentation/widgets/visualization_speed_dial.dart';
import 'package:visualit/features/custom_reader/presentation/widgets/reading_app_bar.dart';
import 'package:visualit/features/custom_reader/presentation/reading_constants.dart';
import 'package:visualit/features/custom_reader/presentation/widgets/chapter_list_sheet.dart';
import 'package:visualit/core/services/toast_service.dart';
import 'package:visualit/features/reader/application/throttled_reading_progress_notifier.dart';
import 'package:visualit/features/custom_reader/presentation/controllers/pagination_controller.dart';
import 'package:visualit/features/custom_reader/presentation/controllers/book_progress_controller.dart';
import 'package:visualit/features/custom_reader/application/epub_paginator_service.dart';
import 'package:visualit/features/custom_reader/presentation/widgets/paginated_reading_view.dart';

class ReadingScreen extends ConsumerStatefulWidget {
  final int bookId;

  const ReadingScreen({Key? key, required this.bookId}) : super(key: key);

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

  List<PageContent> _paginatedPages = [];
  bool _isPaginating = true;

  @override
  void initState() {
    super.initState();
    // Set reading session start time for streak tracking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final existingSessionStart = ref.read(readingSessionStartProvider);
      final now = DateTime.now();

      if (existingSessionStart == null) {
        // New session
        ref.read(readingSessionStartProvider.notifier).state = now;
        print('📖 Reading Session: STARTED at ${now.toString()}');
        print('📖 Session Start Time: ${now.hour}:${now.minute}:${now.second}');
      } else {
        // Continuing existing session
        final elapsed = now.difference(existingSessionStart);
        print(
          '📖 Reading Session: RESUMED (session started ${elapsed.inMinutes} minutes ago)',
        );
        print(
          '📖 Original Start Time: ${existingSessionStart.hour}:${existingSessionStart.minute}:${existingSessionStart.second}',
        );
        print('📖 Current Time: ${now.hour}:${now.minute}:${now.second}');
        print(
          '📖 Total Elapsed: ${elapsed.inMinutes} min ${elapsed.inSeconds % 60} sec',
        );
      }
    });
    _initializeController();
    _startHideOverlayTimer();
    //_loadBookAndEpub();
    // Ensure the system UI is visible when the screen is first loaded
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  // Method to toggle the overlay and system UI
  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
      if (_showOverlay) {
        _startHideOverlayTimer();
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
      } else {
        _cancelHideOverlayTimer();
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      }
    });
  }

  void _startHideOverlayTimer() {
    _cancelHideOverlayTimer();
    // Don't start timer if any overlay is visible
    if (_isSettingsOverlayVisible ||
        _isVisualizationOverlayVisible ||
        _isLocked) {
      return;
    }
    _hideOverlayTimer = Timer(const Duration(seconds: 5), _hideOverlay);
  }

  void _cancelHideOverlayTimer() {
    _hideOverlayTimer?.cancel();
  }

  void _resetHideOverlayTimer() {
    _cancelHideOverlayTimer();
    _startHideOverlayTimer();
  }

  void _togglePaginationMode() {
    ref.read(paginationControllerProvider.notifier).togglePaginationMode();
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

      // RESOLVE PATH: Convert potentially relative path to absolute
      String absolutePath = book.epubFilePath;
      if (!absolutePath.startsWith('/')) {
        final dir = Platform.isAndroid
            ? await getExternalStorageDirectory()
            : await getApplicationDocumentsDirectory();

        if (dir != null) {
          final libraryRoot = Directory('${dir.path}/VisuaLit');
          absolutePath = '${libraryRoot.path}/$absolutePath';
        }
      }

      // Update the state variable with the resolved path
      _epubPath = absolutePath;

      final file = File(absolutePath);
      if (!await file.exists()) {
        if (absolutePath.contains('/cache/file_picker/') ||
            absolutePath.contains('/cache/')) {
          setState(() {
            _error =
                'FILE_NOT_FOUND_CACHE'; // Special error code for UI handling
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = 'FILE_NOT_FOUND'; // Generic file not found
            _isLoading = false;
          });
        }
        return;
      }

      final epubData = await _epubParser.parseEpub(absolutePath);

      setState(() {
        _epubData = epubData;
        _isLoading = false;
      });

      // Analyze book for progress estimation
      ref.read(bookProgressControllerProvider.notifier).analyzeBook(epubData);
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

      log(
        'Initializing reading controller for bookId: ${widget.bookId}',
        name: '_ReadingScreenState',
      );
      final isar = await ref.read(isarInstanceProvider.future);
      _readingController = NewReadingController(isar);

      // Load book data first
      await _loadBookAndEpub();

      // Then load reading progress
      final progress = await _readingController!.loadProgress(widget.bookId);
      final isPaginated = ref
          .read(paginationControllerProvider)
          .isPaginatedMode;

      if (progress != null) {
        if (isPaginated) {
          // Load Paginated Progress
          if (progress.lastPaginatedChapterHref != null) {
            _currentChapterIndex = _getChapterIndexFromHref(
              progress.lastPaginatedChapterHref!,
            );
            log(
              'Restored PAGINATED progress: ChapterIndex=$_currentChapterIndex, Page=${progress.lastPaginatedPageIndex}',
              name: '_ReadingScreenState',
            );
          } else {
            // No paginated progress found, start from beginning or default
            _currentChapterIndex = 0;
            log(
              'No PAGINATED progress found, starting at Chapter 0',
              name: '_ReadingScreenState',
            );
          }
        } else {
          // Load Scroll Progress
          // We use lastChapterHref for scroll mode (legacy/default)
          if (progress.lastChapterHref.isNotEmpty) {
            _currentChapterIndex = _getChapterIndexFromHref(
              progress.lastChapterHref,
            );
            _currentScrollOffset = progress.lastScrollOffset;
            log(
              'Restored SCROLL progress: ChapterIndex=$_currentChapterIndex, ScrollOffset=$_currentScrollOffset',
              name: '_ReadingScreenState',
            );
          } else {
            _currentChapterIndex = 0;
            _currentScrollOffset = 0.0;
            log(
              'No SCROLL progress found, starting at Chapter 0',
              name: '_ReadingScreenState',
            );
          }
        }
      }

      // Initialize PageController with the correct starting page
      _pageController = PageController(initialPage: _currentChapterIndex);

      // Initial pagination
      await _paginateChapter();

      // Restore page index if paginated
      if (isPaginated &&
          progress?.lastPaginatedPageIndex != null &&
          _paginatedPages.isNotEmpty) {
        final pageIndex = progress!.lastPaginatedPageIndex!;
        if (pageIndex < _paginatedPages.length) {
          // We need to wait for the view to build before jumping
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageController.hasClients) {
              _pageController.jumpToPage(pageIndex);
            }
          });
        }
      }

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
            log(
              'Attempting to apply scroll offset: $_currentScrollOffset',
              name: '_ReadingScreenState',
            );

            try {
              // If the scroll position is valid, jump to it
              if (_currentScrollOffset > 0 &&
                  _currentScrollOffset <
                      _scrollController.position.maxScrollExtent) {
                _scrollController.jumpTo(_currentScrollOffset);
                log(
                  'Jump to scroll offset successful: $_currentScrollOffset',
                  name: '_ReadingScreenState',
                );
              } else {
                log(
                  'Invalid scroll offset: $_currentScrollOffset (max: ${_scrollController.position.maxScrollExtent})',
                  name: '_ReadingScreenState',
                );
              }
            } catch (e) {
              log(
                'Error applying scroll offset: $e',
                name: '_ReadingScreenState',
              );
            }
          } else {
            log(
              'ScrollController has no clients when trying to restore position',
              name: '_ReadingScreenState',
            );
          }
        });
      });

      _scrollController.addListener(_onScroll);
    } catch (e) {
      log(
        'Error initializing controller: $e',
        name: '_ReadingScreenState',
        error: e,
      );
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String injectCssAndAdjustStyles(
    String htmlContent,
    List<String> cssContents,
  ) {
    final cssBlock = cssContents.map((css) => '<style>$css</style>').join('\n');
    htmlContent = htmlContent.replaceFirst('</head>', '$cssBlock\n</head>');
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
        log(
          'Debounced save triggered. ScrollOffset=$_currentScrollOffset',
          name: '_ReadingScreenState',
        );
        _saveProgress(
          bookIndex: widget.bookId,
          chapterIndex: _currentChapterIndex,
          scrollOffset: _currentScrollOffset,
        );
      });
    }
  }

  int _getChapterIndexFromHref(String href) {
    if (_epubData == null) return 0;

    final index = _epubData!.chapters.indexWhere(
      (chapter) => chapter.href == href,
    );
    return index >= 0 ? index : 0;
  }

  String _getChapterHrefFromIndex(int index) {
    return _epubData?.chapters[index].href ?? '';
  }

  Future<void> _saveProgress({
    required int bookIndex,
    required int chapterIndex,
    required double scrollOffset,
    int? pageIndex,
  }) async {
    final sessionStart = ref.read(readingSessionStartProvider);
    final isPaginated = ref.read(paginationControllerProvider).isPaginatedMode;

    log(
      'Saving progress: BookId=$bookIndex, ChapterIndex=$chapterIndex, ScrollOffset=$scrollOffset, PageIndex=$pageIndex, Mode=${isPaginated ? "PAGINATED" : "SCROLL"}',
      name: '_ReadingScreenState',
    );
    if (_readingController != null && _epubData != null) {
      final chapterHref = _getChapterHrefFromIndex(chapterIndex);
      if (chapterHref.isNotEmpty) {
        if (isPaginated) {
          await _readingController!.saveProgress(
            bookIndex,
            chapterHref,
            null, // No scroll offset for pagination
            paginatedChapterHref: chapterHref,
            paginatedPageIndex: pageIndex ?? 0,
            sessionStart: sessionStart,
          );
        } else {
          await _readingController!.saveProgress(
            bookIndex,
            chapterHref,
            scrollOffset,
            sessionStart: sessionStart,
          );
        }
      } else {
        log(
          'Warning: Could not save progress - invalid chapter href',
          name: '_ReadingScreenState',
        );
      }
    }
  }

  EdgeInsets _getReadingPadding(MediaQueryData mediaQuery) {
    final safePadding = mediaQuery.padding;
    return EdgeInsets.only(
      top: safePadding.top, // Minimized top padding
      bottom: safePadding.bottom + 100.0,
      left: 24.0,
      right: 24.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to preferences changes to re-paginate
    ref.listen(readingPreferencesProvider, (previous, next) {
      if (previous != next &&
          ref.read(paginationControllerProvider).isPaginatedMode) {
        _paginateChapter();
      }
    });

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final mediaQuery = MediaQuery.of(context);
    final padding = _getReadingPadding(mediaQuery);

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cannot Open Book'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 24),
                if (_error == 'FILE_NOT_FOUND_CACHE') ...[
                  const Text(
                    'Book File Missing',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'This book was imported before the storage fix and the temporary file has been cleaned up by the system.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please remove this book and re-import it to store it permanently.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final isar = await ref.read(isarInstanceProvider.future);
                      await isar.writeTxn(() async {
                        await isar.books.delete(widget.bookId);
                      });
                      if (context.mounted) {
                        ToastService.show(
                          context,
                          'Book removed. You can now re-import it.',
                          type: ToastType.success,
                        );
                        context.pop();
                      }
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remove This Book'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ] else if (_error == 'FILE_NOT_FOUND') ...[
                  const Text(
                    'File Not Found',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'The book file may have been moved or deleted:\n\n$_epubPath',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                  ),
                ] else ...[
                  const Text(
                    'Error Loading Book',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                  ),
                ],
              ],
            ),
          ),
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
                  onDoubleTap: _isLocked ? null : _toggleOverlay,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _epubData?.chapters.length ?? 0,
                    onPageChanged: (index) {
                      setState(() {
                        _currentChapterIndex = index;
                        // Don't reset _currentScrollOffset to 0.0 here
                      });

                      log(
                        "PageView changed to chapter index: $index, Current Scroll Offset: $_currentScrollOffset",
                        name: '_ReadingScreenState',
                      );

                      // Save progress when chapter changes
                      _saveProgress(
                        bookIndex: widget.bookId,
                        chapterIndex: _currentChapterIndex,
                        scrollOffset:
                            0.0, // Starting at the top of the new chapter
                      );

                      _paginateChapter(); // Re-paginate for new chapter

                      _currentScrollOffset = 0.0;
                      // Debug log
                      log(
                        'Page changed to chapter $index, resetting scroll to 0.0',
                        name: '_ReadingScreenState',
                      );
                    },
                    itemBuilder: (context, index) {
                      final chapter = _epubData!.chapters[index];
                      debugPrint('Rendering chapter $index: ${chapter.href}');
                      final prefs = ref.watch(readingPreferencesProvider);

                      // Parse CSS styles as fallback
                      Map<String, Style> htmlStyles = _cssParser
                          .parseCssToHtmlStyles(_epubData!.cssFiles);

                      if (prefs.fontSize != 18.0 ||
                          prefs.fontFamily != 'Georgia' ||
                          prefs.lineHeight != 1.6 ||
                          prefs.brightness != 1.0) {
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
                            fontSize: FontSize(
                              prefs.getStyleForHeading(i).fontSize ??
                                  prefs.fontSize,
                            ),
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
                            log(
                              'Applying scroll offset: $_currentScrollOffset to chapter $index',
                              name: '_ReadingScreenState',
                            );
                            try {
                              // Apply the saved scroll position
                              chapterScrollController.jumpTo(
                                _currentScrollOffset,
                              );
                            } catch (e) {
                              log(
                                'Error applying scroll offset: $e',
                                name: '_ReadingScreenState',
                              );
                            }
                          } else {
                            log(
                              'ScrollController has no clients in post-frame callback',
                              name: '_ReadingScreenState',
                            );
                          }
                        });
                      } else {
                        // For non-active chapters, use a separate controller
                        chapterScrollController = ScrollController();
                      }

                      return Stack(
                        children: [
                          // Vertical View (Always present, but hidden in paginated mode)
                          IgnorePointer(
                            ignoring: ref
                                .watch(paginationControllerProvider)
                                .isPaginatedMode,
                            child: Opacity(
                              opacity:
                                  ref
                                      .watch(paginationControllerProvider)
                                      .isPaginatedMode
                                  ? 0.0
                                  : 1.0,
                              child: Container(
                                color: prefs.pageColor,
                                padding: EdgeInsets.only(
                                  left: 2.0, //prefs.leftPadding,
                                  right: 2.0, //prefs.rightPadding,
                                  top: 0.0,
                                  bottom: prefs.bottomPadding,
                                ),
                                child: NotificationListener<Notification>(
                                  onNotification: (notification) {
                                    if (notification
                                        is OverscrollNotification) {
                                      if (notification.overscroll > 0) {
                                        // Overscroll at bottom -> Next Chapter
                                        if (_currentChapterIndex <
                                            (_epubData?.chapters.length ?? 0) -
                                                1) {
                                          _goToNextChapter();
                                        }
                                      } else if (notification.overscroll < 0) {
                                        // Overscroll at top -> Previous Chapter
                                        if (_currentChapterIndex > 0) {
                                          _goToPreviousChapter();
                                        }
                                      }
                                    }

                                    if (notification
                                        is ScrollMetricsNotification) {
                                      ref
                                          .read(
                                            paginationControllerProvider
                                                .notifier,
                                          )
                                          .updateMetrics(notification.metrics);
                                      final paginationState = ref.read(
                                        paginationControllerProvider,
                                      );
                                      ref
                                          .read(
                                            bookProgressControllerProvider
                                                .notifier,
                                          )
                                          .updateProgress(
                                            currentChapterIndex:
                                                _currentChapterIndex,
                                            currentChapterPage:
                                                paginationState.currentPage,
                                            totalChapterPages:
                                                paginationState.totalPages,
                                          );
                                    }

                                    return false;
                                  },
                                  child: SingleChildScrollView(
                                    physics:
                                        ref
                                            .watch(paginationControllerProvider)
                                            .isPaginatedMode
                                        ? const NeverScrollableScrollPhysics() // Disable user scroll in paginated mode
                                        : const ClampingScrollPhysics(),
                                    controller: chapterScrollController,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 0.0,
                                      vertical: 100.0,
                                    ),
                                    child: ChapterContent(
                                      chapter: chapter,
                                      chapterHref: _epubData!
                                          .chapters[_currentChapterIndex]
                                          .href,
                                      htmlStyles: htmlStyles,
                                      imageBuilder: (src, chapterHref) =>
                                          _buildImageWidget(src, chapterHref),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Horizontal View (Only in paginated mode)
                          // Horizontal View (Only in paginated mode)
                          if (ref
                              .watch(paginationControllerProvider)
                              .isPaginatedMode)
                            if (_isPaginating)
                              const Center(child: CircularProgressIndicator())
                            else
                              PaginatedReadingView(
                                pages: _paginatedPages,
                                initialPageIndex: 0,
                                onPageChanged: (index) {
                                  // Update pagination controller
                                  ref
                                      .read(
                                        paginationControllerProvider.notifier,
                                      )
                                      .updatePage(index);

                                  // Update book progress
                                  final paginationState = ref.read(
                                    paginationControllerProvider,
                                  );
                                  ref
                                      .read(
                                        bookProgressControllerProvider.notifier,
                                      )
                                      .updateProgress(
                                        currentChapterIndex:
                                            _currentChapterIndex,
                                        currentChapterPage:
                                            index + 1, // 1-based for display
                                        totalChapterPages:
                                            paginationState.totalPages,
                                      );

                                  // Save progress for pagination
                                  _saveProgress(
                                    bookIndex: widget.bookId,
                                    chapterIndex: _currentChapterIndex,
                                    scrollOffset:
                                        0, // Ignored in pagination mode
                                    pageIndex: index,
                                  );
                                },
                                onNextChapter: _goToNextChapter,
                                onPreviousChapter: _goToPreviousChapter,
                                imageBuilder: (src) => _buildImageWidget(
                                  src,
                                  _epubData!
                                      .chapters[_currentChapterIndex]
                                      .href,
                                ),
                                padding: padding,
                              ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            // Overlay AppBar
            if (!_isLocked)
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
                      chapterTitle:
                          _currentChapterIndex <
                              (_epubData?.chapters.length ?? 0)
                          ? _epubData!.chapters[_currentChapterIndex].title
                          : 'Chapter ${_currentChapterIndex + 1}',
                    ),
                  ),
                ),
              ),
            // Overlay navigation bar
            if (!_isLocked)
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
                            ? _goToPreviousChapter
                            : null,
                        onNextChapter:
                            _currentChapterIndex <
                                (_epubData?.chapters.length ?? 0) - 1
                            ? _goToNextChapter
                            : null,
                        onChapterListTap: () {
                          _cancelHideOverlayTimer();
                          _showChapterBottomSheet();
                        },
                        currentChapterIndex: _currentChapterIndex,
                        totalChapters: _epubData?.chapters.length ?? 0,
                        currentPage: ref
                            .watch(paginationControllerProvider)
                            .currentPage,
                        totalPages: ref
                            .watch(paginationControllerProvider)
                            .totalPages,
                        currentBookPage: ref
                            .watch(bookProgressControllerProvider)
                            .currentBookPage,
                        totalBookPages: ref
                            .watch(bookProgressControllerProvider)
                            .totalBookPages,
                        settingsSpeedDial: SettingsSpeedDial(
                          isLocked: _isLocked,
                          onToggleLock: () {
                            _cancelHideOverlayTimer();
                            setState(() => _isLocked = !_isLocked);
                          },
                          onShowSettingsPanel: _showSettingsPanel,
                          onShowBookmark: () {
                            _cancelHideOverlayTimer();
                            ToastService.show(
                              context,
                              'Bookmark added',
                              type: ToastType.success,
                            );
                          },
                          onShare: () {
                            _cancelHideOverlayTimer();
                            ToastService.show(
                              context,
                              'Share feature coming soon',
                              type: ToastType.info,
                            );
                          },
                          onSearch: () {
                            _cancelHideOverlayTimer();
                            ToastService.show(
                              context,
                              'Search feature coming soon',
                              type: ToastType.info,
                            );
                          },
                          onTogglePagination: _togglePaginationMode,
                          isPaginatedMode: ref
                              .watch(paginationControllerProvider)
                              .isPaginatedMode,
                          isVisible: _showOverlay,
                        ),
                        visualizationSpeedDial: VisualizationSpeedDial(
                          isVisible: _showOverlay,
                          onToggleVisualization: _showBookOverviewDialog,
                          onAdjustVisualization: () {
                            _cancelHideOverlayTimer();
                            ToastService.show(
                              context,
                              'Settings feature coming soon',
                              type: ToastType.info,
                            );
                          },
                        ),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ),

            // Unlock Button (Only visible when locked)
            if (_isLocked)
              Positioned(
                bottom: 32,
                left: 32,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isLocked = false;
                      _showOverlay = true;
                      _startHideOverlayTimer();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),

            if (_isVisualizationOverlayVisible)
              Positioned(
                top: kReadingTopBarHeight,
                bottom: kReadingBottomBarHeight,
                left: 0,
                right: 0,
                child: BookVisualizationOverlay(
                  bookTitleForLookup: _epubData?.title ?? 'Unknown',
                  localBookISBN: null,
                  localChapterNumber: _currentChapterIndex + 1,
                  localChapterContent:
                      _epubData?.chapters[_currentChapterIndex].content ?? '',
                  onClose: _hideVisualizationOverlay,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String src, String chapterHref) {
    print('Building image widget for src: $src');

    // Handle file:// URIs
    if (src.startsWith('file://')) {
      final filePath = Uri.parse(src).toFilePath();
      if (File(filePath).existsSync()) {
        if (filePath.toLowerCase().endsWith('.svg')) {
          return Center(
            child: SvgPicture.file(
              File(filePath),
              fit: BoxFit.contain,
              placeholderBuilder: (context) =>
                  const CircularProgressIndicator(),
            ),
          );
        }
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
      if (localFile.toLowerCase().endsWith('.svg')) {
        return Center(
          child: SvgPicture.file(
            File(localFile),
            fit: BoxFit.contain,
            placeholderBuilder: (context) => const CircularProgressIndicator(),
          ),
        );
      }
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
        children: [const Icon(Icons.broken_image), Text(message)],
      ),
    );
  }

  void _showChapterBottomSheet() {
    _cancelHideOverlayTimer();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8, // Taller to show "fake" nav bar effect
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => ChapterListSheet(
          scrollController: scrollController,
          chapters: _epubData?.chapters ?? [],
          currentChapterIndex: _currentChapterIndex,
          onChapterSelected: (index) {
            Navigator.pop(context);
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          onClose: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _showSettingsPanel() {
    _cancelHideOverlayTimer();
    setState(() {
      _isSettingsOverlayVisible = true;
    });

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => const AppleReadingSettingsDialog(),
    ).then((_) {
      if (mounted) {
        setState(() {
          _isSettingsOverlayVisible = false;
        });
      }
    });
  }

  void _showBookOverviewDialog() {
    setState(() {
      _isVisualizationOverlayVisible = true;
      _showOverlay = true; // Ensure UI is visible
      _cancelHideOverlayTimer(); // Cancel timer so UI stays visible
    });
  }

  void _hideVisualizationOverlay() {
    setState(() {
      _isVisualizationOverlayVisible = false;
    });
  }

  void _goToPreviousChapter() {
    if (_currentChapterIndex > 0) {
      _cancelHideOverlayTimer();
      _previousChapter();
    }
  }

  void _goToNextChapter() {
    if (_currentChapterIndex < (_epubData?.chapters.length ?? 0) - 1) {
      _cancelHideOverlayTimer();
      _nextChapter();
    }
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
    if (_currentChapterIndex < (_epubData?.chapters.length ?? 0) - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _debugPrintChapterCssLinks(EpubChapter chapter) {
    final document = html_parser.parse(chapter.content);
    final cssLinks =
        document.head?.querySelectorAll('link[rel="stylesheet"]') ?? [];
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

  void _debugPrintChapterCssContents(
    EpubChapter chapter,
    Map<String, String> allCssFiles,
  ) {
    final document = html_parser.parse(chapter.content);
    final cssLinks =
        document.head?.querySelectorAll('link[rel="stylesheet"]') ?? [];
    final chapterDir = p.dirname(chapter.href);

    for (final link in cssLinks) {
      final href = link.attributes['href'];
      if (href == null) continue;
      // Resolve relative path
      final resolvedPath = p
          .normalize(p.join(chapterDir, href))
          .replaceAll('\\', '/');
      final lookupPath = resolvedPath.startsWith('/')
          ? resolvedPath.substring(1)
          : resolvedPath;
      final cssFilePath = allCssFiles[lookupPath];
      if (cssFilePath != null && File(cssFilePath).existsSync()) {
        final cssContent = File(cssFilePath).readAsStringSync();
        print(
          'DEBUG: CSS content for "$href" in chapter "${chapter.title}":\n$cssContent\n',
        );
      } else {
        print('DEBUG: CSS file not found for "$href" (resolved: $lookupPath)');
      }
    }
  }

  @override
  void deactivate() {
    // Force a final save with the current position when leaving the screen
    // We do this in deactivate because ref is still valid here, but not in dispose
    if (_readingController != null && !_isLoading) {
      _saveProgress(
        bookIndex: widget.bookId,
        chapterIndex: _currentChapterIndex,
        scrollOffset: _currentScrollOffset,
      );
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _hideOverlayTimer?.cancel();
    // First, cancel any pending debounced saves
    _saveDebounceTimer?.cancel();

    // Then dispose of controllers
    _scrollController.dispose();
    _pageController.dispose();

    // Reset system UI
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    super.dispose();
  }

  Future<void> _paginateChapter() async {
    if (_epubData == null) return;

    setState(() {
      _isPaginating = true;
    });

    final chapter = _epubData!.chapters[_currentChapterIndex];
    final prefs = ref.read(readingPreferencesProvider);
    final isar = await ref.read(isarInstanceProvider.future);
    final paginator = EpubPaginatorService(isar);

    // Calculate available size
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final padding = _getReadingPadding(mediaQuery);

    // Base style
    final baseStyle = prefs.baseTextStyle.copyWith(
      fontSize: prefs.fontSize,
      fontFamily: prefs.fontFamily,
      height: prefs.lineHeight,
      color: prefs.textColor,
    );

    // Tag styles
    final tagStyles = <String, TextStyle>{};
    for (int i = 1; i <= 6; i++) {
      final headingStyle = prefs.getStyleForHeading(i);
      tagStyles['h$i'] = baseStyle.copyWith(
        fontSize: headingStyle.fontSize ?? prefs.fontSize,
        fontWeight: headingStyle.fontWeight,
        // Add other properties if needed
      );
    }
    // Add other tags if needed (p, div, etc.)
    // Note: flutter_html styles are 'Style', we need 'TextStyle'.
    // We are manually constructing basic tag styles here.

    final pages = await paginator.paginateChapter(
      bookId: widget.bookId,
      chapterHref: chapter.href,
      htmlContent: chapter.content,
      baseStyle: baseStyle,
      tagStyles: tagStyles,
      pageSize: screenSize,
      padding: padding,
    );

    if (mounted) {
      ref
          .read(paginationControllerProvider.notifier)
          .updateTotalPages(pages.length);
      setState(() {
        _paginatedPages = pages;
        _isPaginating = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Trigger pagination when dependencies (media query) change
    _paginateChapter();
  }
}
