import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/features/streaks/providers/streak_providers.dart';
import 'package:visualit/features/streaks/presentation/streak_details_modal.dart';

class StreakWidget extends ConsumerWidget {
  const StreakWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakDataAsync = ref.watch(streakDataProvider);

    return streakDataAsync.when(
      loading: () {
        print('🔍 StreakWidget: Loading state');
        // Show placeholder while loading
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'x',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: '0',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(-2, -8),
              child: const Text('📚', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
      error: (error, stack) {
        print('❌ StreakWidget: Error state - $error');
        // Show error indicator
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 24),
            const SizedBox(width: 4),
            Text('!', style: TextStyle(color: Colors.red, fontSize: 20)),
          ],
        );
      },
      data: (streakData) {
        final streak = streakData.currentStreak;
        final emoji = streakData.streakEmoji;

        print('✅ StreakWidget: Data loaded - streak=$streak, emoji=$emoji');

        // Determine text color based on state
        Color numberColor;
        if (streak == 0) {
          numberColor = Colors.grey[600]!;
        } else if (emoji == '💤') {
          numberColor = Colors.orange;
        } else {
          numberColor = AppTheme.primaryGreen;
        }

        return GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) => StreakDetailsModal(streakData: streakData),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'x',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '$streak',
                      style: TextStyle(
                        color: numberColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Emoji superscripted
              Transform.translate(
                offset: const Offset(-2, -8),
                child: Text(emoji, style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        );
      },
    );
  }
}
