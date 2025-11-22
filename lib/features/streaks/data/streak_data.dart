import 'package:isar/isar.dart';

part 'streak_data.g.dart';

@collection
class StreakData {
  Id id = Isar.autoIncrement;

  // Current streak information
  int currentStreak = 0;
  int longestStreak = 0;

  // Track if user has read today
  bool hasReadToday = false;

  // Last reading session
  DateTime? lastReadDate;

  // Minutes read today
  int todayMinutes = 0;

  // Grace period tracking
  bool isUsingGracePeriod = false;
  DateTime? gracePeriodStartDate;

  // Reading history (stores dates when user read 10+ minutes)
  List<DateTime> readingDates = [];

  // Total statistics
  int totalReadingMinutes = 0;
  int totalDaysRead = 0;

  // Helper to check if streak is active
  bool get isStreakActive {
    if (lastReadDate == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastRead = DateTime(
      lastReadDate!.year,
      lastReadDate!.month,
      lastReadDate!.day,
    );

    final daysDiff = today.difference(lastRead).inDays;

    // Active if read today or yesterday (with grace period)
    return daysDiff <= 1 || (daysDiff == 2 && isUsingGracePeriod);
  }

  // Helper to determine which emoji to show
  String get streakEmoji {
    if (currentStreak == 0) return '📚';
    if (!isStreakActive || isUsingGracePeriod) return '💤';
    return '🔥';
  }
}
