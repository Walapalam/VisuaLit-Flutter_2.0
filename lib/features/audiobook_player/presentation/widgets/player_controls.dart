// lib/features/audiobook_player/presentation/widgets/player_controls.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/audiobook_player/presentation/audiobook_player_service.dart';

// --- DEDICATED WIDGET 2: For the player controls ---
class PlayerControls extends ConsumerWidget {
  const PlayerControls({super.key});

  void _showSpeedSelectionMenu(BuildContext context, WidgetRef ref) {
    final playerService = ref.read(audiobookPlayerServiceProvider.notifier);
    final currentSpeed = ref.read(audiobookPlayerServiceProvider).playbackSpeed;
    const List<double> availableSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    const Color accentGreen = Color(0xFF1DB954);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF191919),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
                child: Text('Playback Speed', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              ...availableSpeeds.map((speed) {
                return ListTile(
                  title: Text(speed == 1.0 ? 'Normal' : '${speed}x', style: TextStyle(color: Colors.white, fontWeight: currentSpeed == speed ? FontWeight.bold : FontWeight.normal)),
                  trailing: currentSpeed == speed ? const Icon(Icons.check, color: accentGreen) : null,
                  onTap: () {
                    playerService.setSpeed(speed);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerService = ref.read(audiobookPlayerServiceProvider.notifier);
    final isPlaying = ref.watch(audiobookPlayerServiceProvider.select((s) => s.isPlaying));
    final isScreenLocked = ref.watch(audiobookPlayerServiceProvider.select((s) => s.isScreenLocked));
    final playbackSpeed = ref.watch(audiobookPlayerServiceProvider.select((s) => s.playbackSpeed));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 52, height: 52,
          child: TextButton(
            onPressed: isScreenLocked ? null : () => _showSpeedSelectionMenu(context, ref),
            style: TextButton.styleFrom(foregroundColor: Colors.white, shape: const CircleBorder()),
            child: Text("${playbackSpeed}x", style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        IconButton(onPressed: isScreenLocked ? null : playerService.skipToPrevious, icon: const Icon(Icons.skip_previous, size: 40), color: Colors.white),
        IconButton(
          iconSize: 70,
          onPressed: isScreenLocked ? null : (isPlaying ? playerService.pause : playerService.play),
          icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
          color: const Color(0xFF1DB954),
        ),
        IconButton(onPressed: isScreenLocked ? null : playerService.skipToNext, icon: const Icon(Icons.skip_next, size: 40), color: Colors.white),
        IconButton(
          icon: Icon(isScreenLocked ? Icons.lock : Icons.lock_outline, size: 28),
          color: Colors.white,
          onPressed: playerService.toggleScreenLock,
        ),
      ],
    );
  }
}
