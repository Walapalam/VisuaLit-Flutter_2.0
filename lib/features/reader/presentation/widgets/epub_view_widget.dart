import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:epub_view/epub_view.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/presentation/reading_controller.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';

/// A widget that displays an EPUB book using the epub_view package.
/// This provides an alternative rendering approach to the custom ContentBlock-based rendering.
class EpubViewWidget extends ConsumerStatefulWidget {
  final int bookId;
  final Size viewSize;
  final Function(int page) onPageChanged;

  const EpubViewWidget({
    super.key,
    required this.bookId,
    required this.viewSize,
    required this.onPageChanged,
  });

  @override
  ConsumerState<EpubViewWidget> createState() => _EpubViewWidgetState();
}

class _EpubViewWidgetState extends ConsumerState<EpubViewWidget> {
  late EpubController _epubController;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      debugPrint("[DEBUG] EpubViewWidget: Initializing controller for book ID: ${widget.bookId}");
      
      // Get the book from the reading controller
      final readingState = ref.read(readingControllerProvider(widget.bookId));
      
      if (!readingState.isBookLoaded || readingState.book == null) {
        setState(() {
          _errorMessage = "Book not loaded";
        });
        return;
      }
      
      final book = readingState.book!;
      
      // Check if the EPUB file exists
      final epubFile = File(book.epubFilePath);
      if (!await epubFile.exists()) {
        setState(() {
          _errorMessage = "EPUB file not found: ${book.epubFilePath}";
        });
        return;
      }
      
      // Create the EpubController
      _epubController = EpubController(
        document: EpubDocument.openFile(epubFile),
        // Start at the last read location
        epubCfi: null, // We'll handle this separately
      );
      
      // Set initial location based on lastReadPage
      // We'll need to convert from page number to CFI later
      
      setState(() {
        _isInitialized = true;
      });
      
      debugPrint("[DEBUG] EpubViewWidget: Controller initialized successfully");
    } catch (e) {
      debugPrint("[ERROR] EpubViewWidget: Failed to initialize controller: $e");
      setState(() {
        _errorMessage = "Failed to load EPUB: $e";
      });
    }
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _epubController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get reading preferences
    final prefs = ref.watch(readingPreferencesProvider);
    
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade300, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red.shade300),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // Apply reading preferences to the EpubView
    return EpubView(
      controller: _epubController,
      onChapterChanged: (chapter) {
        debugPrint("[DEBUG] EpubViewWidget: Chapter changed: ${chapter.title}");
      },
      onDocumentLoaded: (document) {
        debugPrint("[DEBUG] EpubViewWidget: Document loaded with ${document.chapters.length} chapters");
        
        // Jump to the last read page if possible
        _jumpToLastReadLocation();
      },
      onPageChanged: (page) {
        debugPrint("[DEBUG] EpubViewWidget: Page changed to $page");
        widget.onPageChanged(page);
      },
      builders: EpubViewBuilders(
        options: EpubViewOptions(
          padding: const EdgeInsets.all(16.0),
          enableSwipe: true,
          scrollDirection: Axis.horizontal,
        ),
        chapterDividerBuilder: (_) => const Divider(),
        epubCfiBuilder: (cfi) => Container(),
        
        // Apply custom styling based on reading preferences
        style: EpubViewStyle(
          backgroundColor: prefs.pageColor,
          textStyle: TextStyle(
            fontFamily: prefs.fontFamily,
            fontSize: prefs.fontSize,
            height: prefs.lineSpacing,
            color: prefs.textColor,
          ),
          h1: TextStyle(
            fontFamily: prefs.fontFamily,
            fontSize: prefs.fontSize * 1.8,
            fontWeight: FontWeight.bold,
            color: prefs.textColor,
            height: prefs.lineSpacing,
          ),
          h2: TextStyle(
            fontFamily: prefs.fontFamily,
            fontSize: prefs.fontSize * 1.5,
            fontWeight: FontWeight.bold,
            color: prefs.textColor,
            height: prefs.lineSpacing,
          ),
          h3: TextStyle(
            fontFamily: prefs.fontFamily,
            fontSize: prefs.fontSize * 1.3,
            fontWeight: FontWeight.w700,
            color: prefs.textColor,
            height: prefs.lineSpacing,
          ),
          h4: TextStyle(
            fontFamily: prefs.fontFamily,
            fontSize: prefs.fontSize * 1.15,
            fontWeight: FontWeight.w600,
            color: prefs.textColor,
            height: prefs.lineSpacing,
          ),
          h5: TextStyle(
            fontFamily: prefs.fontFamily,
            fontSize: prefs.fontSize * 1.1,
            fontWeight: FontWeight.w600,
            color: prefs.textColor,
            height: prefs.lineSpacing,
          ),
          h6: TextStyle(
            fontFamily: prefs.fontFamily,
            fontSize: prefs.fontSize,
            fontWeight: FontWeight.w600,
            color: prefs.textColor,
            height: prefs.lineSpacing,
          ),
          a: TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
  
  Future<void> _jumpToLastReadLocation() async {
    try {
      final readingState = ref.read(readingControllerProvider(widget.bookId));
      final lastReadPage = readingState.currentPage;
      
      // For now, we'll just use the page number directly
      // In a more sophisticated implementation, we would convert from page number to CFI
      if (lastReadPage > 0) {
        debugPrint("[DEBUG] EpubViewWidget: Jumping to last read page: $lastReadPage");
        // This is a simplification - actual implementation would need to convert page to CFI
        _epubController.gotoEpubCfi("epubcfi(/6/0!)"); // This is just a placeholder
      }
    } catch (e) {
      debugPrint("[ERROR] EpubViewWidget: Failed to jump to last read location: $e");
    }
  }
}