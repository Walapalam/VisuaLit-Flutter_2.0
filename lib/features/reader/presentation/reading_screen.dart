import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:visualit/core/models/book.dart';
import 'package:visualit/core/services/epub_service.dart';
import 'package:visualit/core/theme/app_theme.dart';

// TODO: Move the system chrome changing to the app level, either home or somewhere

class ReadingScreen extends StatefulWidget {
  final Book book;

  const ReadingScreen({
    super.key,
    required this.book,
  });

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class TextHighlight {
  final String id;
  final String text;
  final Color color;
  final int chapterIndex;
  final DateTime createdAt;
  final String? note;

  TextHighlight({
    required this.id,
    required this.text,
    required this.color,
    required this.chapterIndex,
    required this.createdAt,
    this.note,
  });
}

class _ReadingScreenState extends State<ReadingScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final EpubService _epubService = EpubService();
  Timer? _saveProgressTimer;
  Timer? _autoHideTimer;
  late AnimationController _barAnimationController;
  bool _showBars = true;
  int _currentChapterIndex = 0;
  late PageController _pageController;
  double _textSize = 16.0;
  TextAlign _textAlign = TextAlign.left;
  String _font = 'Default';

  final List<TextHighlight> _highlights = [];
  String? _selectedText;
  TextHighlight? _activeHighlight;

  // Predefined highlight colors
  final List<Color> _highlightColors = [
    Colors.yellow.withOpacity(0.3),
    Colors.green.withOpacity(0.3),
    Colors.blue.withOpacity(0.3),
    Colors.pink.withOpacity(0.3),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentChapterIndex);
    _scrollController.addListener(_onScroll);
    _barAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    if (_showBars) {
      _barAnimationController.value = 1.0;
    }
    _startAutoHideTimer();

