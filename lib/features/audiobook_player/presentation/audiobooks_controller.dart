// lib/features/audiobook_player/presentation/audiobooks_controller.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/audiobook_player/data/audiobook.dart';
import 'package:visualit/features/audiobook_player/data/audiobook_library_service.dart';
// --- (1) IMPORT THE PLAYER SERVICE ---
import 'package:visualit/features/audiobook_player/presentation/audiobook_player_service.dart';

/// This provider creates the controller and makes it available to the UI.
final audiobooksControllerProvider = StateNotifierProvider.autoDispose<
    AudiobooksController, AsyncValue<List<Audiobook>>>((ref) {
  final isar = ref.watch(isarDBProvider).requireValue;
  final localLibraryService = ref.watch(localLibraryServiceProvider);
  // --- (2) PASS THE REF TO THE CONTROLLER ---
  // This allows the controller to read other providers.
  return AudiobooksController(isar, localLibraryService, ref);
});

class AudiobooksController extends StateNotifier<AsyncValue<List<Audiobook>>> {
  final Isar _isar;
  final AudiobookLibraryService _localLibraryService;
  // --- (3) STORE THE REF ---
  final Ref _ref;

  AudiobooksController(this._isar, this._localLibraryService, this._ref)
      : super(const AsyncValue.loading()) {
    loadAudiobooks();
  }

  Future<void> loadAudiobooks() async {
    state = const AsyncValue.loading();
    try {
      final audiobooks = await _isar.audiobooks.where().sortByTitle().findAll();
      state = AsyncValue.data(audiobooks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Helper to find and read a cover image file from a directory.
  Future<List<int>?> _findAndReadCoverImage(String path, {required bool isDirectory}) async {
    final directoryPath = isDirectory ? path : p.dirname(path);
    final directory = Directory(directoryPath);
    if (!await directory.exists()) return null;

    File? coverFile;

    // 1. For single files, first check for an image with the same base name.
    if (!isDirectory) {
      final baseName = p.basenameWithoutExtension(path);
      const extensions = ['.jpg', '.jpeg', '.png'];
      for (final ext in extensions) {
        final file = File(p.join(directoryPath, baseName + ext));
        if (await file.exists()) {
          coverFile = file;
          break;
        }
      }
    }

    // 2. If not found, check for common cover names (e.g., cover.jpg).
    if (coverFile == null) {
      const commonNames = ['cover.jpg', 'cover.png', 'folder.jpg', 'folder.png', 'artwork.jpg', 'artwork.png'];
      for (final name in commonNames) {
        final file = File(p.join(directoryPath, name));
        if (await file.exists()) {
          coverFile = file;
          break;
        }
      }
    }

    // 3. If a file was found, read its bytes.
    if (coverFile != null) {
      try {
        return await coverFile.readAsBytes();
      } catch (e) {
        print("Error reading cover image file: ${coverFile.path}. Error: $e");
        return null;
      }
    }
    return null;
  }

  /// Asks the service for a folder path and processes it.
  Future<void> addAudiobookFromFolder() async {
    final directoryPath = await _localLibraryService.pickDirectory();
    if (directoryPath == null) return;

    final directory = Directory(directoryPath);
    // Find all .mp3 files and sort them to ensure correct chapter order.
    final mp3Files = directory.listSync()
        .where((e) => e is File && e.path.toLowerCase().endsWith('.mp3'))
        .map((e) => e.path)
        .toList();

    if (mp3Files.isEmpty) {
      print("No MP3 files found in the selected directory.");
      return;
    }
    // Sorting ensures that "chapter_1.mp3", "chapter_2.mp3", etc., are in order.
    mp3Files.sort();

    final bookTitle = p.basename(directoryPath);
    if (await _isar.audiobooks.where().titleEqualTo(bookTitle).findFirst() != null) {
      print("An audiobook with this title already exists.");
      return;
    }

    final coverBytes = await _findAndReadCoverImage(directoryPath, isDirectory: true);

    final newBook = Audiobook()
      ..title = bookTitle
      ..isSingleFile = false
      ..coverImageBytes = coverBytes;

    int order = 0;
    for (final filePath in mp3Files) {
      final chapterTitle = p.basenameWithoutExtension(filePath);

      final jsonPath = p.setExtension(filePath, '.json');
      final jsonFile = File(jsonPath);

      newBook.chapters.add(AudiobookChapter()
        ..filePath = filePath
        ..title = chapterTitle
        ..sortOrder = order++
        ..lrsJsonPath = await jsonFile.exists() ? jsonPath : null);
    }

    await _isar.writeTxn(() => _isar.audiobooks.put(newBook));
    await loadAudiobooks();
  }

  /// Asks the service for a single file path and processes it.
  Future<void> addAudiobookFromFile() async {
    final filePath = await _localLibraryService.pickSingleMp3File();
    if (filePath == null) return;

    final bookTitle = p.basenameWithoutExtension(filePath);
    if (await _isar.audiobooks.where().titleEqualTo(bookTitle).findFirst() != null) return;

    final coverBytes = await _findAndReadCoverImage(filePath, isDirectory: false);

    final newBook = Audiobook()
      ..title = bookTitle
      ..isSingleFile = true
      ..coverImageBytes = coverBytes;

    final jsonPath = p.setExtension(filePath, '.json');
    final jsonFile = File(jsonPath);

    newBook.chapters.add(AudiobookChapter()
      ..filePath = filePath
      ..title = "Full Audiobook"
      ..sortOrder = 0
      ..lrsJsonPath = await jsonFile.exists() ? jsonPath : null);

    await _isar.writeTxn(() => _isar.audiobooks.put(newBook));
    await loadAudiobooks();
  }

  // --- (4) NEW DELETE METHOD ---
  /// Deletes an audiobook from the database and stops playback if it's the current book.
  Future<void> deleteAudiobook(int audiobookId) async {
    // Read the player service to interact with it
    final playerNotifier = _ref.read(audiobookPlayerServiceProvider.notifier);
    final currentPlayerState = _ref.read(audiobookPlayerServiceProvider);

    // If the book being deleted is the one currently loaded, stop and unload it.
    if (currentPlayerState.audiobook?.id == audiobookId) {
      await playerNotifier.stopAndUnload();
    }

    // Perform the delete transaction in Isar
    await _isar.writeTxn(() async {
      await _isar.audiobooks.delete(audiobookId);
    });

    // Update the UI state efficiently by removing the book from the existing list
    // This avoids a full reload and prevents a loading spinner from appearing.
    final currentBooks = state.valueOrNull ?? [];
    state = AsyncData(currentBooks.where((book) => book.id != audiobookId).toList());
  }
}