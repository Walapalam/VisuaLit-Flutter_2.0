import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// A new class to hold our picked file data securely
class PickedFileData {
  final String path;
  final Uint8List bytes;

  PickedFileData({required this.path, required this.bytes});
}

class LocalLibraryService {
  /// Opens the platform's file picker to select one or more EPUB files.
  /// Uses withData to avoid direct filesystem reads and permissions.
  Future<List<PickedFileData>> pickFiles() async {
    print('LocalLibraryService: Starting file picker...');

    try {
      // Ask for the file bytes directly
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['epub'],
        withData: true, // Crucial: get file bytes via picker channel
      );

      if (result == null) {
        print('LocalLibraryService: User cancelled file selection');
        return [];
      }

      final List<PickedFileData> pickedFiles = [];
      for (final file in result.files) {
        if (file.path != null && file.bytes != null) {
          print(
            'LocalLibraryService: Read ${file.bytes!.lengthInBytes} bytes from ${file.name}',
          );
          pickedFiles.add(PickedFileData(path: file.path!, bytes: file.bytes!));
        } else {
          print(
            'LocalLibraryService: Warning - picked file ${file.name} missing path or data.',
          );
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

  /// Opens the directory picker for selecting an audiobook folder.
  /// No broad storage permission is requested.
  Future<String?> pickDirectory() async {
    print('LocalLibraryService: Executing pickDirectory() for audiobooks...');
    try {
      // Returns the path of the selected directory as a String.
      return await FilePicker.platform.getDirectoryPath();
    } catch (e) {
      print('LocalLibraryService: Error picking directory: $e');
      return null;
    }
  }

  /// Opens the platform's directory picker and scans for all EPUB files within.
  /// Requires the user to select a directory; no broad storage permission needed.
  Future<List<PickedFileData>> scanAndLoadBooks() async {
    print('LocalLibraryService: Starting directory scan...');

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
            print(
              'LocalLibraryService: Scanned and read ${bytes.lengthInBytes} bytes from ${entity.path}',
            );
          } catch (e) {
            print(
              'LocalLibraryService: Error reading scanned file ${entity.path}: $e',
            );
          }
        }
      }
      return pickedFiles;
    } catch (e) {
      print('LocalLibraryService: Error scanning directory: $e');
      return [];
    }
  }

  /// Opens the platform's file picker to select one or more MP3 files.
  /// Returns a list of selected audio files via direct paths (no broad perms).
  Future<List<File>> pickAudiobooks() async {
    print('LocalLibraryService: Executing legacy pickAudiobooks()...');

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
  /// Works for files inside app library and for picked files reachable by path.
  Future<PickedFileData?> loadFileFromPath(String filePath) async {
    print('LocalLibraryService: Loading file from path: $filePath');

    try {
      // Resolve path if it's relative
      final resolvedPath = await resolvePath(filePath);
      final file = File(resolvedPath);

      if (!await file.exists()) {
        print(
          'LocalLibraryService: File does not exist at path: $resolvedPath',
        );
        return null;
      }

      final bytes = await file.readAsBytes();
      print(
        'LocalLibraryService: Successfully read ${bytes.lengthInBytes} bytes from $resolvedPath',
      );
      return PickedFileData(path: resolvedPath, bytes: bytes);
    } catch (e) {
      print('LocalLibraryService: Error loading file from path: $e');
      return null;
    }
  }

  /// Returns the root directory for the app's library storage.
  /// On Android: App-scoped external storage.
  /// On iOS: Application Documents directory.
  Future<Directory> getLibraryRoot() async {
    if (Platform.isAndroid) {
      final base = await getExternalStorageDirectory();
      if (base == null) {
        throw Exception("App external storage not accessible");
      }
      return Directory('${base.path}/VisuaLit');
    } else {
      final docs = await getApplicationDocumentsDirectory();
      return Directory('${docs.path}/VisuaLit');
    }
  }

  /// Resolves a potentially relative path to an absolute path.
  /// If the path is already absolute, it returns it as is (unless it needs migration).
  Future<String> resolvePath(String path) async {
    if (path.isEmpty) return path;

    // If it's already an absolute path, check if we need to fix it (migration scenario)
    // or just return it.
    if (path.startsWith('/')) {
      // Simple check: if it exists, return it.
      if (await File(path).exists()) {
        return path;
      }

      // If it doesn't exist, it might be an old absolute path from a previous iOS container.
      // We'll try to treat it as relative if it contains "VisuaLit".
      if (path.contains('VisuaLit/')) {
        final relativePart = path.split('VisuaLit/').last;
        final root = await getLibraryRoot();
        return '${root.path}/$relativePart';
      }

      return path;
    }

    // It's a relative path, append to library root
    final root = await getLibraryRoot();
    return '${root.path}/$path';
  }
}
