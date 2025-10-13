import 'dart:io';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:connectivity_plus/connectivity_plus.dart';


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
    BuildContext? context,
  }) async {
    print('LocalLibraryService: Downloading book: $fileName');

    // Check network connectivity first
    if (!await _checkNetworkConnectivity()) {
      if (context != null) {
        await showNetworkDialog(context);
      }
      return false;
    }

    // Request permissions
    if (!await _requestStoragePermission()) {
      print('LocalLibraryService: Storage permission denied');
      return false;
    }

    try {
      if (Platform.isAndroid) {
        // Try MediaStore approach first
        try {
          await _ensureMediaStoreInitialized();
          MediaStore.appFolder = 'VisuaLit';

          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/$fileName');
          await tempFile.writeAsBytes(fileData);

          final savedFile = await _mediaStorePlugin.saveFile(
            tempFilePath: tempFile.path,
            dirType: DirType.download,
            dirName: DirName.download,
          );

          await tempFile.delete();

          if (savedFile != null) {
            print('LocalLibraryService: Book saved via MediaStore');
            return true;
          }
        } catch (e) {
          print('LocalLibraryService: MediaStore failed, trying direct approach: $e');
        }

        // Fallback: Try direct file system access
        try {
          final downloadDir = Directory('/storage/emulated/0/Download/VisuaLit');
          await downloadDir.create(recursive: true);

          final file = File('${downloadDir.path}/$fileName');
          await file.writeAsBytes(fileData);

          print('LocalLibraryService: Book saved via direct file access');
          return true;
        } catch (e) {
          print('LocalLibraryService: Direct file access failed: $e');

          // Final fallback: Use app-specific external directory
          final appDir = await getExternalStorageDirectory();
          if (appDir != null) {
            final visuaLitDir = Directory('${appDir.path}/VisuaLit');
            await visuaLitDir.create(recursive: true);

            final file = File('${visuaLitDir.path}/$fileName');
            await file.writeAsBytes(fileData);

            print('LocalLibraryService: Book saved to app-specific directory');
            return true;
          }
        }
      } else {
        // iOS/Windows implementation remains the same
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

    return false;
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
      return true;
    }

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;

      // For Android 11+ (API 30+), request MANAGE_EXTERNAL_STORAGE
      if (androidInfo.version.sdkInt >= 30) {
        var status = await Permission.manageExternalStorage.status;
        if (!status.isGranted) {
          status = await Permission.manageExternalStorage.request();
        }

        if (status.isGranted) {
          print('LocalLibraryService: MANAGE_EXTERNAL_STORAGE permission granted');
          return true;
        } else if (status.isPermanentlyDenied) {
          print('LocalLibraryService: MANAGE_EXTERNAL_STORAGE permanently denied');
          await openAppSettings();
          return false;
        }
      }

      // Fallback to regular storage permissions
      final storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted) {
        print('LocalLibraryService: Storage permission granted');
        return true;
      }

      if (storageStatus.isPermanentlyDenied) {
        await openAppSettings();
      }

      return false;
    }

    return true;
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

  Future<bool> _checkNetworkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> showNetworkDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text(
            'Please enable mobile data or Wi-Fi to download books from the marketplace.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
            ),
            TextButton(
              child: const Text('Retry'),
              onPressed: () async {
                Navigator.of(context).pop();
                if (await _checkNetworkConnectivity()) {
                  // Retry the download operation
                } else {
                  showNetworkDialog(context);
                }
              },
            ),
          ],
        );
      },
    );
  }
}