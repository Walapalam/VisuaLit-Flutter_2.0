import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';
import 'package:isar/isar.dart';
import 'package:visualit/features/reader/data/book_data.dart' as db;
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/features/reader/presentation/custom_reading_screen.dart';

class EpubViewerService {
  static Future<void> openBookWithCustomUI(
      db.Book book,
      BuildContext context
      ) async {
    // Navigate to custom reading screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CustomReadingScreen(book: book),
      ),
    );
  }

  static Future<void> openBook(db.Book book, {BuildContext? context}) async {
    if (book.epubFilePath.isEmpty) {
      throw Exception('Book file path is empty');
    }

    // Check if file exists
    final file = File(book.epubFilePath);
    if (!await file.exists()) {
      throw Exception('Book file not found at: ${book.epubFilePath}');
    }

    try {
      // Determine theme settings
      bool isDarkMode = false;
      Color themeColor = AppTheme.primaryGreen;

      if (context != null) {
        isDarkMode = Theme.of(context).brightness == Brightness.dark;
        themeColor = Theme.of(context).colorScheme.secondary;
      }

      // Configure the epub viewer with theme
      VocsyEpub.setConfig(
        themeColor: themeColor,
        identifier: "book_${book.id}",
        scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
        allowSharing: true,
        enableTts: true,
        nightMode: isDarkMode,
      );

      // Get last read location if available
      EpubLocator? lastLocation;
      if (book.lastReadLocator != null && book.lastReadLocator!.isNotEmpty) {
        try {
          lastLocation = EpubLocator.fromJson(jsonDecode(book.lastReadLocator!));
        } catch (e) {
          print('Error parsing saved locator: $e');
          // If parsing fails, start from beginning
          lastLocation = null;
        }
      }

      // Open the epub file
      VocsyEpub.open(
        book.epubFilePath,
        lastLocation: lastLocation, // Will open first page if null
      );

      // Update last accessed timestamp
      await _updateLastAccessed(book);

      // Listen for location changes to save reading progress
      _setupLocationListener(book);
    } catch (e) {
      throw Exception('Failed to open epub viewer: $e');
    }
  }

  static void _setupLocationListener(db.Book book) {
    VocsyEpub.locatorStream.listen(
          (locatorString) {
        try {
          if (locatorString.isNotEmpty) {
            // Save the entire locator JSON string
            _saveReadingProgress(book, locatorString);
          }
        } catch (e) {
          print('Error processing locator: $e');
        }
      },
      onError: (error) {
        print('Error in locator stream: $error');
      },
    );
  }

  static Future<void> _updateLastAccessed(db.Book book) async {
    try {
      final isar = Isar.getInstance();
      if (isar != null) {
        await isar.writeTxn(() async {
          book.lastAccessedAt = DateTime.now();
          await isar.books.put(book);
        });
      }
    } catch (e) {
      print('Error updating last accessed: $e');
    }
  }

  static Future<void> _saveReadingProgress(db.Book book, String locatorJson) async {
    try {
      final isar = Isar.getInstance();
      if (isar != null) {
        await isar.writeTxn(() async {
          book.lastReadTimestamp = DateTime.now();
          book.lastReadLocator = locatorJson; // Save the entire JSON string
          await isar.books.put(book);
        });
      }
    } catch (e) {
      print('Error saving reading progress: $e');
    }
  }
}