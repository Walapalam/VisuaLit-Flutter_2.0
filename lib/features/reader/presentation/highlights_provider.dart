import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/data/highlight.dart';

/// A Riverpod provider that supplies a stream of highlights for a specific book.
///
/// It uses `StreamProvider.family` to create a unique stream for each `bookId`.
/// The `.autoDispose` modifier ensures that the stream is automatically closed
/// and resources are released when it's no longer being listened to.
final highlightsProvider = StreamProvider.family.autoDispose<List<Highlight>, int>((ref, bookId) {
  // Watch the Isar database provider to get the database instance.
  final isar = ref.watch(isarDBProvider).value;

  // If the Isar instance is not yet available (e.g., during app startup),
  // return an empty stream to prevent errors.
  if (isar == null) {
    return Stream.value([]);
  }

  // Use debugPrint for better logging, especially during development.
  debugPrint("  [highlightsProvider] Creating new Isar stream for bookId: $bookId");

  // Create and return a query stream from Isar.
  // - `isar.highlights`: Accesses the Highlight collection.
  // - `.where()`: Begins a query builder.
  // - `.bookIdEqualTo(bookId)`: Filters the highlights to only include those matching the given bookId.
  // - `.watch(fireImmediately: true)`: Subscribes to the query. The stream will emit the
  //   current results immediately upon listening and then emit new lists of results
  //   whenever the matching data changes in the database.
  return isar.highlights.where().bookIdEqualTo(bookId).watch(fireImmediately: true);
});
