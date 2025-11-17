import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// This provider creates a single instance of LocalLibraryService for the app.
final localLibraryServiceProvider = Provider<AudiobookLibraryService>((ref) {
  return AudiobookLibraryService();
});

class AudiobookLibraryService {
  /// Opens the directory picker for selecting an audiobook folder.
  Future<String?> pickDirectory() async {
    try {
      return await FilePicker.platform.getDirectoryPath();
    } catch (e) {
      print('LocalLibraryService: Error picking directory: $e');
      return null;
    }
  }

  /// Opens the file picker to select a single MP3 file.
  Future<String?> pickSingleMp3File() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3'],
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null) {
        return result.files.single.path!;
      }
      return null;
    } catch (e) {
      print('LocalLibraryService: Error picking single MP3: $e');
      return null;
    }
  }
}