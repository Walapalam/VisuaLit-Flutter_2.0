// lib/features/audiobook_player/presentation/audiobook_player_controller.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/audiobook_player/data/audiobook.dart';

// Debouncer helper class to prevent excessive database writes
class _Debouncer {
  final int milliseconds;
  Timer? _timer;
  _Debouncer({required this.milliseconds});

  run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

final audiobookPlayerControllerProvider = StateNotifierProvider.family
    .autoDispose<AudiobookPlayerController, AudiobookPlayerState, int>(
        (ref, audiobookId) {
      final isar = ref.watch(isarDBProvider).requireValue;
      // Keep the provider alive even when not watched, so music doesn't stop
      // when the user navigates away temporarily (e.g., to the home screen).
      // The autoDispose will still clean it up when the player screen is popped.
      final link = ref.keepAlive();
      final timer = Timer(const Duration(seconds: 30), () {
        link.close(); // Close the link after 30s of inactivity.
      });

      ref.onDispose(() {
        timer.cancel();
      });

      return AudiobookPlayerController(isar, audiobookId);
    });

// A simple state class to hold all player-related data.
class AudiobookPlayerState {
  final Audiobook? audiobook;
  final bool isLoading;
  final bool isPlaying;
  final Duration currentPosition;
  final Duration totalDuration;
  final int currentChapterIndex;

  const AudiobookPlayerState({
    this.audiobook,
    this.isLoading = true,
    this.isPlaying = false,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.currentChapterIndex = 0,
  });

  AudiobookPlayerState copyWith({
    Audiobook? audiobook,
    bool? isLoading,
    bool? isPlaying,
    Duration? currentPosition,
    Duration? totalDuration,
    int? currentChapterIndex,
  }) {
    return AudiobookPlayerState(
      audiobook: audiobook ?? this.audiobook,
      isLoading: isLoading ?? this.isLoading,
      isPlaying: isPlaying ?? this.isPlaying,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
    );
  }
}

class AudiobookPlayerController extends StateNotifier<AudiobookPlayerState> {
  final Isar _isar;
  final int _audiobookId;
  final _Debouncer _debouncer = _Debouncer(milliseconds: 2000); // Shorter debounce time

  // This is the one and only AudioPlayer instance for this controller
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;

  AudiobookPlayerController(this._isar, this._audiobookId)
      : super(const AudiobookPlayerState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    print("DEBUG: [PlayerController] Initializing for audiobookId: $_audiobookId");
    final book = await _isar.audiobooks.get(_audiobookId);
    if (book == null || book.chapters.isEmpty) {
      print("❌ DEBUG: [PlayerController] Audiobook with ID $_audiobookId not found or has no chapters!");
      state = state.copyWith(isLoading: false, audiobook: null); // Explicitly set book to null
      return;
    }

    // *** FIX: Update state with the loaded book and initial chapter index ***
    state = state.copyWith(
      audiobook: book,
      currentChapterIndex: book.lastReadChapterIndex,
    );

    _listenToPlayerState();

    // Load the initial chapter
    await _loadChapter(book.lastReadChapterIndex, seekToInitialPosition: true);

    print("DEBUG: [PlayerController] Initialization complete for title: '${book.displayTitle}'");
  }

