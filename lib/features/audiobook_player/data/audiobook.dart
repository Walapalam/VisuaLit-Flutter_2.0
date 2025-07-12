import 'package:isar/isar.dart';

part 'audiobook.g.dart'; // Run build_runner to generate this

@collection
class Audiobook {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value, caseSensitive: false)
  String? filePath; // Path to the MP3 file on the device

  String? title;
  String? author;
  List<byte>? coverImageBytes; // We can try to extract this later if possible

  // To store playback progress
  int? lastPosition;
  int? totalDuration;
}