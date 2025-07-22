import 'package:flutter_riverpod/flutter_riverpod.dart';

final libraryProvider = StateNotifierProvider<LibraryNotifier, List<Map<String, dynamic>>>((ref) {
  return LibraryNotifier();
});

class LibraryNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  LibraryNotifier() : super([]);

  void addBook(Map<String, dynamic> book) {
    state = [...state, book];
  }
}