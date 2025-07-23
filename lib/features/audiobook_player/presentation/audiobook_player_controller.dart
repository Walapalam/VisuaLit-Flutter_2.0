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
  void cancel() {
    _timer?.cancel();
  }
}



final audiobookPlayerControllerProvider = StateNotifierProvider.family
    .autoDispose<AudiobookPlayerController, AudiobookPlayerState, int>(
        (ref, audiobookId) {
      final isar = ref.watch(isarDBProvider).requireValue;
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
  final double playbackSpeed;
  final bool isScreenLocked;

  const AudiobookPlayerState({
    this.audiobook,
    this.isLoading = true,
    this.isPlaying = false,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.currentChapterIndex = 0,
    this.playbackSpeed = 1.0, // Default speed
    this.isScreenLocked = false,
  });

  AudiobookPlayerState copyWith({
    Audiobook? audiobook,
    bool? isLoading,
    bool? isPlaying,
    Duration? currentPosition,
    Duration? totalDuration,
    int? currentChapterIndex,
    double? playbackSpeed,
    bool? isScreenLocked,
  }) {

    return AudiobookPlayerState(
      audiobook: audiobook ?? this.audiobook,
      isLoading: isLoading ?? this.isLoading,
      isPlaying: isPlaying ?? this.isPlaying,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      isScreenLocked: isScreenLocked ?? this.isScreenLocked,
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
    // This method was already corrected in the previous step and is fine.
    // It loads the book, sets the state, and calls _loadChapter.
    print("DEBUG: [PlayerController] Initializing for audiobookId: $_audiobookId");
    final book = await _isar.audiobooks.get(_audiobookId);
    if (book == null || book.chapters.isEmpty) {
      print("❌ DEBUG: [PlayerController] Audiobook with ID $_audiobookId not found or has no chapters!");
      if (mounted) {
        state = state.copyWith(isLoading: false, audiobook: null);
      }
      return;
    }

    if (mounted) {
      state = state.copyWith(
        audiobook: book,
        currentChapterIndex: book.lastReadChapterIndex,
      );
    } else {
      return; // Abort if disposed during async gap
    }

    _listenToPlayerState();

    await _audioPlayer.setSpeed(state.playbackSpeed);

    // Load the initial chapter
    await _loadChapter(book.lastReadChapterIndex, seekToInitialPosition: true);

    print("DEBUG: [PlayerController] Initialization complete for title: '${book.displayTitle}'");
  }

  void toggleScreenLock() {
    if (!mounted) return;
    state = state.copyWith(isScreenLocked: !state.isScreenLocked);
  }

  /// Cycles through the available playback speeds.
  Future<void> cyclePlaybackSpeed() async {
    if (!mounted) return;

    // Define the cycle of speeds
    const List<double> speedCycle = [1.0, 1.25, 1.5, 1.75, 2.0, 0.5, 0.75];

    final currentSpeed = state.playbackSpeed;
    final currentIndex = speedCycle.indexOf(currentSpeed);

    // If current speed is not in the list (e.g., from a previous session),
    // default to the next speed after 1.0. Otherwise, cycle to the next one.
    final nextIndex = (currentIndex == -1) ? 1 : (currentIndex + 1) % speedCycle.length;
    final nextSpeed = speedCycle[nextIndex];

    await _audioPlayer.setSpeed(nextSpeed);
    state = state.copyWith(playbackSpeed: nextSpeed);
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
    // *** FIX 3: Add a `mounted` guard as the first line. ***
    // This is the safety net that prevents the crash.
    if (!mounted) {
      print("DEBUG: [PlayerController] Aborting save, controller is disposed.");
      return;
    }

    final book = state.audiobook;
    if (book == null) return;

    book.lastReadChapterIndex = state.currentChapterIndex;
    book.lastReadPositionInSeconds = state.currentPosition.inSeconds;

    await _isar.writeTxn(() async {
      await _isar.audiobooks.put(book);
    });
    print("DEBUG: [PlayerController] Progress saved. Chapter: ${book.lastReadChapterIndex}, Position: ${book.lastReadPositionInSeconds}s");
  }

  @override
  void dispose() {
    print("DEBUG: [PlayerController] Disposing controller.");
    // *** FIX 4: Cancel the debouncer and perform a final save. ***
    _debouncer.cancel();
    _saveProgress(); // Perform one last synchronous save before disposing.

    // Clean up all resources
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}