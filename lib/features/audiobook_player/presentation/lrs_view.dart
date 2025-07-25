import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/audiobook_player/presentation/audiobook_player_service.dart';

// 1. --- DATA MODELS for AssemblyAI JSON ---

/// Represents a single word with its timing information.
class LrsWord {
  final String text;
  final int start; // in milliseconds
  final int end;   // in milliseconds

  LrsWord({required this.text, required this.start, required this.end});

  factory LrsWord.fromJson(Map<String, dynamic> json) {
    return LrsWord(
      text: json['text'],
      start: json['start'],
      end: json['end'],
    );
  }
}

/// Represents the entire script data containing a list of words.
class LrsData {
  final List<LrsWord> words;

  LrsData({required this.words});

  factory LrsData.fromJson(Map<String, dynamic> json) {
    final List<dynamic> wordList = json['words'] ?? [];
    return LrsData(
      words: wordList.map((wordJson) => LrsWord.fromJson(wordJson)).toList(),
    );
  }
}

// 2. --- THE MAIN LRS VIEW WIDGET ---

class LrsView extends ConsumerStatefulWidget {
  final String lrsJsonPath;
  const LrsView({super.key, required this.lrsJsonPath});

  @override
  ConsumerState<LrsView> createState() => _LrsViewState();
}

class _LrsViewState extends ConsumerState<LrsView> {
  Future<LrsData?>? _lrsDataFuture;
  int _currentWordIndex = -1;
  StreamSubscription? _positionSubscription;

  // Use a scroll controller to automatically scroll the view
  final ScrollController _scrollController = ScrollController();
  // Store global keys for each word to find its position
  late List<GlobalKey> _wordKeys;


  @override
  void initState() {
    super.initState();
    _lrsDataFuture = _loadLrsData();
    _subscribeToPlayerPosition();
  }

  Future<LrsData?> _loadLrsData() async {
    try {
      final file = File(widget.lrsJsonPath);
      final jsonString = await file.readAsString();
      final decodedJson = jsonDecode(jsonString);
      final lrsData = LrsData.fromJson(decodedJson);

      // Initialize a GlobalKey for each word
      _wordKeys = List.generate(lrsData.words.length, (_) => GlobalKey());
      return lrsData;
    } catch (e) {
      print("Error loading or parsing LRS JSON: $e");
      return null;
    }
  }

  void _subscribeToPlayerPosition() {
    final playerState = ref.read(audiobookPlayerServiceProvider);

    // We listen to the positionStream directly for efficient updates
    _positionSubscription = ref.read(audiobookPlayerServiceProvider.notifier)
        .positionStream
        .listen((position) {
      _lrsDataFuture?.then((lrsData) {
        if (lrsData == null || !mounted) return;

        final currentMillis = position.inMilliseconds;

        // Find the index of the word currently being spoken
        // This is a simple linear search. For very long chapters, this could be optimized.
        final newIndex = lrsData.words.indexWhere(
              (word) => currentMillis >= word.start && currentMillis <= word.end,
        );

        if (newIndex != -1 && newIndex != _currentWordIndex) {
          setState(() {
            _currentWordIndex = newIndex;
          });
          _scrollToCurrentWord();
        }
      });
    });
  }

  void _scrollToCurrentWord() {
    if (_currentWordIndex < 0 || _currentWordIndex >= _wordKeys.length) return;

    final key = _wordKeys[_currentWordIndex];
    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        alignment: 0.5, // Center the word in the viewport
      );
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LrsData?>(
      future: _lrsDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || snapshot.data == null) {
          return const Center(child: Text("Could not load script.", style: TextStyle(color: Colors.white70)));
        }

        final lrsData = snapshot.data!;

        return SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(20.0),
          child: Wrap( // Wrap allows text to flow to the next line naturally
            spacing: 6.0, // Horizontal space between words
            runSpacing: 4.0, // Vertical space between lines
            children: List.generate(lrsData.words.length, (index) {
              return _WordWidget(
                key: _wordKeys[index], // Assign the key
                text: lrsData.words[index].text,
                isHighlighted: index == _currentWordIndex,
              );
            }),
          ),
        );
      },
    );
  }
}

// 3. --- HELPER WIDGET FOR A SINGLE WORD ---

class _WordWidget extends StatelessWidget {
  final String text;
  final bool isHighlighted;

  const _WordWidget({
    super.key,
    required this.text,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    const Color accentGreen = Color(0xFF1DB954);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 1.0),
      decoration: BoxDecoration(
        color: isHighlighted ? accentGreen : Colors.transparent,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
          color: isHighlighted ? Colors.black : Colors.white70,
        ),
      ),
    );
  }
}