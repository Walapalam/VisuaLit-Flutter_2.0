import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:visualit/features/reader/data/book_data.dart';

/// Enum representing the current state of the TTS engine
enum TtsState { playing, stopped, paused, continued }

/// Controller for Text-to-Speech functionality
class TtsController extends StateNotifier<TtsState> {
  final FlutterTts _flutterTts = FlutterTts();
  String _currentText = '';
  
  TtsController() : super(TtsState.stopped) {
    _initTts();
  }
  
  /// Initialize the TTS engine
  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    _flutterTts.setCompletionHandler(() {
      state = TtsState.stopped;
    });
    
    _flutterTts.setCancelHandler(() {
      state = TtsState.stopped;
    });
    
    _flutterTts.setPauseHandler(() {
      state = TtsState.paused;
    });
    
    _flutterTts.setContinueHandler(() {
      state = TtsState.continued;
    });
  }
  
  /// Speak the given text
  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    
    if (state == TtsState.playing) {
      await stop();
    }
    
    _currentText = text;
    state = TtsState.playing;
    await _flutterTts.speak(text);
  }
  
  /// Stop speaking
  Future<void> stop() async {
    await _flutterTts.stop();
    state = TtsState.stopped;
  }
  
  /// Pause speaking
  Future<void> pause() async {
    if (state == TtsState.playing) {
      await _flutterTts.pause();
      state = TtsState.paused;
    }
  }
  
  /// Continue speaking after pause
  Future<void> resume() async {
    if (state == TtsState.paused) {
      state = TtsState.playing;
      await _flutterTts.speak(_currentText);
    }
  }
  
  /// Extract text content from a list of content blocks
  String extractTextFromBlocks(List<ContentBlock> blocks) {
    return blocks
        .where((block) => block.textContent != null && block.textContent!.isNotEmpty)
        .map((block) => block.textContent)
        .join(' ');
  }
  
  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}

/// Provider for the TTS controller
final ttsControllerProvider = StateNotifierProvider<TtsController, TtsState>((ref) {
  return TtsController();
});