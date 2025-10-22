// lib/features/marketplace/data/cached_book.dart
import 'package:isar/isar.dart';

part 'cached_book.g.dart';

@collection
class CachedBook {
  Id id = Isar.autoIncrement;

  @Index()
  late int bookId; // Gutendex book ID

  late String title;
  String? author;
  String? coverUrl;
  String? downloadUrl;
  String? language;
  List<String>? subjects;

  late DateTime cachedAt;

  // Store the full JSON data
  late String rawData;

  @Index()
  String? searchQuery; // Which search query this book belongs to

  int downloadCount = 0;
  bool isBestseller = false;
}
