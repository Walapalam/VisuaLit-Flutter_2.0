import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

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
  /// This method handles storage permissions and returns a list of selected [File] objects.
  /// It returns an empty list if no files are selected or if permissions are denied.
  Future<List<File>> pickFiles() async {
    print('LocalLibraryService: Starting file picker...');

    if (!await _requestPermission()) {
      print('LocalLibraryService: Permission denied, returning empty list');
      return [];
    }

    print('LocalLibraryService: Permission granted, opening file picker');

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['epub'], // Restrict to EPUB files
      );

      print('LocalLibraryService: File picker result: ${result != null ? 'Files selected' : 'No files selected'}');

      // If the user cancels the picker, the result is null.
      if (result == null) {
        print('LocalLibraryService: User cancelled file selection');
        return [];
      }

      print('LocalLibraryService: Number of files selected: ${result.files.length}');
      print('LocalLibraryService: Selected file paths: ${result.paths}');

      // Map the valid file paths to File objects and return the list.
      final files = result.paths
          .where((path) => path != null)
          .map((path) => File(path!))
          .toList();

      print('LocalLibraryService: Number of valid files after filtering: ${files.length}');

      // Debug: Verify file existence and readability
      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        print('LocalLibraryService: File $i - Path: ${file.path}');
        print('LocalLibraryService: File $i - Exists: ${file.existsSync()}');
        print('LocalLibraryService: File $i - Size: ${file.existsSync() ? file.lengthSync() : 'N/A'} bytes');
      }

      print('LocalLibraryService: Successfully returning ${files.length} files');
      return files;
    } catch (e) {
      // Log any errors that occur during file picking.
      print('LocalLibraryService: Error picking files: $e');
      print('LocalLibraryService: Error type: ${e.runtimeType}');
      print('LocalLibraryService: Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  /// Opens the platform's directory picker and scans for all EPUB files within.
  ///
  /// This method recursively finds all files with the '.epub' extension
  /// in the selected directory and its subdirectories.
  /// It returns an empty list if no directory is selected or permissions are denied.
  Future<List<File>> scanAndLoadBooks() async {
    print('LocalLibraryService: Starting directory scan...');

    if (!await _requestPermission()) {
      print('LocalLibraryService: Permission denied, returning empty list');
      return [];
    }

    print('LocalLibraryService: Permission granted, opening directory picker');

    try {
      final directoryPath = await FilePicker.platform.getDirectoryPath();

      print('LocalLibraryService: Directory picker result: ${directoryPath ?? 'No directory selected'}');

      // If the user cancels the directory picker, the path is null.
      if (directoryPath == null) {
        print('LocalLibraryService: User cancelled directory selection');
        return [];
      }

      print('LocalLibraryService: Selected directory: $directoryPath');

      final dir = Directory(directoryPath);

      if (!dir.existsSync()) {
        print('LocalLibraryService: Selected directory does not exist');
        return [];
      }

      print('LocalLibraryService: Starting recursive scan of directory...');

      // Recursively list all entities, filter for files ending in .epub, and return them.
      final allEntities = dir.listSync(recursive: true);
      print('LocalLibraryService: Total entities found: ${allEntities.length}');

      final allFiles = allEntities.whereType<File>();
      print('LocalLibraryService: Total files found: ${allFiles.length}');

      final epubFiles = allFiles
          .where((file) => file.path.toLowerCase().endsWith('.epub'))
          .toList();

      print('LocalLibraryService: EPUB files found: ${epubFiles.length}');

      // Debug: Verify each found file
      for (int i = 0; i < epubFiles.length; i++) {
        final file = epubFiles[i];
        print('LocalLibraryService: EPUB $i - Path: ${file.path}');
        print('LocalLibraryService: EPUB $i - Exists: ${file.existsSync()}');
        print('LocalLibraryService: EPUB $i - Size: ${file.existsSync() ? file.lengthSync() : 'N/A'} bytes');
      }

      print('LocalLibraryService: Successfully returning ${epubFiles.length} EPUB files');
      return epubFiles;
    } catch (e) {
      // Log any errors that occur during directory scanning.
      print('LocalLibraryService: Error scanning directory: $e');
      print('LocalLibraryService: Error type: ${e.runtimeType}');
      print('LocalLibraryService: Stack trace: ${StackTrace.current}');
      return [];
    }
  }
}