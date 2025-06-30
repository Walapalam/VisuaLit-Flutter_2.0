// lib/features/library/data/local_library_service.dart
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:epubx/epubx.dart';
import 'package:visualit/core/models/book.dart';

class LocalLibraryService {
  /// Requests storage permission. Returns true if granted.
  Future<bool> requestStoragePermission() async {
    // On modern Android, we request specific media permissions.
    // Permission.storage is largely ignored.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.audio,
      Permission.photos,
      Permission.videos,
    ].request();

    // We consider permission granted if any of the media types are allowed,
    // as the user might only have books in one category.
    bool isGranted = statuses.values.any((status) => status.isGranted || status.isLimited);

    if (!isGranted) {
      // If permission is permanently denied, it's good practice to guide the user
      // to the app settings.
      if (statuses.values.any((status) => status.isPermanentlyDenied)) {
        openAppSettings();
      }
    }

    return isGranted;
  }

  Future<List<Book>> pickAndLoadBooks() async {
    if (!await requestStoragePermission()) {

      return [];
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['epub', 'pdf', 'mp3', 'wav'],
    );
    if (result == null) return [];

    final files = result.paths.whereType<String>().map((path) => File(path)).toList();

    List<Book> books = [];
    for (final file in files) {
      final ext = file.path.split('.').last.toLowerCase();
      if (ext == 'epub') {
        try {
          final epubBook = await EpubReader.readBook(await file.readAsBytes());
          books.add(Book(
            id: file.path,
            filePath: file.path,
            title: epubBook.Title ?? _fileName(file),
            author: epubBook.Author ?? 'Unknown',
            coverImageUrl: null,
            bookType: BookType.epub,
          ));
        } catch (_) {
          books.add(Book(
            id: file.path,
            filePath: file.path,
            title: _fileName(file),
            author: 'Unknown',
            coverImageUrl: null,
            bookType: BookType.epub,
          ));
        }
      } else if (ext == 'pdf') {
        books.add(Book(
          id: file.path,
          filePath: file.path,
          title: _fileName(file),
          author: 'Unknown',
          coverImageUrl: null,
          bookType: BookType.pdf,
        ));
      } else if (ext == 'mp3' || ext == 'wav') {
        books.add(Book(
          id: file.path,
          filePath: file.path,
          title: _fileName(file),
          author: 'Unknown',
          coverImageUrl: null,
          bookType: BookType.audio,
        ));
      }
    }
    return books;
  }

  /// Scans the device for books (.epub, .pdf, .mp3, .wav).
  Future<List<Book>> scanDeviceForBooks() async {
    if (!await requestStoragePermission()) {
      return [];
    }

    String? directoryPath = await FilePicker.platform.getDirectoryPath();
    if (directoryPath == null) return [];

    final dir = Directory(directoryPath);
    final files = dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) =>
    f.path.endsWith('.epub') ||
        f.path.endsWith('.pdf') ||
        f.path.endsWith('.mp3') ||
        f.path.endsWith('.wav'))
        .toList();

    List<Book> books = [];
    for (final file in files) {
      final ext = file.path.split('.').last.toLowerCase();
      if (ext == 'epub') {
        try {
          final epubBook = await EpubReader.readBook(await file.readAsBytes());
          books.add(Book(
            id: file.path,
            filePath: file.path,
            title: epubBook.Title ?? _fileName(file),
            author: epubBook.Author ?? 'Unknown',
            coverImageUrl: null, // You can extract cover as bytes if needed
            bookType: BookType.epub,
          ));
        } catch (_) {
          // Fallback if parsing fails
          books.add(Book(
            id: file.path,
            filePath: file.path,
            title: _fileName(file),
            author: 'Unknown',
            coverImageUrl: null,
            bookType: BookType.epub,
          ));
        }
      } else if (ext == 'pdf') {
        books.add(Book(
          id: file.path,
          filePath: file.path,
          title: _fileName(file),
          author: 'Unknown',
          coverImageUrl: null,
          bookType: BookType.pdf,
        ));
      } else if (ext == 'mp3' || ext == 'wav') {
        books.add(Book(
          id: file.path,
          filePath: file.path,
          title: _fileName(file),
          author: 'Unknown',
          coverImageUrl: null,
          bookType: BookType.audio,
        ));
      }
    }
    return books;
  }

  /// Placeholder: Save books to local cache (e.g., Hive/Isar).
  Future<void> cacheBooks(List<Book> books) async {
    // TODO: Implement with Hive/Isar
  }

  /// Placeholder: Load books from local cache (e.g., Hive/Isar).
  Future<List<Book>> loadBooksFromCache() async {
    // TODO: Implement with Hive/Isar
    return [];
  }

  String _fileName(File file) => file.uri.pathSegments.last.split('.').first;
}