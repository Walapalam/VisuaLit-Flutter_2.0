// lib/features/audiobook_player/presentation/widgets/progress_slider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/audiobook_player/presentation/audiobook_player_service.dart';

// --- DEDICATED WIDGET 1: For the progress slider and timers ---
class ProgressSlider extends ConsumerWidget {
  const ProgressSlider({super.key});

  String _formatDuration(Duration d) {
    d = d.isNegative ? Duration.zero : d;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(audiobookPlayerServiceProvider.select((s) => s.currentPosition));
    final duration = ref.watch(audiobookPlayerServiceProvider.select((s) => s.totalDuration));
    final playerService = ref.read(audiobookPlayerServiceProvider.notifier);

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(trackHeight: 3.0, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7.0), overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0)),
          child: Slider(
            value: position.inSeconds.toDouble().clamp(0.0, duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 0.0),
            max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0,
            min: 0,
            activeColor: const Color(0xFF1DB954),
            inactiveColor: Colors.grey.shade800,
            thumbColor: Colors.white,
            onChanged: (value) => playerService.seek(Duration(seconds: value.round())),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(position), style: TextStyle(color: Colors.grey[400])),
              Text(_formatDuration(duration), style: TextStyle(color: Colors.grey[400])),
            ],
          ),
        ),
      ],
    );
  }
}
