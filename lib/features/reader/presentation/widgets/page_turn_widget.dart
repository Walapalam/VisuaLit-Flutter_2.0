import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/models/content_block_schema.dart';
import 'package:visualit/core/providers/font_providers.dart';
import 'package:visualit/features/reader/presentation/reading_controller.dart';
import 'package:visualit/features/reader/presentation/widgets/book_page_widget.dart';

/// A widget that displays book pages with page turning functionality.
class PageTurnWidget extends ConsumerStatefulWidget {
  /// The book ID.
  final int bookId;
  
  /// Constructor
  const PageTurnWidget({
    Key? key,
    required this.bookId,
  }) : super(key: key);
  
  @override
  ConsumerState<PageTurnWidget> createState() => _PageTurnWidgetState();
}

class _PageTurnWidgetState extends ConsumerState<PageTurnWidget> {
  /// The page controller for handling page turns.
  late PageController _pageController;
  
  /// The current page index.
  int _currentPageIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPageIndex);
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Watch the reading controller state
    final readingState = ref.watch(readingControllerProvider(widget.bookId));
    
    // Get the reading controller
    final readingController = ref.read(readingControllerProvider(widget.bookId).notifier);
    
    // Get the font settings
    final fontSettings = ref.watch(fontSettingsProvider);
    
    // Show loading indicator if the controller is in loading or formatting state
    if (readingState == ReadingState.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    // Show formatting indicator if the controller is in formatting state
    if (readingState == ReadingState.formatting) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Formatting book...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    
    // Show error message if the controller is in error state
    if (readingState == ReadingState.error) {
      return const Center(
        child: Text(
          'Error loading book',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      );
    }
    
    // Get the current page blocks
    final currentPageBlocks = readingController.getCurrentPageBlocks();
    
    // Get the total number of pages
    final totalPages = readingController.getTotalPages();
    
    return Column(
      children: [
        // Page turn area
        Expanded(
          child: GestureDetector(
            onTapUp: (details) {
              // Determine if the tap was on the left or right side of the screen
              final screenWidth = MediaQuery.of(context).size.width;
              final tapPosition = details.globalPosition.dx;
              
              if (tapPosition < screenWidth / 2) {
                // Tap on left side - go to previous page
                if (readingController.goToPreviousPage()) {
                  setState(() {
                    _currentPageIndex = readingController.getCurrentPageIndex();
                  });
                }
              } else {
                // Tap on right side - go to next page
                if (readingController.goToNextPage()) {
                  setState(() {
                    _currentPageIndex = readingController.getCurrentPageIndex();
                  });
                }
              }
            },
            child: BookPageWidget(
              blocks: currentPageBlocks,
              fontSettings: fontSettings,
            ),
          ),
        ),
        
        // Page indicator
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Page ${_currentPageIndex + 1} of $totalPages',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}