import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/domain/book_page.dart';
import 'package:visualit/features/reader/presentation/reading_controller.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';
import 'package:visualit/features/reader/presentation/widgets/line_guide_painter.dart';
import 'package:visualit/features/reader/presentation/widgets/reading_settings_panel.dart';
import 'package:visualit/features/reader/presentation/widgets/toc_panel.dart';

class ReadingScreen extends ConsumerStatefulWidget {
  final int bookId;

  const ReadingScreen({super.key, required this.bookId});

  @override
  ConsumerState<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends ConsumerState<ReadingScreen> {
  bool _isUiVisible = false;
  late final PageController _pageController;
  double _lineGuideY = 150.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _pageController = PageController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final viewSize = MediaQuery.of(context).size;
    final initialPage = ref.read(readingControllerProvider((widget.bookId, viewSize))).currentPage;

    if (!_pageController.hasClients || _pageController.page?.round() != initialPage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(initialPage);
        }
      });
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pageController.dispose();
    super.dispose();
  }

  void _toggleUiVisibility() {
    setState(() {
      _isUiVisible = !_isUiVisible;
      if (_isUiVisible) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      }
    });
  }

  void _showSettingsPanel(BuildContext context) {
    if (!_isUiVisible) _toggleUiVisibility();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ReadingSettingsPanel(),
    );
  }

  void _showTocPanel(Size viewSize) {
    if (!_isUiVisible) _toggleUiVisibility();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TOCPanel(
        bookId: widget.bookId,
        viewSize: viewSize,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewSize = MediaQuery.of(context).size;
    final provider = readingControllerProvider((widget.bookId, viewSize));

    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final prefs = ref.watch(readingPreferencesProvider);

    print("🔄 [ReadingScreen] Build method called.");
    print("  [ReadingScreen] Current state: isPaginating=${state.isPaginating}, paginator is null=${state.paginator == null}, totalPages=${state.paginator?.totalPages ?? 'N/A'}");


    ref.listen(provider.select((s) => s.currentPage), (previous, next) {
      if (_pageController.hasClients && _pageController.page?.round() != next) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients) {
            _pageController.jumpToPage(next);
          }
        });
      }
    });

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: prefs.pageColor,
        body: Stack(
          children: [
            if (state.isPaginating || state.paginator == null)
              Builder(builder: (context) {
                print("  [ReadingScreen] UI: Building 'Preparing book...' indicator.");
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text('Preparing book...', style: TextStyle(color: prefs.textColor)),
                    ],
                  ),
                );
              })
            else if (state.paginator!.totalPages == 0)
              Builder(builder: (context) {
                print("  [ReadingScreen] UI: Building 'Failed to Load' error message.");
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: prefs.textColor, size: 60),
                        const SizedBox(height: 20),
                        Text(
                          'Failed to Load Book',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: prefs.textColor, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'The content could not be processed. The EPUB file might be empty, corrupted, or in an unsupported format.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: prefs.textColor.withOpacity(0.8), fontSize: 16),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: AppTheme.black,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Back to Library'),
                        ),
                      ],
                    ),
                  ),
                );
              })
            else
              Builder(builder: (context) {
                print("  [ReadingScreen] UI: Building PageView with ${state.paginator!.totalPages} pages.");
                return PageView.builder(
                  controller: _pageController,
                  onPageChanged: controller.onPageChanged,
                  itemCount: state.paginator!.totalPages,
                  itemBuilder: (context, index) {
                    final page = state.paginator!.getPage(index);
                    if (page == null) {
                      print("    [ReadingScreen] PageView trying to build page $index, but it's NULL.");
                    }
                    return page == null
                        ? Center(child: Text("Error loading page $index", style: TextStyle(color: prefs.textColor)))
                        : BookPageView(page: page, preferences: prefs);
                  },
                );
              }),

            _buildGestureDetector(),

            if (prefs.isLineGuideEnabled)
              GestureDetector(
                onVerticalDragUpdate: (details) => setState(() => _lineGuideY = details.globalPosition.dy),
                child: CustomPaint(
                  painter: LineGuidePainter(lineGuideY: _lineGuideY, preferences: prefs),
                  size: Size.infinite,
                ),
              ),

            if (!state.isPaginating && state.paginator != null) ...[
              _buildTopOverlay(prefs, state, viewSize),
              _buildBottomOverlay(prefs, state),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildGestureDetector() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: () {
              if (_isUiVisible) {
                _toggleUiVisibility();
              } else {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                );
              }
            },
          ),
        ),
        Expanded(
          flex: 2,
          child: GestureDetector(onTap: _toggleUiVisibility),
        ),
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: () {
              if (_isUiVisible) {
                _toggleUiVisibility();
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopOverlay(ReadingPreferences prefs, ReadingState state, Size viewSize) {
    return AnimatedOpacity(
      opacity: _isUiVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: IgnorePointer(
        ignoring: !_isUiVisible,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                prefs.pageColor.withOpacity(0.9),
                prefs.pageColor.withOpacity(0),
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: prefs.textColor),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                state.paginator?.allBlocks.first.textContent ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: prefs.textColor, fontSize: 16),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.menu_book, color: prefs.textColor),
                  onPressed: () => _showTocPanel(viewSize),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomOverlay(ReadingPreferences prefs, ReadingState state) {
    final paginator = state.paginator;
    final totalPages = paginator?.totalPages ?? 1;
    final currentPage = state.currentPage;

    return AnimatedOpacity(
      opacity: _isUiVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: IgnorePointer(
        ignoring: !_isUiVisible,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  prefs.pageColor.withOpacity(0.9),
                  prefs.pageColor.withOpacity(0),
                ],
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: currentPage.toDouble().clamp(0, (totalPages > 0 ? totalPages - 1 : 0).toDouble()),
                      min: 0,
                      max: (totalPages > 0 ? totalPages - 1 : 0).toDouble(),
                      onChanged: (value) => _pageController.jumpToPage(value.round()),
                      activeColor: prefs.textColor,
                      inactiveColor: prefs.textColor.withOpacity(0.3),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      '${currentPage + 1} / $totalPages',
                      style: TextStyle(color: prefs.textColor),
                    ),
                  ),
                  IconButton(
                    icon: const Text('Aa', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    color: prefs.textColor,
                    onPressed: () => _showSettingsPanel(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class BookPageView extends StatelessWidget {
  final BookPage page;
  final ReadingPreferences preferences;

  const BookPageView({super.key, required this.page, required this.preferences});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: preferences.fontSize,
      height: preferences.lineSpacing,
      fontFamily: preferences.fontFamily,
      color: preferences.textColor,
    );

    return CustomPaint(
      painter: BookPagePainter(
        page: page,
        textStyle: textStyle,
        preferences: preferences,
        margins: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      ),
      size: Size.infinite,
    );
  }
}

class BookPagePainter extends CustomPainter {
  final BookPage page;
  final TextStyle textStyle;
  final EdgeInsets margins;
  final ReadingPreferences preferences;

  const BookPagePainter({
    required this.page,
    required this.textStyle,
    required this.margins,
    required this.preferences,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double currentY = margins.top;

    for (final block in page.blocks) {
      final style = _getStyleForBlock(block.blockType);
      final textPainter = TextPainter(
        text: TextSpan(text: block.textContent, style: style),
        textAlign: TextAlign.justify,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: size.width - margins.left - margins.right);
      textPainter.paint(canvas, Offset(margins.left, currentY));

      currentY += textPainter.height + (block.blockType != BlockType.p ? 16 : 4);
    }
  }

  TextStyle _getStyleForBlock(BlockType type) {
    switch (type) {
      case BlockType.h1:
        return textStyle.copyWith(
          fontSize: textStyle.fontSize! * 1.6,
          fontWeight: FontWeight.bold,
        );
      case BlockType.h2:
        return textStyle.copyWith(
          fontSize: textStyle.fontSize! * 1.4,
          fontWeight: FontWeight.bold,
        );
      case BlockType.h3:
        return textStyle.copyWith(
          fontSize: textStyle.fontSize! * 1.2,
          fontWeight: FontWeight.w700,
        );
      default:
        return textStyle;
    }
  }

  @override
  bool shouldRepaint(covariant BookPagePainter oldDelegate) {
    return oldDelegate.page.startingBlockIndex != page.startingBlockIndex ||
        oldDelegate.page.pageIndex != page.pageIndex ||
        oldDelegate.preferences != preferences;
  }
}