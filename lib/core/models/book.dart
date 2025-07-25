// lib/core/models/book.dart
enum BookType { epub, pdf, audio }

class Book {
  // TO-DO : No ISBN in the book model, required for book lookup
  final String id;
  final String filePath;
  final String title;
  final String? author;
  final String? coverImageUrl;
  final BookType bookType;

  Book({
    required this.id,
    required this.filePath,
    required this.title,
    this.author,
    this.coverImageUrl,
    required this.bookType,
  });
}