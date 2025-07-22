// lib/core/models/book.dart
import 'package:flutter/widgets.dart';

enum BookType { epub, pdf, audio }

class Book {
  final String id;
  final String filePath;
  final String title;
  final String? author;
  final String? coverImageUrl;
  final BookType bookType;
  final Map<String, Image> images;
  final List<Chapter> chapters;

  Book({
    required this.id,
    required this.filePath,
    required this.title,
    this.author,
    this.coverImageUrl,
    required this.bookType,
    this.images = const {},
    this.chapters = const [],
  });
}

class Chapter {
  final String title;
  final String content;

  Chapter({
    required this.title,
    required this.content,
  });
}