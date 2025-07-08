import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/reader/presentation/reading_controller.dart';
import 'package:visualit/features/reader/domain/book_page.dart';
import 'package:visualit/features/reader/data/book_data.dart';

class ReadingScreen extends ConsumerWidget {
  final int bookId;
  const ReadingScreen({super.key, required this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('ReadingScreen: Building screen for bookId: $bookId');

    final viewSize = MediaQuery.of(context).size;
    print('ReadingScreen: ViewSize: $viewSize');

    final state = ref.watch(readingControllerProvider((bookId, viewSize)));
    final controller = ref.read(readingControllerProvider((bookId, viewSize)).notifier);

    print('ReadingScreen: Controller state - paginator: ${state.paginator}, currentPage: ${state.currentPage}');
    print('ReadingScreen: Page cache size: ${state.pageCache.length}');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E5), // A parchment-like color
      body: SafeArea(
        child: state.paginator.when(
          loading: () {
            print('ReadingScreen: Showing loading indicator');
            return const Center(child: CircularProgressIndicator());
          },
          error: (e, st) {
            print('ReadingScreen: Error state - $e');
            print('ReadingScreen: Stack trace - $st');
            return Center(child: Text("Error: $e"));
          },
          data: (paginator) {
            print('ReadingScreen: Paginator loaded with ${paginator.allBlocks.length} blocks');
            print('ReadingScreen: Building PageView...');

            return PageView.builder(
              onPageChanged: (index) {
                print('ReadingScreen: Page changed to $index');
                controller.onPageChanged(index);
              },
              itemCount: (paginator.allBlocks.length / 10).ceil(), // Estimate page count
              itemBuilder: (context, index) {
                print('ReadingScreen: Building page $index');

                final page = state.pageCache[index];
                if (page == null) {
                  print('ReadingScreen: Page $index not cached, requesting...');
                  Future.microtask(() => controller.getPage(index));
                  return const Center(child: CircularProgressIndicator(color: Colors.black54));
                }

                print('ReadingScreen: Rendering page $index with ${page.blocks.length} blocks');
                return BookPageView(page: page);
              },
            );
          },
        ),
      ),
    );
  }
}

class BookPageView extends StatelessWidget {
  final BookPage page;
  const BookPageView({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    print('BookPageView: Building page ${page.pageIndex} with ${page.blocks.length} blocks');
    print('BookPageView: First block text: ${page.blocks.isNotEmpty ? page.blocks.first.textContent?.substring(0, page.blocks.first.textContent!.length > 50 ? 50 : page.blocks.first.textContent!.length) : 'No blocks'}...');

    return CustomPaint(
      painter: BookPagePainter(
        page: page,
        textStyle: const TextStyle(fontSize: 18, height: 1.6, fontFamily: 'Georgia', color: Colors.black87),
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

  BookPagePainter({
    required this.page,
    required this.textStyle,
    required this.margins,
  });

  @override
  void paint(Canvas canvas, Size size) {
    print('BookPagePainter: Painting page ${page.pageIndex} with ${page.blocks.length} blocks');
    print('BookPagePainter: Canvas size: $size');

    double currentY = margins.top;

    for (int i = 0; i < page.blocks.length; i++) {
      final block = page.blocks[i];
      print('BookPagePainter: Painting block $i - Type: ${block.blockType}, Text length: ${block.textContent?.length ?? 0}');

      final style = _getStyleForBlock(block.blockType);
      final textPainter = TextPainter(
        text: TextSpan(text: block.textContent, style: style),
        textAlign: TextAlign.justify,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: size.width - margins.left - margins.right);

      print('BookPagePainter: Block $i painted at Y: $currentY, height: ${textPainter.height}');
      textPainter.paint(canvas, Offset(margins.left, currentY));
      currentY += textPainter.height + 10; // Add spacing between paragraphs
    }

    print('BookPagePainter: Finished painting page ${page.pageIndex}, final Y: $currentY');
  }

  TextStyle _getStyleForBlock(BlockType type) {
    switch (type) {
      case BlockType.h1:
        return textStyle.copyWith(fontSize: 28, fontWeight: FontWeight.bold);
      case BlockType.h2:
        return textStyle.copyWith(fontSize: 24, fontWeight: FontWeight.bold);
      case BlockType.h3:
        return textStyle.copyWith(fontSize: 22, fontWeight: FontWeight.w600);
      default:
        return textStyle;
    }
  }

  @override
  bool shouldRepaint(covariant BookPagePainter oldDelegate) {
    final shouldRepaint = oldDelegate.page.startingBlockIndex != page.startingBlockIndex ||
        oldDelegate.page.pageIndex != page.pageIndex;
    print('BookPagePainter: shouldRepaint: $shouldRepaint');
    return shouldRepaint;
  }
}