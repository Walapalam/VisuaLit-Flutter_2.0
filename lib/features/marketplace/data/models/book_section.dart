// lib/features/marketplace/data/models/book_section.dart
class BookSection {
  final String title;
  final String apiEndpoint;
  final List<dynamic> books;
  final bool isLoading;
  final String? error;
  final String? nextUrl;

  BookSection({
    required this.title,
    required this.apiEndpoint,
    this.books = const [],
    this.isLoading = false,
    this.error,
    this.nextUrl,
  });

  BookSection copyWith({
    String? title,
    String? apiEndpoint,
    List<dynamic>? books,
    bool? isLoading,
    String? error,
    String? nextUrl,
  }) {
    return BookSection(
      title: title ?? this.title,
      apiEndpoint: apiEndpoint ?? this.apiEndpoint,
      books: books ?? this.books,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      nextUrl: nextUrl ?? this.nextUrl,
    );
  }
}
