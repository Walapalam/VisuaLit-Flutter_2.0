import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
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
    debugPrint("[DEBUG] LocalLibraryService: Requesting storage permission...");

    // Permissions are generally only required on mobile platforms.
    if (!Platform.isAndroid && !Platform.isIOS) {
      debugPrint("[DEBUG] LocalLibraryService: Running on desktop platform, skipping permission request");
      return true;
    }

    debugPrint("[DEBUG] LocalLibraryService: Running on mobile platform (${Platform.operatingSystem}), requesting storage permission");

    try {
      final status = await Permission.storage.request();
      debugPrint("[DEBUG] LocalLibraryService: Permission status: ${status.toString()}");

      if (status.isGranted) {
        debugPrint("[DEBUG] LocalLibraryService: Storage permission granted");
        return true;
      }

      // If permission is permanently denied, guide the user to app settings.
      if (status.isPermanentlyDenied) {
        debugPrint("[WARN] LocalLibraryService: Permission permanently denied, opening app settings");
        await openAppSettings();
      } else {
        debugPrint("[WARN] LocalLibraryService: Permission denied");
      }

      return false;
    } catch (e) {
      debugPrint("[ERROR] LocalLibraryService: Error requesting permission: $e");
      return false;
    }
  }

  /// Opens the platform's file picker to select one or more EPUB or PDF files.
  ///
  /// This method handles storage permissions and returns a list of selected [PickedFileData] objects.
  /// It returns an empty list if no files are selected or if permissions are denied.
  Future<List<PickedFileData>> pickFiles() async {
    debugPrint("[DEBUG] LocalLibraryService: Starting file picker...");

    if (!await _requestPermission()) {
      debugPrint("[WARN] LocalLibraryService: Permission denied, returning empty list");
      return [];
    }

    try {
      // Ask for the file bytes directly
      debugPrint("[DEBUG] LocalLibraryService: Opening file picker for EPUB and PDF files");
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['epub', 'pdf'],
        withData: true, // This is crucial to get the file bytes directly
      );

      if (result == null) {
        debugPrint("[DEBUG] LocalLibraryService: User cancelled file selection");
        return [];
      }

      debugPrint("[DEBUG] LocalLibraryService: User selected ${result.files.length} files");
      final List<PickedFileData> pickedFiles = [];
      int successCount = 0;
      int errorCount = 0;

      for (final file in result.files) {
        try {
          if (file.path != null && file.bytes != null) {
            debugPrint("[DEBUG] LocalLibraryService: Successfully read ${file.bytes!.lengthInBytes} bytes from ${file.name}");
            pickedFiles.add(PickedFileData(path: file.path!, bytes: file.bytes!));
            successCount++;
          } else {
            debugPrint("[WARN] LocalLibraryService: Picked file ${file.name} was missing path or data");
            errorCount++;
          }
        } catch (e) {
          debugPrint("[ERROR] LocalLibraryService: Error processing file ${file.name}: $e");
          errorCount++;
        }
      }

      debugPrint("[DEBUG] LocalLibraryService: Processed ${result.files.length} files: $successCount successful, $errorCount failed");
      return pickedFiles;

    } catch (e, stack) {
      debugPrint("[ERROR] LocalLibraryService: Error picking files: $e");
      debugPrintStack(stackTrace: stack);
      return [];
    }
  }


  /// Opens the platform's directory picker and scans for all EPUB and PDF files within.
  ///
  /// This method recursively finds all files with the '.epub' or '.pdf' extension
  /// in the selected directory and its subdirectories.
  Future<List<PickedFileData>> scanAndLoadBooks() async {
    debugPrint("[DEBUG] LocalLibraryService: Starting directory scan...");

    if (!await _requestPermission()) {
      debugPrint("[WARN] LocalLibraryService: Permission denied, returning empty list");
      return [];
    }

    try {
      debugPrint("[DEBUG] LocalLibraryService: Opening directory picker");
      final directoryPath = await FilePicker.platform.getDirectoryPath();
      if (directoryPath == null) {
        debugPrint("[DEBUG] LocalLibraryService: User cancelled directory selection");
        return [];
      }

      debugPrint("[DEBUG] LocalLibraryService: Selected directory: $directoryPath");
      final dir = Directory(directoryPath);
      if (!await dir.exists()) {
        debugPrint("[ERROR] LocalLibraryService: Selected directory does not exist");
        return [];
      }

      final List<PickedFileData> pickedFiles = [];
      int foundFiles = 0;
      int successCount = 0;
      int errorCount = 0;

      debugPrint("[DEBUG] LocalLibraryService: Starting recursive scan for EPUB and PDF files");
      await for (final entity in dir.list(recursive: true)) {
        final path = entity.path.toLowerCase();
        if (entity is File && (path.endsWith('.epub') || path.endsWith('.pdf'))) {
          foundFiles++;
          try {
            final bytes = await entity.readAsBytes();
            pickedFiles.add(PickedFileData(path: entity.path, bytes: bytes));
            debugPrint("[DEBUG] LocalLibraryService: Scanned and read ${bytes.lengthInBytes} bytes from ${entity.path}");
            successCount++;
          } catch (e) {
            debugPrint("[ERROR] LocalLibraryService: Error reading scanned file ${entity.path}: $e");
            errorCount++;
          }
        }
      }

      debugPrint("[DEBUG] LocalLibraryService: Directory scan complete. Found $foundFiles files: $successCount successful, $errorCount failed");
      return pickedFiles;

    } catch(e, stack) {
      debugPrint("[ERROR] LocalLibraryService: Error scanning directory: $e");
      debugPrintStack(stackTrace: stack);
      return [];
    }
  }

  // Audiobook picker method removed
}
