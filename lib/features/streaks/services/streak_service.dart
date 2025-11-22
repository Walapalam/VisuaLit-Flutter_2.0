import 'package:isar/isar.dart';
import 'package:visualit/features/streaks/data/streak_data.dart';

class StreakService {
  final Isar isar;

  // Minimum minutes required per day to count toward streak
  static const int minMinutesPerDay = 1; // Changed to 1 for debugging

  StreakService(this.isar);

  /// Get or create the streak data
  Future<StreakData> getStreakData() async {
    var streakData = await isar.streakDatas.get(1);

    if (streakData == null) {
      streakData = StreakData()..id = 1;
      await isar.writeTxn(() async {
        await isar.streakDatas.put(streakData!);
      });
    }

    return streakData;
  }

  /// Record a reading session
  Future<void> recordReadingSession(int minutesRead) async {
    final streakData = await getStreakData();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    await isar.writeTxn(() async {
      // Update today's minutes
      if (streakData.lastReadDate != null) {
        final lastReadDay = DateTime(
          streakData.lastReadDate!.year,
          streakData.lastReadDate!.month,
          streakData.lastReadDate!.day,
        );

        if (lastReadDay == today) {
          // Same day, add to today's minutes
          streakData.todayMinutes += minutesRead;
        } else {
          // New day, reset today's minutes
          streakData.todayMinutes = minutesRead;
        }
      } else {
        streakData.todayMinutes = minutesRead;
      }

      streakData.lastReadDate = now;
      streakData.totalReadingMinutes += minutesRead;

      // Check if we've hit the minimum for today
      if (streakData.todayMinutes >= minMinutesPerDay &&
          !streakData.hasReadToday) {
        streakData.hasReadToday = true;

        // Add today to reading dates if not already there
        if (!streakData.readingDates.any((date) {
          final d = DateTime(date.year, date.month, date.day);
          return d == today;
        })) {
          streakData.readingDates.add(today);
          streakData.totalDaysRead++;
        }

        // Recalculate streak
        await _updateStreak(streakData);
      }

      await isar.streakDatas.put(streakData);
    });
  }

  /// Update streak calculation
  Future<void> _updateStreak(StreakData streakData) async {
    if (streakData.readingDates.isEmpty) {
      streakData.currentStreak = 0;
      return;
    }

    // Sort dates in descending order
    final sortedDates = List<DateTime>.from(streakData.readingDates)
      ..sort((a, b) => b.compareTo(a));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final mostRecentRead = DateTime(
      sortedDates.first.year,
      sortedDates.first.month,
      sortedDates.first.day,
    );

    final daysSinceLastRead = today.difference(mostRecentRead).inDays;

    // Check if streak is broken (more than 2 days without grace period)
    if (daysSinceLastRead > 2) {
      streakData.currentStreak = 0;
      streakData.isUsingGracePeriod = false;
      streakData.gracePeriodStartDate = null;
      return;
    }

    // Handle grace period
    if (daysSinceLastRead == 2) {
      streakData.isUsingGracePeriod = true;
      if (streakData.gracePeriodStartDate == null) {
        streakData.gracePeriodStartDate = today;
      }
    } else if (daysSinceLastRead <= 1) {
      streakData.isUsingGracePeriod = false;
      streakData.gracePeriodStartDate = null;
    }

    // Calculate current streak
    int streak = 1;
    DateTime currentDate = mostRecentRead;

    for (int i = 1; i < sortedDates.length; i++) {
      final prevDate = DateTime(
        sortedDates[i].year,
        sortedDates[i].month,
        sortedDates[i].day,
      );

      final daysDiff = currentDate.difference(prevDate).inDays;

      if (daysDiff == 1) {
        // Consecutive day
        streak++;
        currentDate = prevDate;
      } else if (daysDiff == 2) {
        // One day gap (grace period)
        streak++;
        currentDate = prevDate;
      } else {
        // Streak broken
        break;
      }
    }

    streakData.currentStreak = streak;

    // Update longest streak
    if (streak > streakData.longestStreak) {
      streakData.longestStreak = streak;
    }
  }

  /// Reset daily tracking at midnight
  Future<void> resetDailyTracking() async {
    final streakData = await getStreakData();

    await isar.writeTxn(() async {
      streakData.hasReadToday = false;
      streakData.todayMinutes = 0;

      // Recalculate streak to check if it's still active
      await _updateStreak(streakData);

      await isar.streakDatas.put(streakData);
    });
  }

  /// Force recalculate streak (useful for debugging or data migration)
  Future<void> recalculateStreak() async {
    final streakData = await getStreakData();

    await isar.writeTxn(() async {
      await _updateStreak(streakData);
      await isar.streakDatas.put(streakData);
    });
  }
}
