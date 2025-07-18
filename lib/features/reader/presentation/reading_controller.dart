import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/data/toc_entry.dart';

@immutable
class ReadingState {
  final int bookId;
  final Book? book; // The full book object for metadata
  final int currentPage;
  final bool isBookLoaded;
  final TOCEntry? pendingTocNavigation; // For EpubView navigation

  const ReadingState({
    required this.bookId,
    this.book,
    this.currentPage = 0,
    this.isBookLoaded = false,
    this.pendingTocNavigation,
  });

  ReadingState copyWith({
    Book? book,
    int? currentPage,
    bool? isBookLoaded,
    TOCEntry? pendingTocNavigation,
  }) {
    return ReadingState(
      bookId: bookId,
      book: book ?? this.book,
      currentPage: currentPage ?? this.currentPage,
      isBookLoaded: isBookLoaded ?? this.isBookLoaded,
      pendingTocNavigation: pendingTocNavigation ?? this.pendingTocNavigation,
    );
  }
}

class ReadingController extends StateNotifier<ReadingState> {
  final Isar _isar;
  final Ref? ref;
  final _Debouncer _debouncer = _Debouncer(milliseconds: 1000);

  ReadingController(this._isar, int bookId, [this.ref]) : super(ReadingState(bookId: bookId)) {
    debugPrint("[DEBUG] ReadingController: Initializing controller for book ID: $bookId");
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      debugPrint("[DEBUG] ReadingController: Loading book for book ID: ${state.bookId}");
      final book = await _isar.books.get(state.bookId);

      if (book == null) {
        debugPrint("[ERROR] ReadingController: Book with ID ${state.bookId} not found in database");
        return;
      }

      debugPrint("[DEBUG] ReadingController: Book found: ${book.title ?? 'Untitled'}");

      if (mounted) {
        state = state.copyWith(
          book: book, // Save the book object to state
          currentPage: book.lastReadPage,
          isBookLoaded: true,
        );
        debugPrint("[DEBUG] ReadingController: State updated, current page: ${state.currentPage}");
      } else {
        debugPrint("[WARN] ReadingController: Controller no longer mounted during initialization");
      }
    } catch (e, stack) {
      debugPrint("[ERROR] ReadingController: Failed to initialize: $e");
      debugPrintStack(stackTrace: stack);
    }
  }

  void onPageChanged(int page) {
    try {
      debugPrint("[DEBUG] ReadingController: Page changed to $page (current: ${state.currentPage})");

      if (page != state.currentPage) {
        if (mounted) {
          debugPrint("[DEBUG] ReadingController: Updating state with new current page: $page");
          state = state.copyWith(currentPage: page);
        } else {
          debugPrint("[WARN] ReadingController: Controller not mounted, skipping state update");
        }

        debugPrint("[DEBUG] ReadingController: Scheduling save progress with debouncer");
        _debouncer.run(() => _saveProgress(page));
      } else {
        debugPrint("[DEBUG] ReadingController: Page unchanged, skipping update");
      }
    } catch (e, stack) {
      debugPrint("[ERROR] ReadingController: Error in onPageChanged: $e");
      debugPrintStack(stackTrace: stack);
    }
  }

  Future<void> _saveProgress(int page) async {
    try {
      debugPrint("[DEBUG] ReadingController: Saving reading progress for page $page");

      await _isar.writeTxn(() async {
        try {
          final book = await _isar.books.get(state.bookId);

          if (book != null) {
            debugPrint("[DEBUG] ReadingController: Updating book (${book.title ?? 'Untitled'}) with last read page: $page");
            book.lastReadPage = page;
            book.lastReadTimestamp = DateTime.now();
            await _isar.books.put(book);
            debugPrint("[DEBUG] ReadingController: Progress saved successfully");
          } else {
            debugPrint("[WARN] ReadingController: Book not found in database, progress not saved");
          }
        } catch (e) {
          debugPrint("[ERROR] ReadingController: Error in database transaction: $e");
          rethrow;
        }
      });
    } catch (e, stack) {
      debugPrint("[ERROR] ReadingController: Failed to save reading progress: $e");
      debugPrintStack(stackTrace: stack);
    }
  }

  /// Saves the EPUB CFI (Content Fragment Identifier) for the current reading position.
  /// This is used for EpubView mode to track reading progress.
  Future<void> saveEpubCfi(String cfi) async {
    try {
      debugPrint("[DEBUG] ReadingController: Saving EPUB CFI: $cfi");

      await _isar.writeTxn(() async {
        try {
          final book = await _isar.books.get(state.bookId);

          if (book != null) {
            debugPrint("[DEBUG] ReadingController: Updating book (${book.title ?? 'Untitled'}) with last read CFI");
            book.lastReadCfi = cfi;
            book.lastReadTimestamp = DateTime.now();
            await _isar.books.put(book);
            debugPrint("[DEBUG] ReadingController: CFI saved successfully");
          } else {
            debugPrint("[WARN] ReadingController: Book not found in database, CFI not saved");
          }
        } catch (e) {
          debugPrint("[ERROR] ReadingController: Error in database transaction: $e");
          rethrow;
        }
      });
    } catch (e, stack) {
      debugPrint("[ERROR] ReadingController: Failed to save EPUB CFI: $e");
      debugPrintStack(stackTrace: stack);
    }
  }

  /// Clears the pending TOC navigation
  void clearPendingTocNavigation() {
    if (state.pendingTocNavigation != null) {
      debugPrint("[DEBUG] ReadingController: Clearing pending TOC navigation");
      state = state.copyWith(pendingTocNavigation: null);
    }
  }

  Future<void> jumpToLocation(TOCEntry entry) async {
    try {
      debugPrint("[DEBUG] ReadingController: Setting pending TOC navigation - entry: ${entry.title}, src: ${entry.src}");

      if (entry.src == null) {
        debugPrint("[WARN] ReadingController: Cannot jump to location - entry has no source path");
        return;
      }

      // Set pendingTocNavigation for EpubViewWidget to observe and handle
      state = state.copyWith(
        pendingTocNavigation: entry,
      );
    } catch (e, stack) {
      debugPrint("[ERROR] ReadingController: Error jumping to location: $e");
      debugPrintStack(stackTrace: stack);
    }
  }
}

