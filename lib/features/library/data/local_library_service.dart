import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

// --- PROVIDER DEFINITION ---
/// This provider creates and exposes a single instance of LocalLibraryService.
/// Any other part of the app can now 'ref.watch' this provider to access the service.
final localLibraryServiceProvider = Provider<LocalLibraryService>((ref) {
  return LocalLibraryService();
});


/// A data class to hold the path and raw byte data for a picked file.
/// This is used by the EPUB processor.
class PickedFileData {
  final String path;
  final Uint8List bytes;

  PickedFileData({required this.path, required this.bytes});
}

class LocalLibraryService {
  /// Requests necessary storage permissions for mobile platforms.
  /// Returns `true` if permission is granted, otherwise `false`.
  Future<bool> _requestPermission() async {
    // This helper function remains unchanged and supports all other methods.
    if (!Platform.isAndroid) {
      return true;
    }

    // First, check if the permission is already granted.
    final bool hasPermission = await Permission.manageExternalStorage.isGranted;
    if (hasPermission) {
      // If we already have permission, we're done.
      return true;
    }

    // If permission is not granted, we must request it.
    // For MANAGE_EXTERNAL_STORAGE, .request() opens the special system settings screen.
    // This is the correct way and avoids the SecurityException crash.
    final PermissionStatus status = await Permission.manageExternalStorage.request();

    // After the user returns from the settings screen, we check the status again.
    if (status.isGranted) {
      print("MANAGE_EXTERNAL_STORAGE permission has been granted.");
      return true;
    } else {
      print("MANAGE_EXTERNAL_STORAGE permission was not granted. Status: $status");
      // You can optionally show a dialog here explaining why the permission is needed.
      return false;
    }
  }

  // --- UNCHANGED METHOD for EPUBs ---
  /// Opens the file picker to select one or more EPUB files.
  /// This method returns the raw file bytes, which is required by the EPUB processor.
  Future<List<PickedFileData>> pickFiles() async {
    print('LocalLibraryService: Executing pickFiles() for EPUBs...');
    if (!await _requestPermission()) {
      return [];
    }
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['epub'],
        withData: true, // This is crucial for the EPUB logic.
      );

      if (result == null) {
        return [];
      }

      final List<PickedFileData> pickedFiles = [];
      for (final file in result.files) {
        if (file.path != null && file.bytes != null) {
          pickedFiles.add(PickedFileData(path: file.path!, bytes: file.bytes!));
        }
      }
      return pickedFiles;

    } catch (e) {
      print('LocalLibraryService: Error picking EPUB files: $e');
      return [];
    }
  }

  Future<String?> pickFile({List<String>? allowedExtensions}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );

    if (result != null && result.files.single.path != null) {
      return result.files.single.path!;
    }
    return null; // User canceled or no file selected
  }

  // --- ADDED METHOD for AUDIOBOOKS ---
  /// Opens the directory picker for selecting an audiobook folder.
  /// This is the new, preferred method for the multi-chapter audiobook feature.
  Future<String?> pickDirectory() async {
    print('LocalLibraryService: Executing pickDirectory() for audiobooks...');
    if (!await _requestPermission()) {
      print('LocalLibraryService: Permission denied.');
      return null;
    }
    try {
      // Returns the path of the selected directory as a String.
      return await FilePicker.platform.getDirectoryPath();
    } catch (e) {
      print('LocalLibraryService: Error picking directory: $e');
      return null;
    }
  }

  /// (Legacy/Alternative) Opens the file picker to select individual MP3 files.
  /// The new folder-based approach using `pickDirectory` is now the primary method.
  Future<List<File>> pickAudiobooks() async {
    print('LocalLibraryService: Executing legacy pickAudiobooks()...');
    if (!await _requestPermission()) {
      return [];
    }
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['mp3'],
      );

      if (result == null) {
        return [];
      }
      return result.paths
          .where((path) => path != null)
          .map((path) => File(path!))
          .toList();
    } catch (e) {
      print('LocalLibraryService: Error picking audiobooks: $e');
      return [];
    }
  }

  // This method remains available if you use it elsewhere.
  Future<List<PickedFileData>> scanAndLoadBooks() async {
    // ... (your existing implementation)
    return [];
  }
}