// lib/core/services/epub_service.dart
import 'dart:io';
import 'package:epubx/epubx.dart';
import '../models/book.dart';

class EpubService {
  Future<Book> loadBook(String filePath) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final epubBook = await EpubReader.readBook(bytes);

      final chapters = epubBook.Chapters?.map((chapter) => Chapter(
        title: chapter.Title ?? 'Untitled',
        content: chapter.HtmlContent ?? '',
      )).toList() ?? [];

      return Book(
        id: filePath,
        filePath: filePath,
        title: epubBook.Title ?? 'Unknown',
        author: epubBook.Author,
        bookType: BookType.epub,
        chapters: chapters,
        images: {}, // Add image parsing logic if needed
      );
    } catch (e) {
      throw Exception('Failed to load book: $e');
    }
  }
}