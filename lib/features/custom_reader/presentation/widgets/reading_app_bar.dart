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
          stops: [0.0, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
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
              ),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  chapterTitle,
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: subtitleSize,
                    fontWeight: FontWeight.normal,
                  ),
                  maxLines: 1, // Reduced to 1 line to save space
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 2.0),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  padding: const EdgeInsets.all(12.0),
                  onPressed: () => context.go("/home"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
