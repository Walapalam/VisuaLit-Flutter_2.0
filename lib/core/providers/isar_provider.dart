import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:visualit/core/services/new_isar_service.dart';

final isarProvider = Provider<IsarService>((ref) {
  return IsarService();
});

final isarDBProvider = FutureProvider<Isar>((ref) async {
  final isarService = ref.watch(isarProvider);
  return await isarService.db;
});
