import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/features/custom_reader/presentation/reading_constants.dart';

class ReadingAppBar extends StatelessWidget {
  final String bookTitle;
  final String chapterTitle;

  const ReadingAppBar({
    Key? key,
    required this.bookTitle,
    required this.chapterTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double titleSize = 18.0;
    final double subtitleSize = 14.0;

    return Container(
      height: kReadingTopBarHeight,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Colors.transparent],
          stops: [0.8, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Centered Title and Subtitle
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48.0,
                ), // Space for buttons
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      bookTitle.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      chapterTitle,
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: subtitleSize,
                        fontWeight: FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            // Back Button (Top Left)
            Positioned(
              top: 0,
              left: 8,
              bottom: 0,
              child: Center(
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () => context.go("/home"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
