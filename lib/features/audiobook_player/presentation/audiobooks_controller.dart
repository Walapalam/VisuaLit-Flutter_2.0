// lib/features/audiobook_player/presentation/audiobooks_controller.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/audiobook_player/data/audiobook.dart';
import 'package:visualit/features/audiobook_player/data/local_library_service.dart';

/// This provider creates the controller and makes it available to the UI.
final audiobooksControllerProvider = StateNotifierProvider.autoDispose<
    AudiobooksController, AsyncValue<List<Audiobook>>>((ref) {
  final isar = ref.watch(isarDBProvider).requireValue;
  final localLibraryService = ref.watch(localLibraryServiceProvider);
  return AudiobooksController(isar, localLibraryService);
});

class AudiobooksController extends StateNotifier<AsyncValue<List<Audiobook>>> {
  final Isar _isar;
  final LocalLibraryService _localLibraryService;

  AudiobooksController(this._isar, this._localLibraryService)
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

    final newBook = Audiobook()
      ..title = bookTitle
      ..isSingleFile = false;

    int order = 0;
    for (final filePath in mp3Files) {
      final chapterTitle = p.basenameWithoutExtension(filePath); // e.g., "chapter_1"

      // --- THIS IS THE KEY LOGIC FOR LRS ---
      // 1. It takes the full path of the mp3 file (e.g., ".../My Book/chapter_1.mp3")
      // 2. It changes the extension to ".json" -> ".../My Book/chapter_1.json"
      final jsonPath = p.setExtension(filePath, '.json');
      final jsonFile = File(jsonPath);

      // 3. It creates a new Chapter object.
      newBook.chapters.add(Chapter()
        ..filePath = filePath
        ..title = chapterTitle
        ..sortOrder = order++
      // 4. It checks if the corresponding .json file actually exists.
      //    If it exists, its path is saved; otherwise, lrsJsonPath is null.
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

    final newBook = Audiobook()
      ..title = bookTitle
      ..isSingleFile = true;

    // For single files, we can also check for a matching JSON file.
    final jsonPath = p.setExtension(filePath, '.json');
    final jsonFile = File(jsonPath);

    newBook.chapters.add(Chapter()
      ..filePath = filePath
      ..title = "Full Audiobook"
      ..sortOrder = 0
      ..lrsJsonPath = await jsonFile.exists() ? jsonPath : null);

    await _isar.writeTxn(() => _isar.audiobooks.put(newBook));
    await loadAudiobooks();
  }
}