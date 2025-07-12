import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'dart:async';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/application/book_paginator.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/domain/book_page.dart';
import 'package:visualit/features/reader/data/toc_entry.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';

@immutable
class ReadingState {
  final int bookId;
  final BookPaginator? paginator;
  final int currentPage;
  final bool isPaginating;

  const ReadingState({
    required this.bookId,
    this.paginator,
    this.currentPage = 0,
    this.isPaginating = true,
  });

  ReadingState copyWith({
    int? bookId,
    BookPaginator? paginator,
    int? currentPage,
    bool? isPaginating,
  }) {
    return ReadingState(
      bookId: bookId ?? this.bookId,
      paginator: paginator ?? this.paginator,
      currentPage: currentPage ?? this.currentPage,
      isPaginating: isPaginating ?? this.isPaginating,
    );
  }
}

class ReadingController extends StateNotifier<ReadingState> {
  final Isar _isar;
  final Size _viewSize;
  final ReadingPreferences _preferences;
  final Ref _ref;
  final _Debouncer _debouncer = _Debouncer(milliseconds: 1000);

  ReadingController(this._isar, this._ref, int bookId, this._viewSize)
      : _preferences = _ref.read(readingPreferencesProvider),
        super(ReadingState(bookId: bookId)) {
    print("✅ [ReadingController] Initialized for book ID: $bookId");
    _initialize();
  }

  Future<void> _initialize() async {
    print("⏳ [ReadingController] Starting initialization process...");
    try {
      state = state.copyWith(isPaginating: true);
      print("  [ReadingController] State set to: isPaginating = true");

      final book = await _isar.books.get(state.bookId);
      final initialPage = book?.lastReadPage ?? 0;
      print("  [ReadingController] Found book in DB. Last read page: $initialPage");

      final blocks = await _isar.contentBlocks
          .filter()
          .bookIdEqualTo(state.bookId)
          .sortByChapterIndex()
          .thenByBlockIndexInChapter()
          .findAll();

      print("  [ReadingController] Fetched ${blocks.length} content blocks from DB.");

      if (blocks.isEmpty) {
        print("❌ [ReadingController] CRITICAL: No content blocks found for this book. Cannot proceed.");
        state = state.copyWith(isPaginating: false);
        print("  [ReadingController] State set to: isPaginating = false (with no paginator)");
        return;
      }

      print("  [ReadingController] Creating BookPaginator...");
      final paginator = await BookPaginator.create(
        allBlocks: blocks,
        viewSize: _viewSize,
        preferences: _preferences,
      );
      print("✅ [ReadingController] BookPaginator created successfully.");

      state = state.copyWith(
        paginator: paginator,
        isPaginating: false,
        currentPage: initialPage,
      );
      print("✅ [ReadingController] Initialization complete. State updated with paginator and isPaginating = false.");

    } catch (error, stackTrace) {
      print("❌ [ReadingController] FATAL ERROR during initialization: $error");
      print(stackTrace);
      state = state.copyWith(isPaginating: false);
    }
  }

  void onPageChanged(int page) {
    if (page != state.currentPage) {
      state = state.copyWith(currentPage: page);
      _debouncer.run(() => _saveProgress(page));
    }
  }

  Future<void> _saveProgress(int page) async {
    print("ℹ️ [ReadingController] Saving progress. Page: $page");
    await _isar.writeTxn(() async {
      final book = await _isar.books.get(state.bookId);
      if (book != null) {
        book.lastReadPage = page;
        book.lastReadTimestamp = DateTime.now();
        await _isar.books.put(book);
      }
    });
  }

  Future<void> jumpToLocation(TOCEntry entry) async {
    print("ℹ️ [ReadingController] Jumping to: ${entry.title} (src: ${entry.src}, fragment: ${entry.fragment})");
    if (state.paginator == null || entry.src == null) {
      print("⚠️ [ReadingController] Paginator or entry.src is null. Cannot jump.");
      return;
    }

    final targetBlockIndex =
    state.paginator!.findBlockIndexByLocation(entry.src!, entry.fragment);

    if (targetBlockIndex != -1) {
      final targetPage = state.paginator!.getPageForBlock(targetBlockIndex);
      if (targetPage != null) {
        print("✅ [ReadingController] Found block at index $targetBlockIndex on page $targetPage. Jumping.");
        // Manually trigger the page change logic AND update the state.
        // The listener will handle the page controller jump.
        onPageChanged(targetPage);
        if (mounted) { // Ensure the notifier is still active
          state = state.copyWith(currentPage: targetPage);
        }
      } else {
        print("⚠️ [ReadingController] Could not find page for block index $targetBlockIndex. Pagination might be incomplete.");
      }
    } else {
      print("⚠️ [ReadingController] Could not find a matching block in the location map for: ${entry.title}");
    }
  }
}

class _Debouncer {
  final int milliseconds;
  VoidCallback? _action;
  Timer? _timer;

  _Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    _action = action;
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), () {
      _action?.call();
    });
  }
}

final readingControllerProvider = StateNotifierProvider.family.autoDispose<
    ReadingController, ReadingState, (int, Size)>((ref, params) {
  final isar = ref.watch(isarDBProvider).value!;
  final (bookId, viewSize) = params;
  ref.watch(readingPreferencesProvider);
  return ReadingController(isar, ref, bookId, viewSize);
});