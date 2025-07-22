import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/library/data/book_processing_task.dart';
import 'package:visualit/features/library/data/book_processor.dart';
import 'package:visualit/features/reader/data/book_data.dart' as db;
import 'package:visualit/features/reader/data/chapter.dart';

final backgroundTaskQueueProvider = Provider<BackgroundTaskQueue>((ref) {
  final isar = ref.watch(isarDBProvider).requireValue;
  return BackgroundTaskQueue(isar);
});

class BackgroundTaskQueue {
  final Isar _isar;
  final List<BookProcessingTask> _queue = [];
  final List<BookProcessingTask> _runningTasks = [];
  final List<BookProcessingTask> _completedTasks = [];
  final List<BookProcessingTask> _failedTasks = [];

  final int _maxConcurrentTasks = 2;
  final _taskStreamController = StreamController<List<BookProcessingTask>>.broadcast();

  Stream<List<BookProcessingTask>> get taskStream => _taskStreamController.stream;

  // Auto-purge configuration
  final Duration _taskMaxAge = Duration(days: 7); // Purge tasks older than 7 days
  Timer? _cleanupTimer;

  BackgroundTaskQueue(this._isar) {
    print("✅ [BackgroundTaskQueue] Initialized.");
    _processNextTask(); // Start processing if there are tasks in the queue

    // Schedule periodic cleanup
    _cleanupTimer = Timer.periodic(Duration(hours: 24), (_) {
      _purgeOldTasks();
    });

    // Run initial cleanup
    _purgeOldTasks();
  }

  /// Purges old tasks that meet any of these criteria:
  /// - Have exceeded the retry limit
  /// - Are older than _taskMaxAge
  /// - Have failedPermanently = true
  void _purgeOldTasks() {
    final now = DateTime.now();
    int purgedCount = 0;

    // Check completed tasks
    _completedTasks.removeWhere((task) {
      final isOld = task.completedAt != null && 
          now.difference(task.completedAt!) > _taskMaxAge;

      if (isOld) {
        purgedCount++;
        return true;
      }
      return false;
    });

    // Check failed tasks
    _failedTasks.removeWhere((task) {
      final isOld = task.completedAt != null && 
          now.difference(task.completedAt!) > _taskMaxAge;
      final hasExceededRetries = task.retryCount >= 3;
      final isPermanentlyFailed = task.failedPermanently;

      if (isOld || hasExceededRetries || isPermanentlyFailed) {
        purgedCount++;
        return true;
      }
      return false;
    });

    if (purgedCount > 0) {
      print("🧹 [BackgroundTaskQueue] Purged $purgedCount old or failed tasks");
      _notifyListeners();
    }
  }

  List<BookProcessingTask> get allTasks => [
    ..._queue,
    ..._runningTasks,
    ..._completedTasks,
    ..._failedTasks,
  ];

  void enqueueTask(BookProcessingTask task) {
    print("➕ [BackgroundTaskQueue] Enqueuing task for file: ${task.filePath}");
    _queue.add(task);
    _notifyListeners();
    _processNextTask();
  }

  void retryTask(int taskId) {
    final failedTaskIndex = _failedTasks.indexWhere((task) => task.id == taskId);
    if (failedTaskIndex != -1) {
      final task = _failedTasks.removeAt(failedTaskIndex);
      final newTask = task.copyWith(
        status: TaskStatus.queued,
        errorMessage: null,
        errorStackTrace: null,
        retryCount: 0, // Reset retry count for manual retries
        failedPermanently: false, // Reset permanent failure flag
      );
      _queue.add(newTask);
      _notifyListeners();
      _processNextTask();

      // Also update the book in the database
      _isar.writeTxn(() async {
        final book = await _isar.books.get(taskId);
        if (book != null) {
          book.failedPermanently = false;
          book.errorMessage = null;
          book.errorStackTrace = null;
          book.status = db.ProcessingStatus.queued;
          book.retryCount = 0; // Reset retry count for manual retries
          await _isar.books.put(book);
        }
      });
    }
  }

