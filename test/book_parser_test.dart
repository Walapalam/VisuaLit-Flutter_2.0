import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/data/toc_entry.dart';
import 'package:visualit/features/reader/data/chapter_content.dart';
import 'package:visualit/features/reader/data/book_image.dart';
import 'package:visualit/features/reader/data/book_styling.dart';

void main() {
  group('Book Parser Tests', () {
    test('Book model stores data correctly', () {
      // Create a test book with metadata
      final book = Book()
        ..epubFilePath = '/test/path/test_book.epub'
        ..title = 'Test Book'
        ..author = 'Test Author'
        ..publisher = 'Test Publisher'
        ..language = 'en'
        ..publicationDate = DateTime(2023, 1, 1)
        ..isbn = '1234567890'
        ..status = ProcessingStatus.ready;

      // Create TOC entries
      final tocEntry1 = TOCEntry()
        ..title = 'Chapter 1'
        ..src = 'chapter1.xhtml';

      final tocEntry2 = TOCEntry()
        ..title = 'Chapter 2'
        ..src = 'chapter2.xhtml';

      book.toc = [tocEntry1, tocEntry2];

      // Create test images
      final coverImageBytes = Uint8List.fromList(List.generate(100, (i) => i % 256));
      book.coverImageBytes = coverImageBytes;

      final image1 = BookImage(
        src: 'image1.jpg',
        name: 'image1.jpg',
        mimeType: 'image/jpeg',
        imageBytes: Uint8List.fromList(List.generate(100, (i) => (i + 50) % 256)),
      );

      book.images = [image1];

      // Create test styling
      final styleSheet = StyleSheet(
        href: 'style.css',
        content: '''
          body { font-family: Arial, sans-serif; margin: 2em; }
          h1 { color: #333; font-size: 1.5em; }
          p { line-height: 1.5; }
        ''',
      );

      book.styling = BookStyling(styleSheets: [styleSheet]);

      // Verify the book data is stored correctly
      expect(book.title, 'Test Book', reason: 'Book title should be stored correctly');
      expect(book.author, 'Test Author', reason: 'Book author should be stored correctly');
      expect(book.publisher, 'Test Publisher', reason: 'Book publisher should be stored correctly');
      expect(book.language, 'en', reason: 'Book language should be stored correctly');

      // Verify TOC
      expect(book.toc.length, 2, reason: 'Book should have 2 TOC entries');
      expect(book.toc[0].title, 'Chapter 1', reason: 'First TOC entry title should be correct');
      expect(book.toc[1].title, 'Chapter 2', reason: 'Second TOC entry title should be correct');

      // Verify images
      expect(book.coverImageBytes, isNotNull, reason: 'Book should have cover image');
      expect(book.images.length, 1, reason: 'Book should have 1 content image');
      expect(book.images[0].name, 'image1.jpg', reason: 'Image name should be correct');

      // Verify styling
      expect(book.styling?.styleSheets.length, 1, reason: 'Book should have 1 stylesheet');
      expect(book.styling?.styleSheets[0].content, contains('font-family'), 
        reason: 'Stylesheet content should be stored correctly');
    });

    test('Book content is output correctly', () {
      // Create a book with known content
      final book = Book()
        ..title = 'Output Test Book'
        ..author = 'Output Test Author';

      // Create a chapter with specific HTML content
      final chapter = ChapterContent(
        title: 'Output Test Chapter',
        src: 'chapter.html',
        htmlContent: '<h1>Output Test Chapter</h1><p>This is <strong>formatted</strong> content.</p>',
        textContent: 'Output Test Chapter This is formatted content.',
      );

      // Verify the content is correct
      expect(chapter.htmlContent, contains('<strong>formatted</strong>'), 
        reason: 'HTML formatting should be preserved');
      expect(chapter.textContent, contains('formatted'), 
        reason: 'Text content should be extracted correctly');

      // In a real application, we would render this content in a widget and verify the display
      // For this test, we're just verifying that the content is available for rendering
    });
  });
}
