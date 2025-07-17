import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:visualit/core/services/isar_service.dart';

final isarProvider = Provider<IsarService>((ref) {
  debugPrint("[DEBUG] isarProvider: Creating IsarService instance");
  final service = IsarService();

  ref.onDispose(() {
    debugPrint("[DEBUG] isarProvider: Disposing IsarService");
  });

  return service;
});

final isarDBProvider = FutureProvider<Isar>((ref) async {
  debugPrint("[DEBUG] isarDBProvider: Initializing Isar database");
  try {
    final isarService = ref.watch(isarProvider);
    final db = await isarService.getDB();
    debugPrint("[DEBUG] isarDBProvider: Isar database initialized successfully");

    ref.onDispose(() {
      debugPrint("[DEBUG] isarDBProvider: Provider disposed");
    });

    return db;
  } catch (e, stack) {
    debugPrint("[ERROR] isarDBProvider: Failed to initialize Isar database: $e");
    debugPrintStack(stackTrace: stack);
    rethrow;
  }
});
