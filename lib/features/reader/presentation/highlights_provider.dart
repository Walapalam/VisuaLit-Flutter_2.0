import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/data/highlight.dart';

/// This provider returns a stream of all highlights for a specific bookId.
/// The UI can subscribe to this to get real-time updates.
final highlightsProvider = StreamProvider.family.autoDispose<List<Highlight>, int>((ref, bookId) {
  debugPrint("[DEBUG] highlightsProvider: Creating provider for bookId: $bookId");

  try {
    final isarAsync = ref.watch(isarDBProvider);

    if (isarAsync.hasError) {
      debugPrint("[ERROR] highlightsProvider: Isar database error: ${isarAsync.error}");
      return Stream.error(isarAsync.error!);
    }

    final isar = isarAsync.value;
    if (isar == null) {
      debugPrint("[WARN] highlightsProvider: Isar is null, returning empty list");
      return Stream.value([]);
    }

    debugPrint("[DEBUG] highlightsProvider: Creating stream for bookId: $bookId");

    // Set up a callback for when this provider is disposed
    ref.onDispose(() {
      debugPrint("[DEBUG] highlightsProvider: Disposing provider for bookId: $bookId");
    });

    // Create and return the stream
    return isar.highlights
        .where()
        .bookIdEqualTo(bookId)
        .watch(fireImmediately: true)
        .handleError((error) {
          debugPrint("[ERROR] highlightsProvider: Stream error for bookId $bookId: $error");
          return <Highlight>[];
        });
  } catch (e, stack) {
    debugPrint("[ERROR] highlightsProvider: Failed to create highlights stream for bookId $bookId: $e");
    debugPrintStack(stackTrace: stack);
    return Stream.value([]);
  }
});
