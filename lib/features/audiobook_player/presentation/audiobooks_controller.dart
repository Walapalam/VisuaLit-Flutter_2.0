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
    final mp3Files = directory.listSync()
        .where((e) => e is File && e.path.toLowerCase().endsWith('.mp3'))
        .map((e) => e.path).toList();

    if (mp3Files.isEmpty) return;
    mp3Files.sort();

    final bookTitle = p.basename(directoryPath);
    if (await _isar.audiobooks.where().titleEqualTo(bookTitle).findFirst() != null) return;

    final newBook = Audiobook()
      ..title = bookTitle
      ..isSingleFile = false; // Set the flag

    int order = 0;
    for (final filePath in mp3Files) {
      newBook.chapters.add(Chapter()
        ..filePath = filePath
        ..title = p.basenameWithoutExtension(filePath)
        ..sortOrder = order++);
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
      ..isSingleFile = true; // Set the flag

    newBook.chapters.add(Chapter()
      ..filePath = filePath
      ..title = "Full Audiobook"
      ..sortOrder = 0);

    await _isar.writeTxn(() => _isar.audiobooks.put(newBook));
    await loadAudiobooks();
  }
}