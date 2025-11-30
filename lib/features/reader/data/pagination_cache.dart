import 'package:isar/isar.dart';

part 'pagination_cache.g.dart';

@collection
class PaginationCache {
  Id id = Isar.autoIncrement;

  @Index()
  late int bookId;

  @Index()
  late String chapterHref;

  @Index()
  late String settingsHash;

  /// JSON string describing page breaks.
  /// Example: [{"blockIndex": 5, "splitIndex": 10}, ...]
  List<String> pageBreaks = [];

  DateTime createdAt = DateTime.now();
}
