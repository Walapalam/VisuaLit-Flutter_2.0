import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/custom_reader/application/epub_paginator_service.dart';

class PaginatedReadingView extends ConsumerStatefulWidget {
  final List<PageContent> pages;
  final int initialPageIndex;
  final ValueChanged<int> onPageChanged;
  final VoidCallback? onNextChapter;
  final VoidCallback? onPreviousChapter;

  const PaginatedReadingView({
    super.key,
    required this.pages,
    required this.initialPageIndex,
    required this.onPageChanged,
    this.onNextChapter,
    this.onPreviousChapter,
  });

  @override
  ConsumerState<PaginatedReadingView> createState() =>
      _PaginatedReadingViewState();
}

class _PaginatedReadingViewState extends ConsumerState<PaginatedReadingView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPageIndex);
  }

  @override
  void didUpdateWidget(PaginatedReadingView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPageIndex != widget.initialPageIndex) {
      if (_pageController.hasClients &&
          _pageController.page?.round() != widget.initialPageIndex) {
        _pageController.jumpToPage(widget.initialPageIndex);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerMove: (details) {
        if (details.delta.dx > 10) {
          // Swipe Right (Previous)
          if (_pageController.page == 0) {
            widget.onPreviousChapter?.call();
          }
        } else if (details.delta.dx < -10) {
          // Swipe Left (Next)
          if (_pageController.page == widget.pages.length - 1) {
            widget.onNextChapter?.call();
          }
        }
      },
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.pages.length,
        onPageChanged: widget.onPageChanged,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final page = widget.pages[index];
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 24.0,
            ),
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: page.blocks.map((block) {
                  if (block is TextBlock) {
                    return Container(
                      color: Colors.red.withOpacity(
                        0.1,
                      ), // DEBUG: Visualize text block
                      child: Text(block.text, style: block.style),
                    );
                  } else if (block is ImageBlock) {
                    if (block.src.startsWith('http')) {
                      return Image.network(block.src);
                    } else {
                      return Image.file(File(block.src));
                    }
                  }
                  return const SizedBox.shrink();
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
