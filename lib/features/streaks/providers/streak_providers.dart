import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/streaks/data/streak_data.dart';
import 'package:visualit/features/streaks/services/streak_service.dart';

// Streak service provider
final streakServiceProvider = Provider<StreakService>((ref) {
  final isar = ref.watch(isarDBProvider).valueOrNull;
  if (isar == null) {
    throw Exception('Isar not initialized');
  }
  return StreakService(isar);
});

// Streak data provider
final streakDataProvider = StreamProvider<StreakData>((ref) {
  final isar = ref.watch(isarDBProvider).valueOrNull;

  print(
    '🔍 StreakDataProvider: Isar is ${isar == null ? "NULL" : "initialized"}',
  );

  if (isar == null) {
    print('⚠️ StreakDataProvider: Returning empty StreakData (Isar null)');
    return Stream.value(StreakData());
  }

  // Watch for changes to streak data
  return isar.streakDatas.watchLazy().asyncMap((_) async {
    print('🔍 StreakDataProvider: Fetching streak data from Isar');
    final streakData = await isar.streakDatas.get(1);
    print(
      '✅ StreakDataProvider: Got streak data - ${streakData != null ? "found" : "null, creating new"}',
    );
    return streakData ?? StreakData();
  });
});
