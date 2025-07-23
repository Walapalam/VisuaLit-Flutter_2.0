import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:visualit/core/services/isar_service.dart';

/// Provider for IsarService.
/// This must be overridden in main.dart using `overrideWithValue(...)`
/// to ensure only one instance is used app-wide.
final isarProvider = Provider<IsarService>((ref) {
  throw UnimplementedError('isarProvider must be overridden in main.dart');
});

/// FutureProvider that gives access to the Isar database instance.
/// Relies on isarProvider being properly overridden.
final isarDBProvider = FutureProvider<Isar>((ref) async {
  final isarService = ref.watch(isarProvider);
  return await isarService.db;
});
