import 'dart:io';
import 'dart:typed_data'; // Import this
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

// A new class to hold our picked file data securely
class PickedFileData {
  final String path;
  final Uint8List bytes;

  PickedFileData({required this.path, required this.bytes});
}


class LocalLibraryService {
  /// Requests necessary storage permissions for mobile platforms.
  ///
  /// Returns `true` if permission is granted, otherwise `false`.
  Future<bool> _requestPermission() async {
    print('LocalLibraryService: Requesting storage permission...');

    // Permissions are generally only required on mobile platforms.
    if (!Platform.isAndroid && !Platform.isIOS) {
      print('LocalLibraryService: Running on desktop platform, skipping permission request');
      return true;
    }

    print('LocalLibraryService: Running on mobile platform (${Platform.operatingSystem}), requesting storage permission');

    final status = await Permission.storage.request();
    print('LocalLibraryService: Permission status: ${status.toString()}');

    if (status.isGranted) {
      print('LocalLibraryService: Storage permission granted');
      return true;
    }

    // If permission is permanently denied, guide the user to app settings.
    if (status.isPermanentlyDenied) {
      print('LocalLibraryService: Permission permanently denied, opening app settings');
      await openAppSettings();
    } else {
      print('LocalLibraryService: Permission denied');
    }

    return false;
  }

  /// Opens the platform's file picker to select one or more EPUB files.
  ///
  /// This method handles storage permissions and returns a list of selected [PickedFileData] objects.
  /// It returns an empty list if no files are selected or if permissions are denied.
  Future<List<PickedFileData>> pickFiles() async {
    print('LocalLibraryService: Starting file picker...');

    if (!await _requestPermission()) {
      print('LocalLibraryService: Permission denied, returning empty list');
      return [];
    }

    try {
      // Ask for the file bytes directly
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['epub'],
        withData: true, // This is the crucial change!
      );

      if (result == null) {
        print('LocalLibraryService: User cancelled file selection');
        return [];
      }

      final List<PickedFileData> pickedFiles = [];
      for (final file in result.files) {
        if (file.path != null && file.bytes != null) {
          print('LocalLibraryService: Successfully read ${file.bytes!.lengthInBytes} bytes from ${file.name}');
          pickedFiles.add(PickedFileData(path: file.path!, bytes: file.bytes!));
        } else {
          print('LocalLibraryService: Warning - picked file ${file.name} was missing path or data.');
        }
      }

      return pickedFiles;

    } catch (e) {
      print('LocalLibraryService: Error picking files: $e');
      return [];
    }
  }


  /// Opens the platform's directory picker and scans for all EPUB files within.
  ///
  /// This method recursively finds all files with the '.epub' extension
  /// in the selected directory and its subdirectories.
  Future<List<PickedFileData>> scanAndLoadBooks() async {
    print('LocalLibraryService: Starting directory scan...');

    if (!await _requestPermission()) {
      print('LocalLibraryService: Permission denied, returning empty list');
      return [];
    }

    try {
      final directoryPath = await FilePicker.platform.getDirectoryPath();
      if (directoryPath == null) {
        print('LocalLibraryService: User cancelled directory selection');
        return [];
      }

      final dir = Directory(directoryPath);
      if (!await dir.exists()) {
        print('LocalLibraryService: Selected directory does not exist');
        return [];
      }

      final List<PickedFileData> pickedFiles = [];
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File && entity.path.toLowerCase().endsWith('.epub')) {
          try {
            final bytes = await entity.readAsBytes();
            pickedFiles.add(PickedFileData(path: entity.path, bytes: bytes));
            print('LocalLibraryService: Scanned and read ${bytes.lengthInBytes} bytes from ${entity.path}');
          } catch (e) {
            print('LocalLibraryService: Error reading scanned file ${entity.path}: $e');
          }
        }
      }
      return pickedFiles;

    } catch(e) {
      print('LocalLibraryService: Error scanning directory: $e');
      return [];
    }
  }

  /// Opens the platform's file picker to select one or more MP3 files.
  ///
  /// Returns a list of selected audio files, or an empty list if no files are selected
  /// or if permissions are denied.
  Future<List<File>> pickAudiobooks() async {
    print('LocalLibraryService: Starting audiobook picker...');

    if (!await _requestPermission()) {
      print('LocalLibraryService: Permission denied for audiobook picking');
      return [];
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['mp3'], // Restrict to MP3 files
      );

      if (result == null) {
        print('LocalLibraryService: No audiobooks selected');
        return [];
      }

      final files = result.paths
          .where((path) => path != null)
          .map((path) => File(path!))
          .toList();

      print('LocalLibraryService: Selected ${files.length} audiobooks');
      return files;
    } catch (e) {
      print('LocalLibraryService: Error picking audiobooks: $e');
      return [];
    }
  }

  /// Loads a file from the given path and returns a PickedFileData object.
  ///
  /// This is useful for retrying processing of a book that previously failed.
  Future<PickedFileData?> loadFileFromPath(String filePath) async {
    print('LocalLibraryService: Loading file from path: $filePath');

    try {
      final file = File(filePath);
      if (!await file.exists()) {
        print('LocalLibraryService: File does not exist at path: $filePath');
        return null;
      }

      final bytes = await file.readAsBytes();
      print('LocalLibraryService: Successfully read ${bytes.lengthInBytes} bytes from $filePath');
      return PickedFileData(path: filePath, bytes: bytes);
    } catch (e) {
      print('LocalLibraryService: Error loading file from path: $e');
      return null;
    }
  }
}
