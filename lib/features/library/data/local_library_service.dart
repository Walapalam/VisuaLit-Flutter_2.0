import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class PickedFileData {
  final String path;
  final Uint8List bytes;
  PickedFileData({required this.path, required this.bytes});
}

class LocalLibraryService {

  final _mediaStorePlugin = MediaStore();
  bool _mediaStoreInitialized = false;


  /// Initialize MediaStore once when needed
  Future<void> _ensureMediaStoreInitialized() async {
    if (_mediaStoreInitialized || !Platform.isAndroid) return;

    await MediaStore.ensureInitialized();
    MediaStore.appFolder = 'VisuaLit';
    _mediaStoreInitialized = true;
    print('LocalLibraryService: MediaStore initialized with appFolder: VisuaLit');
  }

  /// Downloads a book using media_store_plus (for marketplace purchases)
  /// Saves to Downloads/VisuaLit/ folder
  Future<bool> downloadBook({
    required Uint8List fileData,
    required String fileName,
    String mimeType = 'application/epub+zip',
  }) async {
    print('LocalLibraryService: Downloading book: $fileName');

    try {
      if (Platform.isAndroid) {
        // ✅ CRITICAL FIX: Initialize MediaStore AND set appFolder
        await _ensureMediaStoreInitialized();

        // Set the app folder to VisuaLit (this is required)
        MediaStore.appFolder = 'VisuaLit';
        print('LocalLibraryService: MediaStore initialized with appFolder: VisuaLit');

        // Create temp file
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/$fileName');
        await tempFile.writeAsBytes(fileData);
        print('LocalLibraryService: Wrote temp file: ${tempFile.path}');

        // Save using MediaStore
        final savedFile = await _mediaStorePlugin.saveFile(
          tempFilePath: tempFile.path,
          dirType: DirType.download,
          dirName: DirName.download,
        );

        // Clean up temp file
        await tempFile.delete();

        print('LocalLibraryService: Book saved to: ${savedFile?.uri}');
        return savedFile != null;
      } else {
        // For iOS/Windows, use traditional file I/O
        final appDocDir = await getApplicationDocumentsDirectory();
        final visuaLitDir = Directory('${appDocDir.path}/VisuaLit');

        if (!await visuaLitDir.exists()) {
          await visuaLitDir.create(recursive: true);
        }

        final file = File('${visuaLitDir.path}/$fileName');
        await file.writeAsBytes(fileData);

        print('LocalLibraryService: Book saved to: ${file.path}');
        return true;
      }
    } catch (e, stackTrace) {
      print('LocalLibraryService: Error downloading book: $e\n$stackTrace');
      return false;
    }
  }

  /// Picks files using file_picker (for user uploads)
  Future<List<PickedFileData>> pickFiles() async {
    print('LocalLibraryService: Starting file picker...');

    if (!await _requestStoragePermission()) {
      print('LocalLibraryService: Permission denied');
      return [];
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['epub'],
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        print('LocalLibraryService: No files selected');
        return [];
      }

      final List<PickedFileData> pickedFiles = [];
      for (final file in result.files) {
        if (file.path != null && file.bytes != null) {
          pickedFiles.add(PickedFileData(
            path: file.path!,
            bytes: file.bytes!,
          ));
        }
      }

      print('LocalLibraryService: Selected ${pickedFiles.length} file(s)');
      return pickedFiles;
    } catch (e) {
      print('LocalLibraryService: Error picking files: $e');
      return [];
    }
  }

  /// Scans the VisuaLit folder for existing books
  Future<List<PickedFileData>> scanAndLoadBooks() async {
    print('LocalLibraryService: Scanning VisuaLit folder...');

    Directory? visuaLitDir;
    if (Platform.isAndroid) {
      visuaLitDir = Directory('/storage/emulated/0/Download/VisuaLit');
    } else if (Platform.isIOS) {
      final appDocDir = await getApplicationDocumentsDirectory();
      visuaLitDir = Directory('${appDocDir.path}/VisuaLit');
    } else {
      final downloads = await _getDownloadsDirectory();
      if (downloads == null) return [];
      visuaLitDir = Directory('${downloads.path}/VisuaLit');
    }

    if (!await visuaLitDir.exists()) {
      print('LocalLibraryService: VisuaLit folder does not exist');
      return [];
    }

    try {
      final files = visuaLitDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.toLowerCase().endsWith('.epub'))
          .toList();

      final List<PickedFileData> loadedFiles = [];
      for (final file in files) {
        try {
          final bytes = await file.readAsBytes();
          loadedFiles.add(PickedFileData(path: file.path, bytes: bytes));
        } catch (e) {
          print('LocalLibraryService: Error reading file ${file.path}: $e');
        }
      }

      print('LocalLibraryService: Found ${loadedFiles.length} books');
      return loadedFiles;
    } catch (e) {
      print('LocalLibraryService: Error scanning folder: $e');
      return [];
    }
  }

  /// Loads a single file from path (for retry functionality)
  Future<PickedFileData?> loadFileFromPath(String filePath) async {
    print('LocalLibraryService: Loading file from path: $filePath');

    try {
      final file = File(filePath);
      if (!await file.exists()) {
        print('LocalLibraryService: File does not exist at path: $filePath');
        return null;
      }

      final bytes = await file.readAsBytes();
      return PickedFileData(path: filePath, bytes: bytes);
    } catch (e) {
      print('LocalLibraryService: Error loading file: $e');
      return null;
    }
  }

  /// Requests storage permission using permission_handler
  Future<bool> _requestStoragePermission() async {
    print('LocalLibraryService: Requesting storage permission...');

    if (!Platform.isAndroid && !Platform.isIOS) {
      print('LocalLibraryService: Not mobile platform, skipping permission');
      return true;
    }

    final status = await Permission.storage.request();
    print('LocalLibraryService: Permission status: $status');

    if (status.isGranted) {
      print('LocalLibraryService: Storage permission granted');
      return true;
    }

    if (status.isPermanentlyDenied) {
      print('LocalLibraryService: Permission permanently denied');
      await openAppSettings();
    }

    return false;
  }

  // Helper to get downloads directory
  Future<Directory?> _getDownloadsDirectory() async {
    if (Platform.isWindows) {
      return Directory('${Platform.environment['USERPROFILE']}\\Downloads');
    } else if (Platform.isAndroid) {
      return Directory('/storage/emulated/0/Download');
    }
    return null;
  }

  // Legacy methods for audiobooks (kept for compatibility)
  Future<String?> pickFile({List<String>? allowedExtensions}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );
    return result?.files.single.path;
  }

  Future<String?> pickDirectory() async {
    if (!await _requestStoragePermission()) return null;
    return await FilePicker.platform.getDirectoryPath();
  }

  Future<List<File>> pickAudiobooks() async {
    if (!await _requestStoragePermission()) return [];
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
      allowMultiple: true,
    );
    return result?.paths.whereType<String>().map((path) => File(path)).toList() ?? [];
  }
}