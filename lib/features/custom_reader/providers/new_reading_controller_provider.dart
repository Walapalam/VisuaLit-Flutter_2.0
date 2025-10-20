// lib/features/custom_reader/providers/reading_controller_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/custom_reader/new_reading_controller.dart';

final newReadingControllerProvider = FutureProvider.family<NewReadingController, int>((ref, bookId) async {
  final isar = await ref.watch(isarDBProvider.future);
  return NewReadingController(isar);
});
