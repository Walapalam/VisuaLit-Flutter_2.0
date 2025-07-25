import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

/// This provider creates a single instance of LocalLibraryService for the app.
final localLibraryServiceProvider = Provider<LocalLibraryService>((ref) {
  return LocalLibraryService();
});

class LocalLibraryService {
  /// Correctly requests the special 'All Files Access' permission for scanning folders.
  Future<bool> _requestManageStoragePermission() async {
    if (!Platform.isAndroid) return true;
    if (await Permission.manageExternalStorage.isGranted) return true;

    final status = await Permission.manageExternalStorage.request();
    if (status.isGranted) return true;

    print("MANAGE_EXTERNAL_STORAGE permission was not granted. Status: $status");
    return false;
  }

  /// Requests basic storage permission, sufficient for picking single files.
  Future<bool> _requestBasicStoragePermission() async {
    if (!Platform.isAndroid) return true;
    final status = await Permission.storage.request();
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) await openAppSettings();
    return false;
  }

  /// Opens the directory picker for selecting an audiobook folder.
  Future<String?> pickDirectory() async {
    if (!await _requestManageStoragePermission()) return null;
    try {
      return await FilePicker.platform.getDirectoryPath();
    } catch (e) {
      print('LocalLibraryService: Error picking directory: $e');
      return null;
    }
  }

  /// Opens the file picker to select a single MP3 file.
  Future<String?> pickSingleMp3File() async {
    if (!await _requestBasicStoragePermission()) return null;
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