class _Debouncer {
  final int milliseconds;
  Timer? _timer;
  int _lastActionId = 0;
  bool _isExecuting = false;
  final List<_DebouncedAction> _pendingActions = [];

  _Debouncer({required this.milliseconds}) {
    debugPrint("[DEBUG] _Debouncer: Created with delay of $milliseconds ms");
  }

  /// Run an action after the debounce period, cancelling any pending actions
  void run(VoidCallback action) {
    _runWithId(action, ++_lastActionId);
  }

  /// Run an action with a specific ID to track it
  void _runWithId(VoidCallback action, int actionId) {
    try {
      debugPrint("[DEBUG] _Debouncer: Scheduling action #$actionId");
      _timer?.cancel();

      // Create a new action
      final debouncedAction = _DebouncedAction(
        id: actionId,
        action: action,
        timestamp: DateTime.now(),
      );

      // Add to pending actions list
      _pendingActions.add(debouncedAction);

      // Schedule execution
      _timer = Timer(Duration(milliseconds: milliseconds), () {
        _executeNextAction();
      });
    } catch (e) {
      debugPrint("[ERROR] _Debouncer: Error setting up debounced action: $e");
    }
  }

  /// Execute the next action in the queue
  Future<void> _executeNextAction() async {
    if (_isExecuting || _pendingActions.isEmpty) return;

    try {
      _isExecuting = true;

      // Get the most recent action (last in list)
      final action = _pendingActions.isNotEmpty ? _pendingActions.removeLast() : null;

      // Clear any older actions
      _pendingActions.clear();

      if (action != null) {
        final delay = DateTime.now().difference(action.timestamp).inMilliseconds;
        debugPrint("[DEBUG] _Debouncer: Executing action #${action.id} after ${delay}ms");

        // Execute the action
        action.action();
      }
    } catch (e) {
      debugPrint("[ERROR] _Debouncer: Error executing debounced action: $e");
    } finally {
      _isExecuting = false;

      // If there are more actions in the list, execute the next one
      if (_pendingActions.isNotEmpty) {
        // Small delay to prevent tight loop
        Timer(const Duration(milliseconds: 10), _executeNextAction);
      }
    }
  }

  /// Execute any pending actions immediately
  void flush() {
    if (_timer != null) {
      debugPrint("[DEBUG] _Debouncer: Flushing pending actions");
      _timer!.cancel();
      _timer = null;
      _executeNextAction();
    }
  }

  void dispose() {
    try {
      debugPrint("[DEBUG] _Debouncer: Disposing");
      if (_timer != null) {
        _timer!.cancel();
        _timer = null;
      }
      _pendingActions.clear();
    } catch (e) {
      debugPrint("[ERROR] _Debouncer: Error disposing: $e");
    }
  }
}

/// Helper class to track debounced actions
class _DebouncedAction {
  final int id;
  final VoidCallback action;
  final DateTime timestamp;

  _DebouncedAction({
    required this.id,
    required this.action,
    required this.timestamp,
  });
}

final readingControllerProvider =
StateNotifierProvider.family.autoDispose<ReadingController, ReadingState, int>((ref, bookId) {
  debugPrint("[DEBUG] readingControllerProvider: Creating controller for book ID: $bookId");

  try {
    final isarAsync = ref.watch(isarDBProvider);

    if (isarAsync.hasError) {
      debugPrint("[ERROR] readingControllerProvider: Isar database error: ${isarAsync.error}");
      throw isarAsync.error!;
    }

    if (!isarAsync.hasValue) {
      debugPrint("[WARN] readingControllerProvider: Isar database not yet initialized");
      throw Exception("Isar database not yet initialized");
    }

    final isar = isarAsync.value!;
    debugPrint("[DEBUG] readingControllerProvider: Isar database ready, creating controller");

    final controller = ReadingController(isar, bookId);

    ref.onDispose(() {
      debugPrint("[DEBUG] readingControllerProvider: Disposing controller for book ID: $bookId");
    });

    return controller;
  } catch (e, stack) {
    debugPrint("[ERROR] readingControllerProvider: Failed to create controller: $e");
    debugPrintStack(stackTrace: stack);
    rethrow;
  }
});
