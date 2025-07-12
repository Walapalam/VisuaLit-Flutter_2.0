import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:just_audio/just_audio.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/audiobook_player/data/audiobook.dart';

// Helper class to bundle player streams
class _PlayerData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
  final PlayerState playerState;

  _PlayerData({
    required this.position,
    required this.bufferedPosition,
    required this.duration,
    required this.playerState,
  });
}

class AudiobookPlayerScreen extends ConsumerStatefulWidget {
  final int audiobookId;
  const AudiobookPlayerScreen({super.key, required this.audiobookId});

  @override
  ConsumerState<AudiobookPlayerScreen> createState() => _AudiobookPlayerScreenState();
}

class _AudiobookPlayerScreenState extends ConsumerState<AudiobookPlayerScreen> {
  final AudioPlayer _player = AudioPlayer();
  late Future<Audiobook?> _audiobookFuture;

  @override
  void initState() {
    super.initState();
    _audiobookFuture = _loadAudiobookAndSetupPlayer();
  }

  Future<Audiobook?> _loadAudiobookAndSetupPlayer() async {
    final isar = await ref.read(isarDBProvider.future);
    final audiobook = await isar.audiobooks.get(widget.audiobookId);
    if (audiobook != null && audiobook.filePath != null) {
      try {
        await _player.setFilePath(audiobook.filePath!);
      } catch (e) {
        print("Error setting audio source: $e");
        return null;
      }
    }
    return audiobook;
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  // Combine multiple streams for the UI
  Stream<_PlayerData> get _playerDataStream =>
      Stream.periodic(const Duration(milliseconds: 200)).asyncMap((_) {
        return _PlayerData(
            position: _player.position,
            bufferedPosition: _player.bufferedPosition,
            duration: _player.duration ?? Duration.zero,
            playerState: _player.playerState
        );
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
      ),
      body: FutureBuilder<Audiobook?>(
        future: _audiobookFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text('Error: Could not load audiobook.'));
          }

          final audiobook = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.album, size: 200), // Placeholder for cover art
                const SizedBox(height: 32),
                Text(
                  audiobook.title ?? 'Unknown Title',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  audiobook.author ?? 'Unknown Author',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 32),

                StreamBuilder<_PlayerData>(
                  stream: _playerDataStream,
                  builder: (context, snapshot) {
                    final data = snapshot.data;
                    final position = data?.position ?? Duration.zero;
                    final duration = data?.duration ?? Duration.zero;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Slider(
                          min: 0.0,
                          max: duration.inSeconds.toDouble(),
                          value: position.inSeconds.toDouble().clamp(0.0, duration.inSeconds.toDouble()),
                          onChanged: (value) {
                            _player.seek(Duration(seconds: value.toInt()));
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDuration(position)),
                              Text(_formatDuration(duration)),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                StreamBuilder<PlayerState>(
                  stream: _player.playerStateStream,
                  builder: (context, snapshot) {
                    final playerState = snapshot.data;
                    final processingState = playerState?.processingState;
                    final playing = playerState?.playing;

                    if (processingState == ProcessingState.loading ||
                        processingState == ProcessingState.buffering) {
                      return const CircularProgressIndicator();
                    } else if (playing != true) {
                      return IconButton(
                        icon: const Icon(Icons.play_arrow),
                        iconSize: 64.0,
                        onPressed: _player.play,
                      );
                    } else if (processingState != ProcessingState.completed) {
                      return IconButton(
                        icon: const Icon(Icons.pause),
                        iconSize: 64.0,
                        onPressed: _player.pause,
                      );
                    } else {
                      return IconButton(
                        icon: const Icon(Icons.replay),
                        iconSize: 64.0,
                        onPressed: () => _player.seek(Duration.zero),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "${d.inHours > 0 ? '${d.inHours}:' : ''}$minutes:$seconds";
  }
}