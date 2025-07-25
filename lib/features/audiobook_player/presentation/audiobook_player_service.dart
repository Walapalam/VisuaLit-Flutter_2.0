// lib/features/audiobook_player/presentation/audiobook_player_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/audiobook_player/data/audiobook.dart';

// Debouncer helper class (can be moved to a shared location if used elsewhere)
class _Debouncer {
  final int milliseconds;
  Timer? _timer;
  _Debouncer({required this.milliseconds});
  run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
  void cancel() => _timer?.cancel();
}

// --- THE NEW GLOBAL PROVIDER ---
// This is the single source of truth for audio playback.
final audiobookPlayerServiceProvider =
StateNotifierProvider<AudiobookPlayerService, AudiobookPlayerState>((ref) {
  final isar = ref.watch(isarDBProvider).requireValue;
  return AudiobookPlayerService(isar);
});

// The state class now includes all UI-related properties.
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
    this.isLoading = false,
    this.isPlaying = false,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.currentChapterIndex = 0,
    this.playbackSpeed = 1.0,
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

// This service now holds all the logic from the old controller.
class AudiobookPlayerService extends StateNotifier<AudiobookPlayerState> {
  final Isar _isar;
  final _Debouncer _debouncer = _Debouncer(milliseconds: 2000);
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;

  Stream<Duration> get positionStream => _audioPlayer.positionStream;

  AudiobookPlayerService(this._isar) : super(const AudiobookPlayerState()) {
    _listenToPlayerState();
  }

  Future<void> stopAndUnloadPlayer() async {
    if (!mounted) return;

    // First, pause the audio player.
    await _audioPlayer.pause();

    // Then, reset the state to its initial, empty state.
    // This will cause any widgets watching the provider (like MiniAudioPlayer)
    // to rebuild and hide themselves.
    state = const AudiobookPlayerState();
  }

  // This is the new primary method to start or change a book.
  Future<void> loadAndPlay(Audiobook book) async {
    // If we're already on this book, don't restart it, just ensure it's loaded.
    if (state.audiobook?.id == book.id) return;

    await _audioPlayer.stop();

    state = state.copyWith(
      audiobook: book,
      currentChapterIndex: book.lastReadChapterIndex,
      isLoading: true,
    );
    await _audioPlayer.setSpeed(state.playbackSpeed);
    await _loadChapter(book.lastReadChapterIndex, seekToInitialPosition: true);
  }

  // --- All methods below are copied from the old controller ---

  void _listenToPlayerState() {
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((playerState) {
      if (!mounted) return;
      final isEffectivelyPlaying = playerState.playing && playerState.processingState != ProcessingState.completed;
      final isLoading = playerState.processingState == ProcessingState.loading || playerState.processingState == ProcessingState.buffering;
      state = state.copyWith(isPlaying: isEffectivelyPlaying, isLoading: isLoading);
      if (playerState.processingState == ProcessingState.completed) {
        skipToNext();
      }
    });
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      if (!mounted) return;
      state = state.copyWith(currentPosition: position);
      _debouncer.run(_saveProgress);
    });
    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      if (!mounted || duration == null || duration <= Duration.zero) return;
      state = state.copyWith(totalDuration: duration);
      _saveChapterDuration(duration);
    });
  }

  Future<void> _loadChapter(int chapterIndex, {bool seekToInitialPosition = false}) async {
    if (!mounted) return;
    final book = state.audiobook;
    if (book == null || chapterIndex < 0 || chapterIndex >= book.chapters.length) return;

    state = state.copyWith(isLoading: true, currentChapterIndex: chapterIndex);
    final chapter = book.chapters[chapterIndex];
    if (chapter.filePath == null) {
      if (mounted) state = state.copyWith(isLoading: false);
      return;
    }

    try {
      final initialPosition = seekToInitialPosition ? Duration(seconds: book.lastReadPositionInSeconds) : Duration.zero;
      // We don't need the MediaItem tag for now unless you set up background audio
      await _audioPlayer.setAudioSource(AudioSource.file(chapter.filePath!), initialPosition: initialPosition);
      _audioPlayer.play();
    } catch (e) {
      print("❌ [PlayerService] Error setting audio source: $e");
      if (mounted) state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _saveChapterDuration(Duration duration) async {
    final book = state.audiobook;
    final index = state.currentChapterIndex;
    if (book == null || book.chapters[index].durationInSeconds != null) return;
    book.chapters[index].durationInSeconds = duration.inSeconds;
    await _isar.writeTxn(() => _isar.audiobooks.put(book));
    if (mounted) state = state.copyWith(audiobook: book);
  }

  Future<void> _saveProgress() async {
    if (!mounted) return;
    final book = state.audiobook;
    if (book == null) return;
    book.lastReadChapterIndex = state.currentChapterIndex;
    book.lastReadPositionInSeconds = state.currentPosition.inSeconds;
    await _isar.writeTxn(() => _isar.audiobooks.put(book));
  }

  void play() => _audioPlayer.play();
  void pause() => _audioPlayer.pause();
  void seek(Duration position) => _audioPlayer.seek(position);

  Future<void> setSpeed(double newSpeed) async {
    if (!mounted) return;
    await _audioPlayer.setSpeed(newSpeed);
    state = state.copyWith(playbackSpeed: newSpeed);
  }

  void toggleScreenLock() {
    if (!mounted) return;
    state = state.copyWith(isScreenLocked: !state.isScreenLocked);
  }

  Future<void> jumpToChapter(int index) async {
    if (!mounted) return;
    await _saveProgress();
    await _loadChapter(index);
  }

  Future<void> skipToNext() async {
    await _saveProgress();
    final book = state.audiobook;
    if (book == null) return;
    final nextChapterIndex = state.currentChapterIndex + 1;
    if (nextChapterIndex < book.chapters.length) {
      await _loadChapter(nextChapterIndex);
    } else {
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.pause();
    }
  }

  Future<void> skipToPrevious() async {
    if (_audioPlayer.position.inSeconds > 3) {
      await _audioPlayer.seek(Duration.zero);
      return;
    }
    await _saveProgress();
    final book = state.audiobook;
    if (book == null) return;
    final prevChapterIndex = state.currentChapterIndex - 1;
    if (prevChapterIndex >= 0) {
      await _loadChapter(prevChapterIndex);
    } else {
      await _audioPlayer.seek(Duration.zero);
    }
  }

  @override
  void dispose() {
    _debouncer.cancel();
    _saveProgress();
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}