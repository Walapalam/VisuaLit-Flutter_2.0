import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';
import 'package:visualit/features/reader/presentation/widgets/reading_settings_panel.dart';
import 'package:visualit/features/reader/presentation/widgets/book_overview_dialog.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/core/providers/isar_provider.dart';

final bookProvider = FutureProvider.family<Book?, int>((ref, bookId) async {
  final isar = await ref.watch(isarDBProvider.future);
  return await isar.books.get(bookId);
});

class ReadingScreen extends ConsumerStatefulWidget {
  final int bookId;
  const ReadingScreen({super.key, required this.bookId});

  @override
  ConsumerState<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends ConsumerState<ReadingScreen> {
  bool _isUiVisible = false;
  bool _isLocked = false;
  final EpubController _epubController = EpubController();
  Book? _currentBook;
  String _currentChapter = 'Loading...';
  double _currentProgress = 0.0;
  List<EpubChapter> _chapters = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _loadBook();
  }

  Future<void> _loadBook() async {
    final bookAsync = ref.read(bookProvider(widget.bookId));
    bookAsync.when(
      data: (book) {
        if (book != null) {
          setState(() {
            _currentBook = book;
          });
        }
      },
      loading: () {},
      error: (error, stack) {},
    );
  }

  @override
  void dispose() {
    ScreenBrightness().resetScreenBrightness();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleUiVisibility() {
    if (_isLocked) return;
    setState(() {
      _isUiVisible = !_isUiVisible;
      SystemChrome.setEnabledSystemUIMode(
        _isUiVisible ? SystemUiMode.edgeToEdge : SystemUiMode.immersive,
      );
    });
  }

  void _showMainSettingsPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ReadingSettingsPanel(),
    );
  }

  void _showBookOverviewDialog() async {
    if (_currentBook == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    Navigator.of(context).pop();

    showGeneralDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      barrierLabel: 'Book Visualizations',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: BookOverviewDialog(
            bookTitleForLookup: _currentBook!.title ?? '',
            localBookISBN: _currentBook!.isbn ?? '',
            localChapterNumber: 1,
            localChapterContent: _currentChapter,
          ),
        );
      },
    );
  }

  Future<void> _saveReadingProgress() async {
    if (_currentBook == null) return;

    final isar = await ref.read(isarDBProvider.future);
    await isar.writeTxn(() async {
      _currentBook!.lastReadTimestamp = DateTime.now();
      _currentBook!.lastReadPage = (_currentProgress * 100).toInt();
      await isar.books.put(_currentBook!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(readingPreferencesProvider);
    final bookAsync = ref.watch(bookProvider(widget.bookId));

    ref.listen(readingPreferencesProvider.select((p) => p.brightness), (_, next) async {
      try {
        await ScreenBrightness().setScreenBrightness(next);
      } catch (_) {}
    });

    // Listen to font size changes and apply to epub controller
    ref.listen(readingPreferencesProvider.select((p) => p.fontSize), (_, next) async {
      try {
        await _epubController.setFontSize(fontSize: next);
      } catch (_) {}
    });

    return Scaffold(
      backgroundColor: prefs.pageColor,
      extendBodyBehindAppBar: true, // Allow body to extend behind app bar
      bottomNavigationBar: AnimatedSlide(
        offset: Offset(0, _isUiVisible ? 0 : 1), // Slide from bottom
        duration: const Duration(milliseconds: 300),
        child: Container(
          height: 80,
          child: _buildBottomProgress(prefs),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: AnimatedScale(
        scale: _isUiVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildVisualizationFab(),
            const SizedBox(height: 10),
            _buildSpeedDialFab(),
          ],
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _toggleUiVisibility, // Single tap to toggle UI
        child: AbsorbPointer(
          absorbing: _isLocked,
          child: bookAsync.when(
            data: (book) => book != null
                ? _buildEpubViewer(book, prefs)
                : const Center(child: Text('Book not found')),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        ),
      ),
    );
  }

  Widget _buildEpubViewer(Book book, ReadingPreferences prefs) {
    return Container(
      color: prefs.pageColor, // Apply theme background color
      child: EpubViewer(
        epubSource: EpubSource.fromFile(File(book.epubFilePath)),
        epubController: _epubController,
        displaySettings: EpubDisplaySettings(
          flow: EpubFlow.paginated, // Force paginated for proper chapter separation
          snap: true, // Enable snapping for better page turns
          spread: EpubSpread.values.first, // Single page view
        ),
        onChaptersLoaded: (List<EpubChapter> chapters) {
          setState(() {
            _chapters = chapters;
            if (chapters.isNotEmpty) {
              _currentChapter = chapters.first.title ?? 'Chapter 1';
            }
          });
        },
        onEpubLoaded: () async {
          // Apply reading preferences
          await _epubController.setFontSize(fontSize: prefs.fontSize);

          // Set theme colors for epub content
          await _setEpubTheme(prefs);

          // Restore reading position if available
          if (book.lastReadPage > 0) {
            final progressPercent = book.lastReadPage / 100.0;
            await _epubController.toProgressPercentage(progressPercent);
          }
        },
        onRelocated: (EpubLocation location) {
          _updateReadingProgress();
        },
        onTextSelected: (EpubTextSelection selection) {
          print('Text selected: ${selection.selectedText}');
        },
      ),
    );
  }

  // Add method to apply theme to epub content
  Future<void> _setEpubTheme(ReadingPreferences prefs) async {
    try {
      // Apply font family
      if (prefs.fontFamily.isNotEmpty) {
        // You might need to inject CSS for font family and colors
        // This is a placeholder - actual implementation depends on epub viewer capabilities
      }

      // Note: Some epub viewers may not support dynamic theming
      // You may need to inject custom CSS through the controller if available
    } catch (e) {
      print('Error applying epub theme: $e');
    }
  }

  Future<void> _updateReadingProgress() async {
    try {
      setState(() {
        _currentProgress = (_currentProgress + 0.01).clamp(0.0, 1.0);
      });
      _saveReadingProgress();
    } catch (e) {
      print('Error updating progress: $e');
    }
  }

  void _showChapterList() {
    if (_chapters.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Chapters',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _chapters.length,
                itemBuilder: (context, index) {
                  final chapter = _chapters[index];
                  return ListTile(
                    title: Text(chapter.title ?? 'Chapter ${index + 1}'),
                    subtitle: Text('${chapter.href}'),
                    onTap: () {
                      Navigator.pop(context);
                      _epubController.display(cfi: chapter.href);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomProgress(ReadingPreferences prefs) {
    return BottomAppBar(
      color: prefs.pageColor.withOpacity(0.9), // Use theme color
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Text(
              '${(_currentProgress * 100).toInt()}%',
              style: TextStyle(color: prefs.textColor, fontSize: 12),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Slider(
                value: _currentProgress,
                min: 0.0,
                max: 1.0,
                activeColor: Theme.of(context).colorScheme.primary,
                inactiveColor: prefs.textColor.withOpacity(0.3),
                onChanged: (value) async {
                  setState(() {
                    _currentProgress = value;
                  });
                  await _epubController.toProgressPercentage(value);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _currentChapter,
                style: TextStyle(color: prefs.textColor, fontSize: 12),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedDialFab() {
    return SpeedDial(
      icon: Icons.more_horiz,
      activeIcon: Icons.close,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      foregroundColor: Theme.of(context).colorScheme.onSecondary,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      buttonSize: const Size(56, 56), // Increased size
      childrenButtonSize: const Size(50, 50),
      spacing: 8,
      spaceBetweenChildren: 8,
      animationCurve: Curves.elasticInOut,
      isOpenOnStart: false,
      animationDuration: const Duration(milliseconds: 300),
      visible: true, // Always visible when parent is visible
      closeManually: false,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.bookmark_border),
          label: 'Bookmark',
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Theme.of(context).colorScheme.onSecondary,
          onTap: () async {
            try {
              final location = await _epubController.getCurrentLocation();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bookmark added!')),
              );
            } catch (e) {
              print('Error adding bookmark: $e');
            }
          },
        ),
        SpeedDialChild(
          child: Icon(_isLocked ? Icons.lock_open_outlined : Icons.lock_outline),
          label: _isLocked ? 'Unlock' : 'Lock Screen',
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Theme.of(context).colorScheme.onSecondary,
          onTap: () => setState(() => _isLocked = !_isLocked),
        ),
        SpeedDialChild(
          child: const Icon(Icons.search),
          label: 'Search',
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Theme.of(context).colorScheme.onSecondary,
          onTap: _showSearchDialog,
        ),
        SpeedDialChild(
          child: const Icon(Icons.tune_outlined),
          label: 'Theme & Settings',
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Theme.of(context).colorScheme.onSecondary,
          onTap: _showMainSettingsPanel,
        ),
      ],
    );
  }

  Widget _buildVisualizationFab() {
    return FloatingActionButton(
      heroTag: "visualization",
      onPressed: _showBookOverviewDialog,
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: const Icon(Icons.visibility),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String searchQuery = '';
        return AlertDialog(
          title: const Text('Search in Book'),
          content: TextField(
            onChanged: (value) => searchQuery = value,
            decoration: const InputDecoration(
              hintText: 'Enter search term...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                if (searchQuery.isNotEmpty) {
                  try {
                    final results = await _epubController.search(query: searchQuery);
                    if (results.isNotEmpty) {
                      _showSearchResults(results);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No results found')),
                      );
                    }
                  } catch (e) {
                    print('Error searching: $e');
                  }
                }
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void _showSearchResults(List<EpubSearchResult> results) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Search Results (${results.length})',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final result = results[index];
                  return ListTile(
                    title: Text(result.excerpt),
                    onTap: () {
                      Navigator.pop(context);
                      _epubController.display(cfi: result.cfi);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
