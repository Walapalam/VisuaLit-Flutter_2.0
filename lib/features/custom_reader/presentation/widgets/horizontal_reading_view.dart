import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/custom_reader/presentation/widgets/chapter_content.dart';

class HorizontalReadingView extends ConsumerStatefulWidget {
  final ChapterContent chapterContent;
  final int totalPages;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final VoidCallback? onNextChapter;
  final VoidCallback? onPreviousChapter;

  const HorizontalReadingView({
    super.key,
    required this.chapterContent,
    required this.totalPages,
    required this.currentPage,
    required this.onPageChanged,
    this.onNextChapter,
    this.onPreviousChapter,
  });

  @override
  ConsumerState<HorizontalReadingView> createState() =>
      _HorizontalReadingViewState();
}

class _HorizontalReadingViewState extends ConsumerState<HorizontalReadingView> {
  late PageController _pageController;
  DateTime _lastNavigationTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.currentPage - 1);
  }

  @override
  void didUpdateWidget(HorizontalReadingView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPage != widget.currentPage) {
      if (_pageController.hasClients &&
          _pageController.page?.round() != widget.currentPage - 1) {
        _pageController.jumpToPage(widget.currentPage - 1);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _canNavigate() {
    final now = DateTime.now();
    if (now.difference(_lastNavigationTime) <
        const Duration(milliseconds: 500)) {
      return false;
    }
    _lastNavigationTime = now;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerMove: (details) {
        // Detect swipe at edges
        if (details.delta.dx > 10) {
          // Swiping Right (Previous Chapter)
          if (widget.currentPage == 1 && _canNavigate()) {
            widget.onPreviousChapter?.call();
          }
        } else if (details.delta.dx < -10) {
          // Swiping Left (Next Chapter)
          if (widget.currentPage == widget.totalPages && _canNavigate()) {
            widget.onNextChapter?.call();
          }
        }
      },
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.totalPages,
        onPageChanged: (index) => widget.onPageChanged(index + 1),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final viewportHeight = constraints.maxHeight;
              final offset = index * viewportHeight;

              return ClipRect(
                child: OverflowBox(
                  alignment: Alignment.topLeft,
                  minHeight: 0,
                  maxHeight: double.infinity,
                  child: Transform.translate(
                    offset: Offset(0, -offset),
                    child: RepaintBoundary(child: widget.chapterContent),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
