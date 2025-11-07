// lib/features/home/presentation/widgets/reading_streak_card.dart

import 'package:flutter/material.dart';
import 'package:visualit/core/theme/app_theme.dart';

class ReadingStreakCard extends StatelessWidget {
  final List<bool> streakHistory;
  final int currentStreak;
  final int longestStreak;
  final int totalDays;

  const ReadingStreakCard({
    super.key,
    required this.streakHistory,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalDays,
  });

  @override
  Widget build(BuildContext context) {
    const int daysPerRow = 7;
    final int numRows = (streakHistory.length / daysPerRow).ceil();
    const double squareSize = 15.0;
    const double spacing = 2.0;

    return Card(
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reading Streak',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: numRows * (squareSize + spacing),
              width: double.infinity,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: daysPerRow,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  childAspectRatio: 1.0,
                ),
                itemCount: streakHistory.length,
                itemBuilder: (context, i) {
                  return Container(
                    width: squareSize,
                    height: squareSize,
                    decoration: BoxDecoration(
                      color: streakHistory[i] ? AppTheme.primaryGreen :
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Divider(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StreakStat(label: 'Current', value: currentStreak),
                _StreakStat(label: 'Longest', value: longestStreak),
                _StreakStat(label: 'Total Days', value: totalDays),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakStat extends StatelessWidget {
  final String label;
  final int value;
  final double fontSize;

  const _StreakStat({
    required this.label,
    required this.value,
    this.fontSize = 14
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
