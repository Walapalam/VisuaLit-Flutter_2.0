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
  final _Debouncer _debouncer = _Debouncer(milliseconds: 2000);

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
      print("❌ DEBUG: [PlayerController] Audiobook with ID $_audiobookId not found!");
      if (mounted) state = state.copyWith(isLoading: false, audiobook: null);
      return;
    }

    if (mounted) {
      state = state.copyWith(
        audiobook: book,
        currentChapterIndex: book.lastReadChapterIndex,
      );
    } else { return; }

    _listenToPlayerState();
    await _audioPlayer.setSpeed(state.playbackSpeed);
    await _loadChapter(book.lastReadChapterIndex, seekToInitialPosition: true);
    print("DEBUG: [PlayerController] Initialization complete for '${book.displayTitle}'");
  }

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
      final initialPosition = seekToInitialPosition ? Duration(seconds: book.lastReadPositionInSeconds) : Duration.zero;
      await _audioPlayer.setAudioSource(audioSource, initialPosition: initialPosition);
      _audioPlayer.play();
    } catch (e) {
      print("❌ DEBUG: [PlayerController] Error setting audio source: $e");
      if (mounted) state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _saveChapterDuration(Duration duration) async {
    final book = state.audiobook;
    final index = state.currentChapterIndex;
    if (book == null || book.chapters[index].durationInSeconds != null) return;

    book.chapters[index].durationInSeconds = duration.inSeconds;
    await _isar.writeTxn(() async {
      await _isar.audiobooks.put(book);
    });
    print("DEBUG: [PlayerController] Saved duration for chapter $index: ${duration.inSeconds}s");
    if (mounted) state = state.copyWith(audiobook: book);
  }

  Future<void> _saveProgress() async {
    if (!mounted) return;
    final book = state.audiobook;
    if (book == null) return;
    book.lastReadChapterIndex = state.currentChapterIndex;
    book.lastReadPositionInSeconds = state.currentPosition.inSeconds;
    await _isar.writeTxn(() async {
      await _isar.audiobooks.put(book);
    });
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
    final book = state.audiobook;
    if (book == null || index < 0 || index >= book.chapters.length) return;
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
    print("DEBUG: [PlayerController] Disposing controller.");
    _debouncer.cancel();
    _saveProgress();
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}