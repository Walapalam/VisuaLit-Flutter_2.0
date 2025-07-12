import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/audiobook_player/data/audiobook.dart';
import 'package:visualit/features/library/data/local_library_service.dart';
import 'package:visualit/features/library/presentation/library_controller.dart';

import '../../library/data/local_library_service.dart'; // To reuse the provider

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
      final audiobooks = await _isar.audiobooks.where().findAll();
      state = AsyncValue.data(audiobooks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addAudiobook() async {
    final files = await _localLibraryService.pickAudiobooks();
    if (files.isEmpty) return;

    for (final file in files) {
      final existing = await _isar.audiobooks
          .where()
          .filePathEqualTo(file.path)
          .findFirst();

      if (existing != null) continue; // Skip if already exists

      final newAudiobook = Audiobook()
        ..filePath = file.path
      // Use the file name as the initial title, without the extension
        ..title = p.basenameWithoutExtension(file.path);

      await _isar.writeTxn(() => _isar.audiobooks.put(newAudiobook));
    }
    // Reload the list from the database to update the UI
    loadAudiobooks();
  }
}