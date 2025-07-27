// lib/features/audiobook_player/presentation/lrs_view.dart

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
  // Static cache to hold loaded data and persist across widget rebuilds.
  static final Map<String, Future<LrsData?>> _cache = {};

  // This is the magic number to tweak if highlighting is consistently ahead or behind.
  // - A POSITIVE value (e.g., 150) makes the highlight appear EARLIER.
  // - A NEGATIVE value (e.g., -100) makes the highlight appear LATER.
  static const Duration _syncOffset = Duration(milliseconds: 150);

  Future<LrsData?>? _lrsDataFuture;
  int _currentWordIndex = -1;
  StreamSubscription? _positionSubscription;

  final ScrollController _scrollController = ScrollController();
  late List<GlobalKey> _wordKeys = [];

  @override
  void initState() {
    super.initState();
    _lrsDataFuture = _getCachedLrsData();

    // Populate keys when the future completes, whether from cache or file.
    _lrsDataFuture?.then((lrsData) {
      if (lrsData != null && mounted) {
        setState(() {
          _wordKeys = List.generate(lrsData.words.length, (_) => GlobalKey());
        });
      }
    });

    _subscribeToPlayerPosition();
  }

  /// Gets the LRS data from the cache or loads it from the file if not present.
  Future<LrsData?> _getCachedLrsData() {
    if (_cache.containsKey(widget.lrsJsonPath)) {
      print("✅ Loading LRS data from cache for: ${widget.lrsJsonPath}");
      return _cache[widget.lrsJsonPath]!;
    } else {
      print("⚙️ Loading LRS data from file for: ${widget.lrsJsonPath}");
      final future = _loadLrsDataFromFile();
      _cache[widget.lrsJsonPath] = future;
      return future;
    }
  }

  /// Handles the actual file I/O and JSON parsing.
  Future<LrsData?> _loadLrsDataFromFile() async {
    try {
      final file = File(widget.lrsJsonPath);
      final jsonString = await file.readAsString();
      final decodedJson = jsonDecode(jsonString);
      return LrsData.fromJson(decodedJson);
    } catch (e) {
      print("❌ Error loading or parsing LRS JSON: $e");
      return null;
    }
  }

  /// Subscribes to the player's position and updates the highlighted word.
  void _subscribeToPlayerPosition() {
    _positionSubscription = ref.read(audiobookPlayerServiceProvider.notifier)
        .positionStream
        .listen((position) {
      _lrsDataFuture?.then((lrsData) {
        if (lrsData == null || !mounted) return;

        // Apply the sync offset to the player's current position.
        final adjustedMillis = position.inMilliseconds + _syncOffset.inMilliseconds;

        // Find the index of the LAST word that has already started.
        // This is robust and handles silent gaps between words correctly.
        final newIndex = lrsData.words.lastIndexWhere(
              (word) => word.start <= adjustedMillis,
        );

        // Only update state and scroll if the highlighted word has changed.
        if (newIndex != -1 && newIndex != _currentWordIndex) {
          setState(() {
            _currentWordIndex = newIndex;
          });
          _scrollToCurrentWord();
        }
      });
    });
  }

  /// Scrolls the list to ensure the currently highlighted word is visible.
  void _scrollToCurrentWord() {
    if (_wordKeys.isEmpty || _currentWordIndex < 0 || _currentWordIndex >= _wordKeys.length) return;

    final key = _wordKeys[_currentWordIndex];
    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        alignment: 0.5, // Center the word in the viewport.
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
        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Handle error or no data
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text("Could not load script.", style: TextStyle(color: Colors.white70)));
        }

        final lrsData = snapshot.data!;

        // Handle the brief moment before the keys are initialized after data is loaded
        if (_wordKeys.isEmpty || _wordKeys.length != lrsData.words.length) {
          return const Center(child: CircularProgressIndicator());
        }

        // Build the main content view
        return SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(20.0),
          child: Wrap(
            spacing: 6.0,
            runSpacing: 4.0,
            children: List.generate(lrsData.words.length, (index) {
              return _WordWidget(
                key: _wordKeys[index],
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