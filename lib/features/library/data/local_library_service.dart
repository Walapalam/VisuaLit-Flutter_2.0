import 'dart:io';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
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

    // Different permissions for different Android versions
    if (Platform.isAndroid) {
      // Get Android SDK version
      final sdkVersion = await _getAndroidSdkVersion();
      print('LocalLibraryService: Android SDK version: $sdkVersion');

      if (sdkVersion >= 33) {
        // Android 13+ (API 33+): Request granular media permissions
        print('LocalLibraryService: Requesting granular media permissions for Android 13+');
        final photos = await Permission.photos.request();
        final audio = await Permission.audio.request();
        final videos = await Permission.videos.request();

        print('LocalLibraryService: Permission status - Photos: ${photos.toString()}, Audio: ${audio.toString()}, Videos: ${videos.toString()}');

        // Return true if any of the permissions are granted
        return photos.isGranted || audio.isGranted || videos.isGranted;
      } 
      else if (sdkVersion >= 30) {
        // Android 11-12 (API 30-32): Request manage external storage
        print('LocalLibraryService: Requesting manage external storage permission for Android 11-12');
        final status = await Permission.manageExternalStorage.request();
        print('LocalLibraryService: Permission status: ${status.toString()}');

        if (status.isGranted) {
          print('LocalLibraryService: Manage external storage permission granted');
          return true;
        }
      }
      // Fall back to storage permission for older versions
    }

    // Default approach for older Android versions and iOS
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

  /// Helper method to get Android SDK version
  Future<int> _getAndroidSdkVersion() async {
    if (Platform.isAndroid) {
      try {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.version.sdkInt;
      } catch (e) {
        print('LocalLibraryService: Error getting Android SDK version: $e');
      }
    }
    return 0; // Default value for non-Android platforms
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
}
