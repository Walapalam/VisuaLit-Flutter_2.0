import 'package:flutter/material.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/features/custom_reader/presentation/reading_constants.dart';

class ReadingNavigationBar extends StatelessWidget {
  final VoidCallback? onPreviousChapter;
  final VoidCallback? onNextChapter;
  final VoidCallback onChapterListTap;
  final int currentChapterIndex;
  final int totalChapters;
  final Widget settingsSpeedDial;
  final Widget visualizationSpeedDial;
  final Color? backgroundColor;

  const ReadingNavigationBar({
    Key? key,
    required this.onPreviousChapter,
    required this.onNextChapter,
    required this.onChapterListTap,
    required this.currentChapterIndex,
    required this.totalChapters,
    required this.settingsSpeedDial,
    required this.visualizationSpeedDial,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kReadingBottomBarHeight,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      color: backgroundColor ?? Colors.black.withOpacity(0.8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: settingsSpeedDial,
          ),
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: AppTheme.primaryGreen,
                        size: 20,
                      ),
                      onPressed: onPreviousChapter,
                    ),
                    GestureDetector(
                      onTap: onChapterListTap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Chapter ${currentChapterIndex + 1} of $totalChapters',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        color: AppTheme.primaryGreen,
                        size: 20,
                      ),
                      onPressed: onNextChapter,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: visualizationSpeedDial,
          ),
        ],
      ),
    );
  }
}
