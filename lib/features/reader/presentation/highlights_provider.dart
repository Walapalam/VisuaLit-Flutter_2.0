import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/data/highlight.dart';

// This provider returns a stream of all highlights for a specific bookId.
final highlightsProvider = StreamProvider.family.autoDispose<List<Highlight>, int>((ref, bookId) {
  final isar = ref.watch(isarDBProvider).value;
  if (isar == null) {
    return Stream.value([]);
  }

  print("  [highlightsProvider] Creating stream for bookId: $bookId");

  // Use query to watch changes, then filter by bookId in Dart
  return isar.collection<Highlight>()
      .where()
      .watch()
      .map((highlights) => highlights.where((h) => h.bookId == bookId).toList());
});