  Future<void> _loadChapter(int chapterIndex, {bool seekToInitialPosition = false}) async {
    // Ensure the controller isn't disposed
    if (!mounted) return;

    final book = state.audiobook;
    if (book == null || chapterIndex < 0 || chapterIndex >= book.chapters.length) {
      print("❌ DEBUG: [PlayerController] Invalid chapter index: $chapterIndex");
      return;
    }

    state = state.copyWith(isLoading: true, currentChapterIndex: chapterIndex);
    final chapter = book.chapters[chapterIndex];
    if (chapter.filePath == null) {
      print("❌ DEBUG: [PlayerController] Chapter $chapterIndex has no file path!");
      state = state.copyWith(isLoading: false);
      return;
    }

    try {
      final audioSource = AudioSource.file(
        chapter.filePath!,
        tag: MediaItem(
          id: '${book.id}-${chapter.sortOrder}',
          album: book.displayTitle,
          title: chapter.title ?? 'Chapter ${chapter.sortOrder + 1}',
          artist: book.author,
          artUri: book.coverImageBytes != null
              ? Uri.parse('data:image/png;base64,${base64Encode(book.coverImageBytes!)}')
              : null,
        ),
      );

      // *** FIX: Set the audio source and handle initial position ***
      final initialPosition = seekToInitialPosition ? Duration(seconds: book.lastReadPositionInSeconds) : Duration.zero;
      await _audioPlayer.setAudioSource(audioSource, initialPosition: initialPosition);

      // We don't set isLoading to false here. Instead, we let the player state stream handle it.
      // The player will transition from 'loading' to 'ready', which will update the UI naturally.
      _audioPlayer.play(); // Start playing automatically

    } catch (e) {
      print("❌ DEBUG: [PlayerController] Error setting audio source: $e");
      state = state.copyWith(isLoading: false);
    }
  }

  void _listenToPlayerState() {
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((playerState) {
      final isEffectivelyPlaying = playerState.playing && playerState.processingState != ProcessingState.completed;
      final isLoading = playerState.processingState == ProcessingState.loading || playerState.processingState == ProcessingState.buffering;

      state = state.copyWith(isPlaying: isEffectivelyPlaying, isLoading: isLoading);

      if (playerState.processingState == ProcessingState.completed) {
        skipToNext();
      }
    });

    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      state = state.copyWith(currentPosition: position);
      _debouncer.run(_saveProgress);
    });

    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      state = state.copyWith(totalDuration: duration ?? Duration.zero);
    });
  }

  void play() => _audioPlayer.play();
  void pause() => _audioPlayer.pause();
  void seek(Duration position) => _audioPlayer.seek(position);

  Future<void> skipToNext() async {
    print("DEBUG: [PlayerController] Skip to next action triggered.");
    await _saveProgress(); // Save progress of the current chapter first
    final currentBook = state.audiobook;
    if (currentBook == null) return;

    final nextChapterIndex = state.currentChapterIndex + 1;
    if (nextChapterIndex < currentBook.chapters.length) {
      await _loadChapter(nextChapterIndex);
    } else {
      print("DEBUG: [PlayerController] End of audiobook reached.");
      // Optional: seek to start of last chapter and pause, or show a completion message.
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.pause();
    }
  }

  Future<void> skipToPrevious() async {
    print("DEBUG: [PlayerController] Skip to previous action triggered.");

    // If more than 3 seconds into the track, just restart it. Otherwise, go to the previous track.
    if (_audioPlayer.position.inSeconds > 3) {
      await _audioPlayer.seek(Duration.zero);
      return;
    }

    await _saveProgress(); // Save progress
    final currentBook = state.audiobook;
    if (currentBook == null) return;

    final prevChapterIndex = state.currentChapterIndex - 1;
    if (prevChapterIndex >= 0) {
      await _loadChapter(prevChapterIndex);
    } else {
      print("DEBUG: [PlayerController] Already at the first chapter.");
      await _audioPlayer.seek(Duration.zero);
    }
  }

  Future<void> _saveProgress() async {
    final book = state.audiobook;
    if (book == null || !mounted) return;

    // Use a temporary variable to avoid race conditions with the state
    final currentPosition = state.currentPosition;
    final currentChapter = state.currentChapterIndex;

    // Update the book object in memory
    book.lastReadChapterIndex = currentChapter;
    book.lastReadPositionInSeconds = currentPosition.inSeconds;

    await _isar.writeTxn(() async {
      await _isar.audiobooks.put(book);
    });
    print("DEBUG: [PlayerController] Progress saved. Chapter: $currentChapter, Position: ${currentPosition.inSeconds}s");
  }

  @override
  void dispose() {
    print("DEBUG: [PlayerController] Disposing controller. Performing final save and releasing player.");
    _saveProgress(); // ** FIX: Perform a final save **
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}