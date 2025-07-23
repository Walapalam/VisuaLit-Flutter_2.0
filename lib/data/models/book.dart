class Book {
  final String id;
  final String isbn;
  final String title;
  final String? author;
  final String characterPersonas; // Storing as String, assuming it's JSON
//This is a simplified model for a book in a library system.
  Book({
    required this.id,
    required this.isbn,
    required this.title,
    this.author,
    required this.characterPersonas,
  });
//this is a factory constructor to create a Book instance from a JSON map.
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['\$id'] as String,
      isbn: json['isbn'] as String,
      title: json['title'] as String,
      author: json['author'] as String?,
      characterPersonas: json['character_personas'] as String,
    );
  }
}