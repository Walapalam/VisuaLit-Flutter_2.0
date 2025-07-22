import 'dart:io';
import 'dart:typed_data'; // Import this
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

// A new class to hold our picked file data securely
class PickedFileData {
  final String path;
  final Uint8List bytes;

  PickedFileData({required this.path, required this.bytes});
}


class LocalLibraryService {
  /// Requests all necessary permissions at once.
  ///
  /// This method can be called at app startup to ensure all permissions are granted.
  /// Returns `true` if all permissions are granted, otherwise `false`.
  Future<bool> requestAllPermissions() async {
    print('LocalLibraryService: Requesting all permissions at once...');

    // Permissions are generally only required on mobile platforms.
    if (!Platform.isAndroid && !Platform.isIOS) {
      print('LocalLibraryService: Running on desktop platform, skipping permission request');
      return true;
    }

    if (Platform.isAndroid) {
      final sdkVersion = await _getAndroidSdkVersion();
      print('LocalLibraryService: Android SDK version: $sdkVersion');

      if (sdkVersion >= 33) {
        // For Android 13+, request all specific media permissions
        print('LocalLibraryService: Android 13+ detected, requesting all media permissions');

        // First check if we already have the permissions
        Map<Permission, PermissionStatus> currentStatuses = {
          Permission.photos: await Permission.photos.status,
          Permission.audio: await Permission.audio.status,
          Permission.videos: await Permission.videos.status,
          Permission.storage: await Permission.storage.status,
        };

        print('LocalLibraryService: Current permission statuses: $currentStatuses');

        // If we already have all the necessary permissions, return true
        if (currentStatuses[Permission.photos]!.isGranted && 
            currentStatuses[Permission.audio]!.isGranted && 
            currentStatuses[Permission.videos]!.isGranted) {
          print('LocalLibraryService: All necessary permissions already granted');
          return true;
        }

        // Request essential permissions first (the ones we actually need for EPUB files)
        Map<Permission, PermissionStatus> essentialStatuses = await [
          Permission.photos,
          Permission.audio,
          Permission.videos,
          Permission.storage,
        ].request();

        print('LocalLibraryService: Essential permissions status: $essentialStatuses');

        // Check if essential permissions are granted
        bool essentialGranted = essentialStatuses[Permission.photos]!.isGranted || 
                               essentialStatuses[Permission.audio]!.isGranted || 
                               essentialStatuses[Permission.videos]!.isGranted || 
                               essentialStatuses[Permission.storage]!.isGranted;

        if (essentialGranted) {
          print('LocalLibraryService: Essential permissions granted');
          return true;
        }

        // Request additional permissions if essential ones failed
        Map<Permission, PermissionStatus> additionalStatuses = await [
          Permission.bluetooth,
          Permission.bluetoothConnect,
          Permission.bluetoothScan,
          Permission.notification,
          Permission.systemAlertWindow,
          Permission.ignoreBatteryOptimizations,
        ].request();

        print('LocalLibraryService: Additional permissions status: $additionalStatuses');

        // If any permission is permanently denied, guide the user to app settings
        if (essentialStatuses.values.any((status) => status.isPermanentlyDenied)) {
          print('LocalLibraryService: Some essential permissions permanently denied, opening app settings');
          await openAppSettings();

          // Check if permissions were granted after returning from settings
          currentStatuses = {
            Permission.photos: await Permission.photos.status,
            Permission.audio: await Permission.audio.status,
            Permission.videos: await Permission.videos.status,
            Permission.storage: await Permission.storage.status,
          };

          print('LocalLibraryService: Updated permission statuses after settings: $currentStatuses');

          return currentStatuses.values.any((status) => status.isGranted);
        }

        return false;
      } else {
        // For Android 10-12, request storage permission
        print('LocalLibraryService: Android 10-12 detected, requesting storage permission');

        // Check if we already have the permission
        final currentStatus = await Permission.storage.status;
        if (currentStatus.isGranted) {
          print('LocalLibraryService: Storage permission already granted');
          return true;
        }

        // Request storage permission
        final status = await Permission.storage.request();
        print('LocalLibraryService: Storage permission status: ${status.toString()}');

        if (status.isGranted) {
          print('LocalLibraryService: Storage permission granted');
          return true;
        }

        // If permission is permanently denied, guide the user to app settings
        if (status.isPermanentlyDenied) {
          print('LocalLibraryService: Storage permission permanently denied, opening app settings');
          await openAppSettings();

          // Check if permission was granted after returning from settings
          final updatedStatus = await Permission.storage.status;
          print('LocalLibraryService: Updated storage permission status after settings: $updatedStatus');

          return updatedStatus.isGranted;
        } else {
          print('LocalLibraryService: Storage permission denied');
        }

        return false;
      }
    } else if (Platform.isIOS) {
      // For iOS, request photo library permission
      print('LocalLibraryService: iOS detected, requesting photo library permission');

      // Check if we already have the permission
      final currentStatus = await Permission.photos.status;
      if (currentStatus.isGranted) {
        print('LocalLibraryService: Photo library permission already granted');
        return true;
      }

      // Request photo library permission
      final status = await Permission.photos.request();
      print('LocalLibraryService: Photo library permission status: ${status.toString()}');

      if (status.isGranted) {
        print('LocalLibraryService: Photo library permission granted');
        return true;
      }

      // If permission is permanently denied, guide the user to app settings
      if (status.isPermanentlyDenied) {
        print('LocalLibraryService: Photo library permission permanently denied, opening app settings');
        await openAppSettings();

        // Check if permission was granted after returning from settings
        final updatedStatus = await Permission.photos.status;
        print('LocalLibraryService: Updated photo library permission status after settings: $updatedStatus');

        return updatedStatus.isGranted;
      } else {
        print('LocalLibraryService: Photo library permission denied');
      }

      return false;
    }

    return false;
  }
  /// Gets the Android SDK version.
  ///
  /// Returns 0 if not running on Android.
  Future<int> _getAndroidSdkVersion() async {
    if (!Platform.isAndroid) return 0;

    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.version.sdkInt;
  }

