import 'package:visualit/features/reader/data/book_data.dart';

/// Interface for book processing service.
/// 
/// This interface defines the contract for services that process book files
/// (e.g., EPUB) and extract content for rendering and searching.
abstract class IBookProcessor {
  /// Processes a book file in an isolate.
  /// 
  /// This method should handle the extraction of content from the book file,
  /// parsing of chapters, and storage of content blocks in the database.
  /// 
  /// [filePath] is the path to the book file to process.
  static Future<void> launchIsolate(String filePath) async {
    throw UnimplementedError('Subclasses must implement launchIsolate');
  }
  
  /// Processes a book synchronously.
  /// 
  /// This method can be used for immediate processing of a book
  /// without launching an isolate.
  /// 
  /// [book] is the book to process.
  Future<void> processBook(Book book);
}