    // Show system bars initially
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    // Restore system bars when leaving the screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _saveProgressTimer?.cancel();
    _autoHideTimer?.cancel();
    _barAnimationController.dispose();
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoHideTimer() {
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _hideBars();
      }
    });
  }

  void _toggleBars() {
    setState(() {
      _showBars = !_showBars;
      if (_showBars) {
        _barAnimationController.forward();
        _startAutoHideTimer();
        // Show system bars
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      } else {
        _barAnimationController.reverse();
        _autoHideTimer?.cancel();
        // Hide system bars
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      }
    });
  }

  void _hideBars() {
    if (mounted && _showBars) {
      setState(() {
        _showBars = false;
        _barAnimationController.reverse();
        // Hide system bars
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      });
    }
  }

  void _showBarsUI() {
    if (mounted && !_showBars) {
      setState(() {
        _showBars = true;
        _barAnimationController.forward();
        _startAutoHideTimer();
        // Show system bars
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      });
    }
  }

  void _onScroll() {
    _saveProgressTimer?.cancel();
    _saveProgressTimer = Timer(const Duration(seconds: 1), _saveProgress);

    if (_showBars) {
      _hideBars();
    }
  }

  Future<void> _saveProgress() async {
    if (!_scrollController.hasClients) return;
    // TODO: Implement progress saving logic
  }

  void _buildContentsDrawer() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkGrey,
      builder: (context) {
        return ListView(
          children: [
            Center(
              child: ListTile(
                title: Text(
                  'Chapter ${_currentChapterIndex + 1} of ${widget.book.chapters.length}',
                  style: const TextStyle(color: AppTheme.white),
                ),
              ),
            ),
            const Divider(color: AppTheme.grey),
            const Center(
              child: ListTile(
                title: Text(
                  'Contents',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ...List.generate(widget.book.chapters.length, (index) {
              return ListTile(
                title: Text(
                  widget.book.chapters[index].title,
                  style: const TextStyle(color: AppTheme.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _currentChapterIndex = index;
                    _pageController.jumpToPage(index);
                    _scrollController.jumpTo(0);
                  });
                  _saveProgress();
                },
              );
            }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Restore system UI before popping
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        return true;
      },
      child: Theme(
        data: Theme.of(context).copyWith(
          scaffoldBackgroundColor: Colors.transparent,
          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: Colors.transparent,
            modalBackgroundColor: Colors.transparent,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: false,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Background
              Container(color: AppTheme.darkGrey),

              // Reading content
              PageView.builder(
                controller: _pageController,
                itemCount: widget.book.chapters.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentChapterIndex = index;
                    _scrollController.jumpTo(0);
                  });
                  _saveProgress();
                },
                itemBuilder: (context, index) {
                  final chapter = widget.book.chapters[index];
                  return GestureDetector(
                    onTap: () {
                      if (_showBars) {
                        _hideBars();
                      } else {
                        _showBarsUI();
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: kToolbarHeight + MediaQuery.of(context).padding.top,
                          bottom: kBottomNavigationBarHeight + 16,
                          left: 16,
                          right: 16,
                        ),
                        child: Stack(
                          children: [
                            SelectableHtml(
                              data: chapter.content,
                              style: {
                                'p': Style(
                                  fontSize: FontSize(_textSize),
                                  textAlign: _textAlign,
                                  fontFamily: _font,
                                  color: Colors.white,
                                  padding: const HtmlPaddings.zero(),
                                  margin: const HtmlMargin.zero(),
                                ),
                                'body': Style(
                                  padding: const HtmlPaddings.zero(),
                                  margin: const HtmlMargin.zero(),
                                  color: Colors.white,
                                ),
                              },
                              onSelectionChanged: (selection) {
                                setState(() {
                                  _selectedText = selection?.text;
                                  if (_selectedText != null && _selectedText!.isNotEmpty) {
                                    _showHighlightOptions();
                                  }
                                });
                              },
                            ),
                            // Layer for highlights
                            ...(_highlights
                              .where((h) => h.chapterIndex == _currentChapterIndex)
                              .map((highlight) => Positioned(
                                left: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => _showHighlightOptions(highlight: highlight),
                                  child: SelectableText(
                                    highlight.text,
                                    style: TextStyle(
                                      backgroundColor: highlight.color,
                                      color: Colors.transparent,
                                    ),
                                  ),
                                ),
                              ))),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Top app bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -1),
                    end: Offset.zero,
                  ).animate(_barAnimationController),
                  child: Container(
                    color: AppTheme.darkGrey.withOpacity(0.9),
                    child: AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      title: Text(widget.book.title),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.bookmark),
                          onPressed: _showAllHighlights,
                        ),
                        IconButton(
                          icon: const Icon(Icons.format_size),
                          onPressed: () {
                            // TODO: Implement font settings
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(_barAnimationController),
                  child: Container(
                    color: AppTheme.darkGrey.withOpacity(0.9),
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Chapter ${_currentChapterIndex + 1}',
                              style: const TextStyle(color: AppTheme.white),
                            ),
                            IconButton(
                              icon: const Icon(Icons.list),
                              color: AppTheme.white,
                              onPressed: _buildContentsDrawer,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: ScaleTransition(
            scale: _barAnimationController,
            child: SpeedDial(
              icon: Icons.more_vert,
              backgroundColor: AppTheme.primaryGreen,
              overlayColor: Colors.transparent,
              overlayOpacity: 0,
              spacing: 12,
              spaceBetweenChildren: 12,
              renderOverlay: false,
              children: [
                SpeedDialChild(
                  child: const Icon(Icons.search),
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: AppTheme.black,
                  label: 'Dictionary',
                  labelStyle: const TextStyle(color: AppTheme.white),
                  labelBackgroundColor: AppTheme.darkGrey,
                  onTap: () {
                    // TODO: Implement dictionary
                  },
                ),
                SpeedDialChild(
                  child: const Icon(Icons.headset),
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: AppTheme.black,
                  label: 'Listen',
                  labelStyle: const TextStyle(color: AppTheme.white),
                  labelBackgroundColor: AppTheme.darkGrey,
                  onTap: () {
                    // TODO: Implement audio
                  },
                ),
              ],
            ),
          ),
        ),
      )
    );
  }

  void _showHighlightOptions({TextHighlight? highlight}) {
    if (_selectedText == null && highlight == null) return;

    setState(() => _activeHighlight = highlight);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkGrey,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (highlight == null) ...[
                const Text(
                  'Highlight Color',
                  style: TextStyle(
                    color: AppTheme.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _highlightColors.map((color) {
                    return GestureDetector(
                      onTap: () => _addHighlight(color),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ] else ...[
                ListTile(
                  leading: const Icon(Icons.edit, color: AppTheme.white),
                  title: const Text('Add Note', style: TextStyle(color: AppTheme.white)),
                  onTap: () => _editHighlightNote(highlight),
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: AppTheme.white),
                  title: const Text('Delete', style: TextStyle(color: AppTheme.white)),
                  onTap: () => _deleteHighlight(highlight),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _addHighlight(Color color) {
    if (_selectedText == null) return;

    setState(() {
      _highlights.add(TextHighlight(
        id: DateTime.now().toString(),
        text: _selectedText!,
        color: color,
        chapterIndex: _currentChapterIndex,
        createdAt: DateTime.now(),
      ));
      _selectedText = null;
    });

    Navigator.pop(context);
  }

  void _editHighlightNote(TextHighlight highlight) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) {
        String note = highlight.note ?? '';
        return AlertDialog(
          backgroundColor: AppTheme.darkGrey,
          title: const Text('Add Note', style: TextStyle(color: AppTheme.white)),
          content: TextField(
            style: const TextStyle(color: AppTheme.white),
            decoration: const InputDecoration(
              hintText: 'Enter your note...',
              hintStyle: TextStyle(color: AppTheme.grey),
            ),
            onChanged: (value) => note = value,
            controller: TextEditingController(text: note),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  final index = _highlights.indexOf(highlight);
                  _highlights[index] = TextHighlight(
                    id: highlight.id,
                    text: highlight.text,
                    color: highlight.color,
                    chapterIndex: highlight.chapterIndex,
                    createdAt: highlight.createdAt,
                    note: note,
                  );
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteHighlight(TextHighlight highlight) {
    setState(() {
      _highlights.removeWhere((h) => h.id == highlight.id);
    });
    Navigator.pop(context);
  }

  void _showAllHighlights() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkGrey,
      builder: (context) {
        return ListView.builder(
          itemCount: _highlights.length,
          itemBuilder: (context, index) {
            final highlight = _highlights[index];
            return ListTile(
              title: Text(
                highlight.text,
                style: const TextStyle(color: AppTheme.white),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: highlight.note != null
                  ? Text(
                      highlight.note!,
                      style: const TextStyle(color: AppTheme.grey),
                    )
                  : null,
              leading: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: highlight.color,
                  shape: BoxShape.circle,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _jumpToHighlight(highlight);
              },
            );
          },
        );
      },
    );
  }

  void _jumpToHighlight(TextHighlight highlight) {
    if (_currentChapterIndex != highlight.chapterIndex) {
      _pageController.jumpToPage(highlight.chapterIndex);
    }
    // TODO: Implement scroll to text position
  }
}

// Add this class at the file level
class ReadingScreenRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute?.settings.name == 'reader') {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name == 'reader') {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }
}
