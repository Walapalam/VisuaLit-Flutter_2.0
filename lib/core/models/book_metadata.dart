// lib/core/models/book_metadata.dart
import 'package:flutter/widgets.dart';

class BookMetadata {
  final String title;
  final List<String> authors;
  final String filePath;
  final Image? coverImage;

  BookMetadata({
    required this.title,
    required this.authors,
    required this.filePath,
    this.coverImage,
  });
}