// dart
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/epub_parser_service.dart';
import 'package:isar/isar.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as p;


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
  final PageController _pageController = PageController();

  EpubMetadata? _epubData;
  String? _epubPath;
  int _currentChapterIndex = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBookAndEpub();
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
      appBar: AppBar(
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
      ),
      body: PageView.builder(
          controller: _pageController,
          itemCount: _epubData?.chapters.length ?? 0,
          onPageChanged: (index) {
            setState(() {
              _currentChapterIndex = index;
            });
          },
          itemBuilder: (context, index) {
            final chapter = _epubData!.chapters[index];

            // Preprocess the HTML to rewrite image sources
            final processedContent = chapter.content;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Html(
                    data: processedContent, // Use processed content with local file URIs
                    style: {
                      "body": Style(
                        fontSize: FontSize(16),
                        lineHeight: const LineHeight(1.6),
                      ),
                    },
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
                    ],
                  ),
                ],
              ),
            );
          }
      ),
      bottomNavigationBar: SafeArea(
        child: _buildNavigationBar(),
      ),
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _currentChapterIndex > 0 ? _previousChapter : null,
          ),
          Text(
            'Chapter ${_currentChapterIndex + 1} of ${_epubData?.chapters.length ?? 0}',
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
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
    if (_currentChapterIndex < (_epubData?.chapters.length ?? 0) - 1) {
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

