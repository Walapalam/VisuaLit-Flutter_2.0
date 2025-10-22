// dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/custom_reader/data/highlight.dart';

final highlightProvider = StateNotifierProvider<HighlightController, List<Highlight>>((ref) {
  return HighlightController();
});

class HighlightController extends StateNotifier<List<Highlight>> {
  HighlightController() : super([]);

  void addHighlight(Highlight highlight) {
    state = [...state, highlight];
    // TODO: Persist to Isar
  }

  void removeHighlight(int id) {
    state = state.where((h) => h.id != id).toList();
    // TODO: Remove from Isar
  }
}
