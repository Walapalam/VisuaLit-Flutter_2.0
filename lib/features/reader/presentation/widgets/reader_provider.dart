import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';

import '../../application/book_paginator.dart';

// This provider will manage the state for a single reading session.
// It takes a bookId and viewSize and provides the ready-to-use BookPaginator.
final readerProvider = AutoDisposeFutureProviderFamily<BookPaginator, (int bookId, Size viewSize)>(
      (ref, args) async {
    final (bookId, viewSize) = args;

    print("📖 [readerProvider] Fired for bookId: $bookId, viewSize: ${viewSize.width}x${viewSize.height}");

    // Depend on Isar to get the database instance.
    final isar = await ref.watch(isarDBProvider.future);

    // Depend on the user's current reading preferences.
    final preferences = ref.watch(readingPreferencesProvider);

    // Fetch all the content blocks for the given book from the database.
    final blocks = await isar.contentBlocks.where().bookIdEqualTo(bookId).findAll();
    print("  [readerProvider] Fetched ${blocks.length} content blocks from DB.");

    if (blocks.isEmpty) {
      throw Exception('This book has no content to display.');
    }

    // Create the BookPaginator instance. This is an async operation.
    // The provider will suspend and show a loading state until this future completes.
    final paginator = await BookPaginator.create(
      allBlocks: blocks,
      viewSize: viewSize,
      preferences: preferences,
    );

    print("✅ [readerProvider] BookPaginator is ready. Returning to UI.");
    return paginator;
  },
);