  Future<void> _processNextTask() async {
    if (_queue.isEmpty || _runningTasks.length >= _maxConcurrentTasks) {
      return;
    }

    final task = _queue.removeAt(0);

    // Check if task has exceeded max retry count
    if (task.retryCount >= 3) {
      print("🔄 [BackgroundTaskQueue] Task ${task.id} has exceeded max retry count (${task.retryCount}). Marking as permanently failed.");

      // Mark task as permanently failed
      final failedTask = task.copyWith(
        status: TaskStatus.failed,
        failedPermanently: true,
      );
      _failedTasks.add(failedTask);

      // Update book in database
      await _isar.writeTxn(() async {
        final book = await _isar.books.get(task.id);
        if (book != null) {
          book.status = db.ProcessingStatus.error;
          book.failedPermanently = true;
          await _isar.books.put(book);
        }
      });

      _notifyListeners();
      _processNextTask(); // Try next task
      return;
    }

    // Check cooldown period if this is a retry
    if (task.retryCount > 0 && task.lastTriedAt != null) {
      final cooldownPeriod = Duration(seconds: 10);
      final timeSinceLastTry = DateTime.now().difference(task.lastTriedAt!);

      if (timeSinceLastTry < cooldownPeriod) {
        print("⏳ [BackgroundTaskQueue] Task ${task.id} is in cooldown period. Requeuing for later.");
        // Put back in queue at the end
        _queue.add(task);
        _notifyListeners();
        _processNextTask(); // Try next task
        return;
      }
    }

    final updatedTask = task.copyWith(
      status: TaskStatus.running,
      startedAt: DateTime.now(),
      lastTriedAt: DateTime.now(),
    );
    _runningTasks.add(updatedTask);
    _notifyListeners();

    // Update book status in database
    await _isar.writeTxn(() async {
      final book = await _isar.books.where().epubFilePathEqualTo(task.filePath).findFirst();
      if (book != null) {
        book.status = db.ProcessingStatus.processing;
        await _isar.books.put(book);
      }
    });

    try {
      // Process the book in an isolate
      final result = await compute(_processBookInIsolate, {
        'filePath': task.filePath,
        'fileBytes': task.fileBytes,
        'bookId': task.id,
      });

      // Update book in database with processed data
      await _isar.writeTxn(() async {
        final book = await _isar.books.get(task.id);
        if (book != null) {
          book.title = result['title'];
          book.author = result['author'];
          book.coverImageBytes = result['coverImageBytes'];
          book.status = db.ProcessingStatus.ready;
          book.toc = result['toc'];
          book.publisher = result['publisher'];
          book.language = result['language'];
          book.publicationDate = result['publicationDate'];
          await _isar.books.put(book);
        }

        // Save chapters first
        final chapters = result['chapters'] as List<Chapter>;
        final chapterIds = await _isar.chapters.putAll(chapters);

        // Update content blocks with chapter IDs
        final contentBlocks = result['contentBlocks'] as List<db.ContentBlock>;
        for (int i = 0; i < contentBlocks.length; i++) {
          final block = contentBlocks[i];
          // Find the chapter for this block
          for (int j = 0; j < chapters.length; j++) {
            if (block.chapterIndex == chapters[j].orderIndex) {
              block.chapterId = chapterIds[j];
              break;
            }
          }
        }

        // Save content blocks
        await _isar.contentBlocks.putAll(contentBlocks);
      });

      // Mark task as completed
      final completedTask = updatedTask.copyWith(
        status: TaskStatus.completed,
        completedAt: DateTime.now(),
      );
      _runningTasks.remove(updatedTask);
      _completedTasks.add(completedTask);

    } catch (e, stackTrace) {
      print("❌ [BackgroundTaskQueue] Error processing book: $e");

      // Increment retry count
      final newRetryCount = updatedTask.retryCount + 1;
      final hasExceededMaxRetries = newRetryCount >= 3;

      print("🔄 [BackgroundTaskQueue] Task ${updatedTask.id} failed. Retry count: $newRetryCount/3");

      // Update book status to error
      await _isar.writeTxn(() async {
        final book = await _isar.books.get(task.id);
        if (book != null) {
          book.status = db.ProcessingStatus.error;
          book.errorMessage = e.toString();
          book.errorStackTrace = stackTrace.toString();
          book.failedPermanently = hasExceededMaxRetries;
          book.retryCount = newRetryCount;
          await _isar.books.put(book);
        }
      });

      // Create updated task with incremented retry count
      final failedTask = updatedTask.copyWith(
        status: TaskStatus.failed,
        completedAt: DateTime.now(),
        errorMessage: e.toString(),
        errorStackTrace: stackTrace,
        retryCount: newRetryCount,
        failedPermanently: hasExceededMaxRetries,
      );

      _runningTasks.remove(updatedTask);

      // If we haven't exceeded max retries, requeue the task
      if (!hasExceededMaxRetries) {
        print("⏳ [BackgroundTaskQueue] Requeuing task ${updatedTask.id} for retry after cooldown");
        final requeuedTask = failedTask.copyWith(
          status: TaskStatus.queued,
        );
        _queue.add(requeuedTask);
      } else {
        // Otherwise, mark as permanently failed
        print("❌ [BackgroundTaskQueue] Task ${updatedTask.id} has permanently failed after $newRetryCount attempts");
        _failedTasks.add(failedTask);
      }
    }

    _notifyListeners();

    // Process next task if available
    _processNextTask();
  }