  /// Requests necessary storage permissions for mobile platforms.
  ///
  /// Returns `true` if permission is granted, otherwise `false`.
  Future<bool> _requestPermission() async {
    print('LocalLibraryService: Requesting storage permission...');

    // Simply call the more comprehensive requestAllPermissions method
    // This ensures consistent permission handling throughout the app
    return await requestAllPermissions();
  }

  /// Opens the platform's file picker to select one or more EPUB files.
  ///
  /// This method handles storage permissions and returns a list of selected [PickedFileData] objects.
  /// It returns an empty list if no files are selected or if permissions are denied.
  Future<List<PickedFileData>> pickFiles() async {
    print('LocalLibraryService: Starting file picker...');

    // First check if we have permissions
    bool hasPermission = await requestAllPermissions();
    if (!hasPermission) {
      print('LocalLibraryService: Permission denied, attempting one more time...');

      // Try one more time with a more direct approach
      if (Platform.isAndroid) {
        final sdkVersion = await _getAndroidSdkVersion();
        if (sdkVersion >= 33) {
          // For Android 13+, try with just the essential permissions
          print('LocalLibraryService: Trying with just essential permissions for Android 13+');
          Map<Permission, PermissionStatus> statuses = await [
            Permission.photos,
            Permission.audio,
            Permission.videos,
          ].request();

          hasPermission = statuses.values.any((status) => status.isGranted);
          print('LocalLibraryService: Essential permissions retry result: $hasPermission');
        } else {
          // For older Android versions, try storage permission again
          print('LocalLibraryService: Trying storage permission again for older Android');
          final status = await Permission.storage.request();
          hasPermission = status.isGranted;
          print('LocalLibraryService: Storage permission retry result: $hasPermission');
        }
      }

      if (!hasPermission) {
        print('LocalLibraryService: Permission still denied after retry, returning empty list');
        return [];
      }
    }

    try {
      print('LocalLibraryService: Permissions granted, opening file picker...');

      // Ask for the file bytes directly
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['epub'],
        withData: true, // This is crucial to get the file bytes directly
      );

      if (result == null) {
        print('LocalLibraryService: User cancelled file selection');
        return [];
      }

      print('LocalLibraryService: User selected ${result.files.length} files');

      final List<PickedFileData> pickedFiles = [];
      for (final file in result.files) {
        print('LocalLibraryService: Processing file: ${file.name}, path: ${file.path}, has bytes: ${file.bytes != null}');

        if (file.path != null) {
          if (file.bytes != null) {
            print('LocalLibraryService: Successfully read ${file.bytes!.lengthInBytes} bytes from ${file.name}');
            pickedFiles.add(PickedFileData(path: file.path!, bytes: file.bytes!));
          } else {
            // If bytes are null but we have a path, try to read the file directly
            print('LocalLibraryService: File bytes were null, trying to read file directly: ${file.path}');
            try {
              final bytes = await File(file.path!).readAsBytes();
              print('LocalLibraryService: Successfully read ${bytes.length} bytes directly from ${file.name}');
              pickedFiles.add(PickedFileData(path: file.path!, bytes: bytes));
            } catch (e) {
              print('LocalLibraryService: Error reading file directly: $e');
            }
          }
        } else {
          print('LocalLibraryService: Warning - picked file ${file.name} was missing path.');
        }
      }

      print('LocalLibraryService: Successfully processed ${pickedFiles.length} files');
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

    // First check if we have permissions
    bool hasPermission = await requestAllPermissions();
    if (!hasPermission) {
      print('LocalLibraryService: Permission denied for directory scan, attempting one more time...');

      // Try one more time with a more direct approach
      if (Platform.isAndroid) {
        final sdkVersion = await _getAndroidSdkVersion();
        if (sdkVersion >= 33) {
          // For Android 13+, try with just the essential permissions
          print('LocalLibraryService: Trying with just essential permissions for Android 13+');
          Map<Permission, PermissionStatus> statuses = await [
            Permission.photos,
            Permission.audio,
            Permission.videos,
          ].request();

          hasPermission = statuses.values.any((status) => status.isGranted);
          print('LocalLibraryService: Essential permissions retry result: $hasPermission');
        } else {
          // For older Android versions, try storage permission again
          print('LocalLibraryService: Trying storage permission again for older Android');
          final status = await Permission.storage.request();
          hasPermission = status.isGranted;
          print('LocalLibraryService: Storage permission retry result: $hasPermission');
        }
      }

      if (!hasPermission) {
        print('LocalLibraryService: Permission still denied after retry, returning empty list');
        return [];
      }
    }

    try {
      print('LocalLibraryService: Permissions granted, opening directory picker...');

      final directoryPath = await FilePicker.platform.getDirectoryPath();
      if (directoryPath == null) {
        print('LocalLibraryService: User cancelled directory selection');
        return [];
      }

      print('LocalLibraryService: User selected directory: $directoryPath');

      final dir = Directory(directoryPath);
      if (!await dir.exists()) {
        print('LocalLibraryService: Selected directory does not exist');
        return [];
      }

      print('LocalLibraryService: Starting recursive scan of directory...');

      final List<PickedFileData> pickedFiles = [];
      try {
        await for (final entity in dir.list(recursive: true)) {
          if (entity is File && entity.path.toLowerCase().endsWith('.epub')) {
            try {
              print('LocalLibraryService: Found EPUB file: ${entity.path}');
              final bytes = await entity.readAsBytes();
              pickedFiles.add(PickedFileData(path: entity.path, bytes: bytes));
              print('LocalLibraryService: Scanned and read ${bytes.lengthInBytes} bytes from ${entity.path}');
            } catch (e) {
              print('LocalLibraryService: Error reading scanned file ${entity.path}: $e');
            }
          }
        }
      } catch (e) {
        print('LocalLibraryService: Error during directory listing: $e');
        // Continue with any files we've already found
      }

      print('LocalLibraryService: Scan complete, found ${pickedFiles.length} EPUB files');
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

    // First check if we have permissions
    bool hasPermission = await requestAllPermissions();
    if (!hasPermission) {
      print('LocalLibraryService: Permission denied for audiobook picking, attempting one more time...');

      // Try one more time with a more direct approach
      if (Platform.isAndroid) {
        final sdkVersion = await _getAndroidSdkVersion();
        if (sdkVersion >= 33) {
          // For Android 13+, try with just the essential permissions
          print('LocalLibraryService: Trying with just essential permissions for Android 13+');
          Map<Permission, PermissionStatus> statuses = await [
            Permission.photos,
            Permission.audio,
            Permission.videos,
          ].request();

          hasPermission = statuses.values.any((status) => status.isGranted);
          print('LocalLibraryService: Essential permissions retry result: $hasPermission');
        } else {
          // For older Android versions, try storage permission again
          print('LocalLibraryService: Trying storage permission again for older Android');
          final status = await Permission.storage.request();
          hasPermission = status.isGranted;
          print('LocalLibraryService: Storage permission retry result: $hasPermission');
        }
      }

      if (!hasPermission) {
        print('LocalLibraryService: Permission still denied after retry, returning empty list');
        return [];
      }
    }

    try {
      print('LocalLibraryService: Permissions granted, opening audiobook picker...');

      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['mp3'], // Restrict to MP3 files
      );

      if (result == null) {
        print('LocalLibraryService: No audiobooks selected');
        return [];
      }

      print('LocalLibraryService: User selected ${result.files.length} audiobook files');

      final List<File> files = [];
      for (final file in result.files) {
        if (file.path != null) {
          print('LocalLibraryService: Processing audiobook: ${file.name}, path: ${file.path}');
          try {
            final audioFile = File(file.path!);
            if (await audioFile.exists()) {
              files.add(audioFile);
              print('LocalLibraryService: Successfully added audiobook: ${file.name}');
            } else {
              print('LocalLibraryService: Audiobook file does not exist: ${file.path}');
            }
          } catch (e) {
            print('LocalLibraryService: Error processing audiobook file: $e');
          }
        } else {
          print('LocalLibraryService: Warning - picked audiobook ${file.name} was missing path.');
        }
      }

      print('LocalLibraryService: Successfully processed ${files.length} audiobooks');
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

    // Check if we have permissions first
    bool hasPermission = await requestAllPermissions();
    if (!hasPermission) {
      print('LocalLibraryService: Permission denied for loading file, attempting one more time...');

      // Try one more time with a more direct approach
      if (Platform.isAndroid) {
        final sdkVersion = await _getAndroidSdkVersion();
        if (sdkVersion >= 33) {
          // For Android 13+, try with just the essential permissions
          print('LocalLibraryService: Trying with just essential permissions for Android 13+');
          Map<Permission, PermissionStatus> statuses = await [
            Permission.photos,
            Permission.audio,
            Permission.videos,
          ].request();

          hasPermission = statuses.values.any((status) => status.isGranted);
          print('LocalLibraryService: Essential permissions retry result: $hasPermission');
        } else {
          // For older Android versions, try storage permission again
          print('LocalLibraryService: Trying storage permission again for older Android');
          final status = await Permission.storage.request();
          hasPermission = status.isGranted;
          print('LocalLibraryService: Storage permission retry result: $hasPermission');
        }
      }

      if (!hasPermission) {
        print('LocalLibraryService: Permission still denied after retry, cannot load file');
        return null;
      }
    }

    try {
      print('LocalLibraryService: Permissions granted, attempting to load file: $filePath');

      final file = File(filePath);
      if (!await file.exists()) {
        print('LocalLibraryService: File does not exist at path: $filePath');
        return null;
      }

      print('LocalLibraryService: File exists, reading bytes...');

      try {
        final bytes = await file.readAsBytes();
        print('LocalLibraryService: Successfully read ${bytes.lengthInBytes} bytes from $filePath');
        return PickedFileData(path: filePath, bytes: bytes);
      } catch (e) {
        print('LocalLibraryService: Error reading file bytes: $e');

        // Try an alternative approach if the first one fails
        print('LocalLibraryService: Trying alternative approach to read file...');
        try {
          final randomAccessFile = await file.open(mode: FileMode.read);
          final fileSize = await randomAccessFile.length();
          final buffer = Uint8List(fileSize);
          await randomAccessFile.readInto(buffer);
          await randomAccessFile.close();

          print('LocalLibraryService: Successfully read ${buffer.lengthInBytes} bytes using alternative method');
          return PickedFileData(path: filePath, bytes: buffer);
        } catch (e2) {
          print('LocalLibraryService: Alternative method also failed: $e2');
          return null;
        }
      }
    } catch (e) {
      print('LocalLibraryService: Error loading file from path: $e');
      return null;
    }
  }
}
