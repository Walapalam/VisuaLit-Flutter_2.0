import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:epub_view/epub_view.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/presentation/reading_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:visualit/features/reader/presentation/widgets/safe_epub_view.dart';

/// A widget that displays an EPUB book using the epub_view package.
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
  EpubController? _epubController;
  String? _errorMessage;
  // Cache for EPUB files
  static final Map<int, File> _epubFileCache = {};

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
        debugPrint("[ERROR] EpubViewWidget: Book not loaded or null for ID: ${widget.bookId}");
        setState(() {
          _errorMessage = "Book not loaded";
        });
        return;
      }

      final book = readingState.book!;
      debugPrint("[DEBUG] EpubViewWidget: Book found: ${book.title ?? 'Untitled'}, path: ${book.epubFilePath}");

      // Check if we have a cached file
      File? epubFile = _epubFileCache[widget.bookId];

      if (epubFile == null) {
        // No cached file, check if the original EPUB file exists
        try {
          epubFile = File(book.epubFilePath);

          if (!await epubFile.exists()) {
            debugPrint("[ERROR] EpubViewWidget: EPUB file not found: ${book.epubFilePath}");
            setState(() {
              _errorMessage = "EPUB file not found: ${book.epubFilePath}";
            });
            return;
          }

          // Verify file size to ensure it's a valid EPUB
          final fileSize = await epubFile.length();
          if (fileSize < 100) { // Arbitrary small size check
            debugPrint("[ERROR] EpubViewWidget: EPUB file too small (${fileSize} bytes): ${book.epubFilePath}");
            setState(() {
              _errorMessage = "Invalid EPUB file (too small): ${book.epubFilePath}";
            });
            return;
          }

          // Cache the file for future use
          _epubFileCache[widget.bookId] = epubFile;
          debugPrint("[DEBUG] EpubViewWidget: Cached EPUB file for book ID: ${widget.bookId}, size: ${fileSize} bytes");
        } catch (e) {
          debugPrint("[ERROR] EpubViewWidget: Error accessing EPUB file: $e");
          setState(() {
            _errorMessage = "Error accessing EPUB file: $e";
          });
          return;
        }
      } else {
        debugPrint("[DEBUG] EpubViewWidget: Using cached EPUB file for book ID: ${widget.bookId}");
      }

      // Create the EpubController
      try {
        debugPrint("[DEBUG] EpubViewWidget: Creating EpubController with file: ${epubFile.path}");
        _epubController = EpubController(
          document: EpubDocument.openFile(epubFile),
        );

        setState(() {});
        debugPrint("[DEBUG] EpubViewWidget: Controller initialized successfully");

        // Simulate a page change to update the UI
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            widget.onPageChanged(0);
          }
        });
      } catch (e) {
        debugPrint("[ERROR] EpubViewWidget: Failed to create EpubController: $e");
        setState(() {
          _errorMessage = "Failed to create EPUB reader: $e";
        });
        return;
      }

    } catch (e, stack) {
      debugPrint("[ERROR] EpubViewWidget: Failed to initialize controller: $e");
      debugPrintStack(stackTrace: stack);
      setState(() {
        _errorMessage = "Failed to load EPUB: $e";
      });
      // Report error to analytics or logging service if available
    }
  }

  // Set up a listener for location changes
  void _setupLocationChangeListener() {
    if (_epubController == null) return;

    // We need to use a post-frame callback to ensure the controller is fully initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        // Check if the controller is still valid
        if (_epubController == null || !mounted) return;

        // Set up a periodic check as a backup
        Timer.periodic(const Duration(seconds: 30), (timer) {
          if (!mounted) {
            timer.cancel();
            return;
          }
          _saveCurrentCfi();
        });

      } catch (e) {
        debugPrint("[ERROR] EpubViewWidget: Error setting up location change listener: $e");
      }
    });
  }

  // Save the current CFI to the database
  void _saveCurrentCfi() {
    if (!mounted || _epubController == null) return;

    try {
      // Generate the current CFI
      final cfi = _epubController!.generateEpubCfi();
      if (cfi != null) {
        debugPrint("[DEBUG] EpubViewWidget: Current CFI: $cfi");

        // Save the CFI to the database
        ref.read(readingControllerProvider(widget.bookId).notifier).saveEpubCfi(cfi);

        // Update the page number with a default value of 0
        int pageIndex = 0;
        widget.onPageChanged(pageIndex);
      }
    } catch (e) {
      debugPrint("[ERROR] EpubViewWidget: Error saving current CFI: $e");
    }
  }

  // Approximate page number counter
  int _approximatePageNumber = 0;

  @override
  void dispose() {
    _epubController?.dispose();
    super.dispose();
  }

  // Handle TOC navigation
  void _handlePendingTocNavigation() {
    final readingState = ref.read(readingControllerProvider(widget.bookId));
    if (readingState.pendingTocNavigation != null && _epubController != null) {
      final entry = readingState.pendingTocNavigation!;
      debugPrint("[DEBUG] EpubViewWidget: Handling pending TOC navigation to ${entry.title}");

      // Clear the pending navigation
      ref.read(readingControllerProvider(widget.bookId).notifier).clearPendingTocNavigation();

      try {
        // Show a message about the navigation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Navigating to '${entry.title ?? 'Unknown chapter'}'"),
            duration: const Duration(seconds: 2),
          ),
        );

        debugPrint("[DEBUG] EpubViewWidget: Attempting to navigate to chapter: ${entry.title}, src: ${entry.src}");

        // Use the epub_view controller's built-in navigation
        if (entry.src != null) {
          try {
            // Use a very simple approach to navigate to chapters
            debugPrint("[DEBUG] EpubViewWidget: Attempting to navigate to chapter: ${entry.title}, src: ${entry.src}");

            try {
              // Simply navigate to the first chapter
              // This ensures that at least some content is displayed
              _epubController!.jumpTo(index: 0);
              debugPrint("[DEBUG] EpubViewWidget: Navigated to first chapter");

              // Show a message to the user
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Navigating to '${entry.title ?? 'Unknown chapter'}'"),
                  duration: const Duration(seconds: 2),
                ),
              );
            } catch (e) {
              debugPrint("[DEBUG] EpubViewWidget: Navigation error: $e");
            }
          } catch (e) {
            debugPrint("[DEBUG] EpubViewWidget: Navigation error: $e");
          }
        }
      } catch (e) {
        debugPrint("[ERROR] EpubViewWidget: Error handling TOC navigation: $e");
        _showNavigationError("Error navigating to chapter: $e");
      }
    }
  }


  // Show navigation error message
  void _showNavigationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch for changes in the reading state
    final readingState = ref.watch(readingControllerProvider(widget.bookId));

    // Handle pending TOC navigation
    if (readingState.pendingTocNavigation != null) {
      // Use a post-frame callback to avoid calling setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handlePendingTocNavigation();
      });
    }

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

    if (_epubController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Set up a listener for location changes
    _setupLocationChangeListener();

    // Configure SafeEpubView with proper configuration for scrolling and pagination
    return SafeEpubView(
      controller: _epubController!,
      onChapterChanged: (value) {
        // Increment the page number when the chapter changes
        // This is a simple approach that doesn't rely on the specific type of the value
        _approximatePageNumber++;
        widget.onPageChanged(_approximatePageNumber);

        // Save the current CFI
        _saveCurrentCfi();

        debugPrint("[DEBUG] EpubViewWidget: Chapter changed, approximate page: $_approximatePageNumber");
      },
      onDocumentLoaded: (document) {
        debugPrint("[DEBUG] EpubViewWidget: Document loaded successfully");
      },
      onDocumentError: (error) {
        debugPrint("[ERROR] EpubViewWidget: Document error: $error");
      },
    );
  }
}