  void _notifyListeners() {
    _taskStreamController.add(allTasks);
  }

  void dispose() {
    _cleanupTimer?.cancel();
    _taskStreamController.close();
  }
}

// This function runs in an isolate
Future<Map<String, dynamic>> _processBookInIsolate(Map<String, dynamic> params) async {
  final filePath = params['filePath'] as String;
  final fileBytes = params['fileBytes'] as Uint8List;
  final bookId = params['bookId'] as int;

  try {
    // Use the BookProcessor to parse the EPUB file
    final parsedBook = await BookProcessor.parseEpub(fileBytes, filePath);

    // Convert chapters and blocks to database entities
    final contentBlocks = <db.ContentBlock>[];
    final chapters = <Chapter>[];

    // First, create all chapters
    for (final parsedChapter in parsedBook.chapters) {
      final chapter = Chapter(
        bookId: bookId,
        title: parsedChapter.title,
        orderIndex: parsedChapter.index,
        sourcePath: parsedChapter.path
      );
      chapters.add(chapter);
    }

    // Now create content blocks with references to chapters
    for (int chapterIndex = 0; chapterIndex < parsedBook.chapters.length; chapterIndex++) {
      final parsedChapter = parsedBook.chapters[chapterIndex];
      final chapter = chapters[chapterIndex];

      for (int i = 0; i < parsedChapter.blocks.length; i++) {
        final block = parsedChapter.blocks[i];
        final contentBlock = db.ContentBlock()
          ..bookId = bookId
          ..chapterId = chapter.id // This will be set after chapter is saved
          ..chapterIndex = parsedChapter.index // Keep for backward compatibility
          ..blockIndexInChapter = i
          ..src = parsedChapter.path
          ..blockType = block.blockType
          ..htmlContent = block.htmlContent
          ..textContent = block.textContent
          ..imageBytes = block.imageBytes;

        contentBlocks.add(contentBlock);
      }
    }

    // Return the parsed data
    return {
      'title': parsedBook.title,
      'author': parsedBook.author,
      'coverImageBytes': parsedBook.coverImageBytes,
      'toc': parsedBook.toc,
      'publisher': parsedBook.publisher,
      'language': parsedBook.language,
      'publicationDate': parsedBook.publicationDate,
      'chapters': chapters,
      'contentBlocks': contentBlocks,
    };
  } catch (e, stackTrace) {
    print("❌ [_processBookInIsolate] Error processing book: $e");
    print(stackTrace);
    rethrow; // Rethrow to be caught by the BackgroundTaskQueue
  }
}
