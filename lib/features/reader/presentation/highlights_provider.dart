import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/data/highlight.dart';

// This provider returns a stream of all highlights for a specific bookId.
// The UI can subscribe to this to get real-time updates.
final highlightsProvider = StreamProvider.family.autoDispose<List<Highlight>, int>((ref, bookId) {
  final isar = ref.watch(isarDBProvider).value;
  if (isar == null) {
    return Stream.value([]);
  }

  print("  [highlightsProvider] Creating stream for bookId: $bookId");

  return isar.highlights.where().bookIdEqualTo(bookId).watch(fireImmediately: true);
});