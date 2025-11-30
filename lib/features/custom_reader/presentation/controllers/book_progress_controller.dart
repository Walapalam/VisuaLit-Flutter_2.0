import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/custom_reader/application/epub_parser_service.dart';

class BookProgressState {
  final int totalBookPages;
  final int currentBookPage;
  final bool isCalculating;

  BookProgressState({
    this.totalBookPages = 0,
    this.currentBookPage = 0,
    this.isCalculating = false,
  });

  BookProgressState copyWith({
    int? totalBookPages,
    int? currentBookPage,
    bool? isCalculating,
  }) {
    return BookProgressState(
      totalBookPages: totalBookPages ?? this.totalBookPages,
      currentBookPage: currentBookPage ?? this.currentBookPage,
      isCalculating: isCalculating ?? this.isCalculating,
    );
  }
}

class BookProgressController extends StateNotifier<BookProgressState> {
  BookProgressController() : super(BookProgressState());

  int _totalBookChars = 0;
  final Map<int, int> _chapterCharCounts = {};

  Future<void> analyzeBook(EpubMetadata epubData) async {
    state = state.copyWith(isCalculating: true);

    // Run in microtask to avoid blocking UI
    await Future.microtask(() {
      _totalBookChars = 0;
      _chapterCharCounts.clear();

      for (int i = 0; i < epubData.chapters.length; i++) {
        final charCount = epubData.chapters[i].content.length;
        _chapterCharCounts[i] = charCount;
        _totalBookChars += charCount;
      }
    });

    state = state.copyWith(isCalculating: false);
  }

  void updateProgress({
    required int currentChapterIndex,
    required int currentChapterPage,
    required int totalChapterPages,
  }) {
    if (_totalBookChars == 0 || totalChapterPages == 0) return;

    // Calculate chars per page for the current chapter
    final currentChapterChars = _chapterCharCounts[currentChapterIndex] ?? 0;
    final charsPerPage = (currentChapterChars / totalChapterPages).ceil();

    if (charsPerPage == 0) return;

    // Estimate total book pages
    final estimatedTotalPages = (_totalBookChars / charsPerPage).ceil();

    // Calculate pages before current chapter
    int charsBefore = 0;
    for (int i = 0; i < currentChapterIndex; i++) {
      charsBefore += _chapterCharCounts[i] ?? 0;
    }
    final pagesBefore = (charsBefore / charsPerPage).ceil();

    // Calculate current global page
    final currentGlobalPage = pagesBefore + currentChapterPage;

    state = state.copyWith(
      totalBookPages: estimatedTotalPages,
      currentBookPage: currentGlobalPage,
    );
  }
}

final bookProgressControllerProvider =
    StateNotifierProvider<BookProgressController, BookProgressState>((ref) {
      return BookProgressController();
    });
