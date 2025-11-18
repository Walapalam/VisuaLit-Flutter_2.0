import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.9),
            Colors.black.withOpacity(0.6),
            Colors.black.withOpacity(0.0),
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 2.0),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 10),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => context.go("/home"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
