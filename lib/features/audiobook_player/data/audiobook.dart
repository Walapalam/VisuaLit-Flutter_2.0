import 'package:isar/isar.dart';

part 'audiobook.g.dart'; // This will be regenerated

@embedded
class Chapter {
  String? title;
  String? filePath;
  int? durationInSeconds;
  int sortOrder = 0;
}

@collection
class Audiobook {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value, caseSensitive: false)
  String? title;

  String? author;
  List<byte>? coverImageBytes;

  List<Chapter> chapters = [];
  bool isSingleFile = false;

  // --- NEW FIELDS FOR STATE PERSISTENCE ---
  int lastReadChapterIndex = 0;
  int lastReadPositionInSeconds = 0;

  String get displayTitle => title ?? 'Unknown Audiobook';
}