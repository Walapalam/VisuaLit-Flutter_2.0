import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:visualit/core/services/isar_service.dart';
import 'package:visualit/features/library/data/local_library_service.dart';
import 'package:visualit/features/library/presentation/library_controller.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/data/chapter_content.dart';
import 'package:visualit/features/reader/data/toc_entry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:archive/archive.dart';

// Generate mocks
@GenerateMocks([IsarService, LocalLibraryService, Isar])
import 'book_processing_test.mocks.dart';

// Mock Isar collection for testing
class _MockIsarCollection<T> extends Mock implements IsarCollection<T> {
  final List<T> _items = [];

  @override
  Future<int> put(T object) async {
    _items.add(object);
    return _items.length; // Return a fake ID
  }

  @override
  Future<List<int>> putAll(List<T> objects) async {
    _items.addAll(objects);
    return List.generate(objects.length, (i) => _items.length - objects.length + i + 1);
  }

  @override
  Future<T?> get(int id) async {
    if (id <= 0 || id > _items.length) return null;
    return _items[id - 1];
  }

  @override
  QueryBuilder<T, T, QWhere> where({bool distinct = false}) {
    return _MockQueryBuilder<T>(_items);
  }
}

// Mock query builder for testing
class _MockQueryBuilder<T> extends Mock implements QueryBuilder<T, T, QWhere> {
  final List<T> _items;

  _MockQueryBuilder(this._items);

  @override
  Future<List<T>> findAll() async {
    return _items;
  }

  @override
  Future<T?> findFirst() async {
    if (_items.isEmpty) return null;
    return _items.first;
  }
}

void main() {
  late MockIsarService mockIsarService;
  late MockLocalLibraryService mockLocalLibraryService;
  late MockIsar mockIsar;
  late LibraryController libraryController;

  setUp(() async {
    // Initialize mocks
    mockIsarService = MockIsarService();
    mockLocalLibraryService = MockLocalLibraryService();
    mockIsar = MockIsar();

    // Set up mock behavior for Isar
    // Mock books collection
    final mockBooksCollection = _MockIsarCollection<Book>();
    when(mockIsar.books).thenReturn(mockBooksCollection);

    // Mock chapterContents collection
    final mockChapterContentsCollection = _MockIsarCollection<ChapterContent>();
    when(mockIsar.chapterContents).thenReturn(mockChapterContentsCollection);

    // Mock writeTxn to execute the callback
    when(mockIsar.writeTxn<dynamic>(any)).thenAnswer((invocation) async {
      final callback = invocation.positionalArguments[0] as Future<dynamic> Function();
      return await callback();
    });

    // Create the library controller with mocked dependencies
    libraryController = LibraryController(mockLocalLibraryService, mockIsar);
  });

  tearDown(() async {
    // No need to close the mock database
  });

  group('Book Processing Tests', () {
    test('Book is parsed correctly', () async {
      // Create test data - a minimal EPUB file structure as bytes
      final testEpubBytes = _createTestEpubBytes();

      // Mock the file picking process
      when(mockLocalLibraryService.pickFiles()).thenAnswer((_) async {
        return [
          PickedFileData(
            path: '/test/path/test_book.epub',
            bytes: testEpubBytes,
          ),
        ];
      });

      // Process the test file
      await libraryController.pickAndProcessBooks();

      // Verify a book was created in the database
      final books = await mockIsar.books.where().findAll();
      expect(books.length, 1, reason: 'One book should be added to the database');

      // Verify book metadata was parsed correctly
      final book = books.first;
      expect(book.title, 'Test Book', reason: 'Book title should be parsed correctly');
      expect(book.author, 'Test Author', reason: 'Book author should be parsed correctly');
      expect(book.status, ProcessingStatus.ready, reason: 'Book status should be ready');

      // Verify TOC was parsed correctly
      expect(book.toc.length, 2, reason: 'Book should have 2 TOC entries');
      expect(book.toc[0].title, 'Chapter 1', reason: 'First TOC entry title should be correct');
      expect(book.toc[1].title, 'Chapter 2', reason: 'Second TOC entry title should be correct');

      // Verify chapters were stored correctly
      final chapters = await mockIsar.chapterContents.where().findAll();
      expect(chapters.length, 2, reason: 'Two chapters should be stored');

      // Verify chapter content
      final chapter1 = chapters.firstWhere((c) => c.title == 'Chapter 1');
      expect(chapter1.htmlContent, contains('<h1>Chapter 1</h1>'), 
        reason: 'Chapter HTML content should be stored correctly');
      expect(chapter1.textContent, contains('Chapter 1'), 
        reason: 'Chapter text content should be stored correctly');
    });

    test('Book is stored correctly in database', () async {
      // Create and store a test book directly
      final testBook = Book()
        ..epubFilePath = '/test/path/direct_test_book.epub'
        ..title = 'Direct Test Book'
        ..author = 'Direct Test Author'
        ..status = ProcessingStatus.ready
        ..toc = [
          TOCEntry()
            ..title = 'Direct Chapter 1'
            ..src = 'chapter1.html',
          TOCEntry()
            ..title = 'Direct Chapter 2'
            ..src = 'chapter2.html',
        ];

      // Store the book
      final bookId = await mockIsar.writeTxn(() async {
        return await mockIsar.books.put(testBook);
      });

      // Create and store test chapters
      final chapter1 = ChapterContent(
        title: 'Direct Chapter 1',
        src: 'chapter1.html',
        htmlContent: '<h1>Direct Chapter 1</h1><p>This is direct test content.</p>',
        textContent: 'Direct Chapter 1 This is direct test content.',
        bookId: bookId,
      );

      final chapter2 = ChapterContent(
        title: 'Direct Chapter 2',
        src: 'chapter2.html',
        htmlContent: '<h1>Direct Chapter 2</h1><p>More direct test content.</p>',
        textContent: 'Direct Chapter 2 More direct test content.',
        bookId: bookId,
      );

      // Store the chapters
      await mockIsar.writeTxn(() async {
        await mockIsar.chapterContents.putAll([chapter1, chapter2]);
      });

      // Retrieve the book and verify it was stored correctly
      final storedBook = await mockIsar.books.get(bookId);
      expect(storedBook, isNotNull, reason: 'Book should be retrieved from database');
      expect(storedBook!.title, 'Direct Test Book', reason: 'Book title should be stored correctly');
      expect(storedBook.author, 'Direct Test Author', reason: 'Book author should be stored correctly');
      expect(storedBook.toc.length, 2, reason: 'Book should have 2 TOC entries');

      // Retrieve the chapters and verify they were stored correctly
      final storedChapters = await mockIsar.chapterContents.where()
        .bookIdEqualTo(bookId)
        .findAll();
      expect(storedChapters.length, 2, reason: 'Two chapters should be stored');

      // Verify chapter content was stored correctly
      final storedChapter1 = storedChapters.firstWhere((c) => c.title == 'Direct Chapter 1');
      expect(storedChapter1.htmlContent, contains('<h1>Direct Chapter 1</h1>'), 
        reason: 'Chapter HTML content should be stored correctly');
      expect(storedChapter1.textContent, contains('Direct Chapter 1'), 
        reason: 'Chapter text content should be stored correctly');
    });

    // This test would normally use a widget test to verify display,
    // but we'll use a simpler approach for this example
    test('Book content is output correctly', () async {
      // Create a test book with known content
      final testBook = Book()
        ..epubFilePath = '/test/path/output_test_book.epub'
        ..title = 'Output Test Book'
        ..author = 'Output Test Author'
        ..status = ProcessingStatus.ready;

      // Store the book
      final bookId = await mockIsar.writeTxn(() async {
        return await mockIsar.books.put(testBook);
      });

      // Create a test chapter with specific HTML content
      final testChapter = ChapterContent(
        title: 'Output Test Chapter',
        src: 'chapter.html',
        htmlContent: '<h1>Output Test Chapter</h1><p>This is <strong>formatted</strong> content.</p>',
        textContent: 'Output Test Chapter This is formatted content.',
        bookId: bookId,
      );

      // Store the chapter
      await mockIsar.writeTxn(() async {
        await mockIsar.chapterContents.put(testChapter);
      });

      // Retrieve the chapter and verify its content
      final storedChapter = await mockIsar.chapterContents.where()
        .bookIdEqualTo(bookId)
        .findFirst();

      expect(storedChapter, isNotNull, reason: 'Chapter should be retrieved from database');
      expect(storedChapter!.htmlContent, contains('<strong>formatted</strong>'), 
        reason: 'HTML formatting should be preserved');
      expect(storedChapter.textContent, contains('formatted'), 
        reason: 'Text content should be extracted correctly');

      // In a real test, we would render this content in a widget and verify the display
      // For this example, we'll just verify the content is available for rendering
    });
  });
}

// Helper function to create test EPUB bytes
Uint8List _createTestEpubBytes() {
  // Create a minimal valid EPUB file structure
  // This is a simplified version that contains just enough for the parser to work

  // Create container.xml
  final containerXml = '''<?xml version="1.0" encoding="UTF-8"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
  <rootfiles>
    <rootfile full-path="content.opf" media-type="application/oebps-package+xml"/>
  </rootfiles>
</container>''';

  // Create content.opf with metadata, manifest and spine
  final contentOpf = '''<?xml version="1.0" encoding="UTF-8"?>
<package xmlns="http://www.idpf.org/2007/opf" version="3.0" unique-identifier="uid">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
    <dc:title>Test Book</dc:title>
    <dc:creator>Test Author</dc:creator>
    <dc:identifier id="uid">test-book-id</dc:identifier>
    <dc:language>en</dc:language>
    <dc:publisher>Test Publisher</dc:publisher>
    <dc:date>2023-01-01</dc:date>
    <meta name="cover" content="cover-image"/>
  </metadata>
  <manifest>
    <item id="chapter1" href="chapter1.xhtml" media-type="application/xhtml+xml"/>
    <item id="chapter2" href="chapter2.xhtml" media-type="application/xhtml+xml"/>
    <item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" properties="nav"/>
    <item id="css" href="style.css" media-type="text/css"/>
    <item id="cover-image" href="cover.jpg" media-type="image/jpeg" properties="cover-image"/>
    <item id="image1" href="image1.jpg" media-type="image/jpeg"/>
  </manifest>
  <spine>
    <itemref idref="chapter1"/>
    <itemref idref="chapter2"/>
  </spine>
</package>''';

  // Create chapter1.xhtml
  final chapter1 = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <title>Chapter 1</title>
  <link rel="stylesheet" type="text/css" href="style.css"/>
</head>
<body>
  <h1>Chapter 1</h1>
  <p>This is the content of chapter 1.</p>
  <p>It contains <strong>formatted</strong> text.</p>
  <img src="image1.jpg" alt="Test Image"/>
</body>
</html>''';

  // Create chapter2.xhtml
  final chapter2 = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <title>Chapter 2</title>
  <link rel="stylesheet" type="text/css" href="style.css"/>
</head>
<body>
  <h1>Chapter 2</h1>
  <p>This is the content of chapter 2.</p>
  <p>It also contains <em>formatted</em> text.</p>
</body>
</html>''';

  // Create nav.xhtml (TOC)
  final navXhtml = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops">
<head>
  <title>Table of Contents</title>
</head>
<body>
  <nav epub:type="toc">
    <h1>Table of Contents</h1>
    <ol>
      <li><a href="chapter1.xhtml">Chapter 1</a></li>
      <li><a href="chapter2.xhtml">Chapter 2</a></li>
    </ol>
  </nav>
</body>
</html>''';

  // Create style.css
  final styleCss = '''
body {
  font-family: Arial, sans-serif;
  margin: 2em;
}
h1 {
  color: #333;
  font-size: 1.5em;
}
p {
  line-height: 1.5;
}
''';

  // Create dummy image data
  final coverImageBytes = Uint8List.fromList(List.generate(100, (i) => i % 256));
  final image1Bytes = Uint8List.fromList(List.generate(100, (i) => (i + 50) % 256));

  // Create a ZIP archive (EPUB is a ZIP file with specific structure)
  final archive = Archive();

  // Add files to the archive
  archive.addFile(ArchiveFile('META-INF/container.xml', containerXml.length, containerXml.codeUnits));
  archive.addFile(ArchiveFile('content.opf', contentOpf.length, contentOpf.codeUnits));
  archive.addFile(ArchiveFile('chapter1.xhtml', chapter1.length, chapter1.codeUnits));
  archive.addFile(ArchiveFile('chapter2.xhtml', chapter2.length, chapter2.codeUnits));
  archive.addFile(ArchiveFile('nav.xhtml', navXhtml.length, navXhtml.codeUnits));
  archive.addFile(ArchiveFile('style.css', styleCss.length, styleCss.codeUnits));
  archive.addFile(ArchiveFile('cover.jpg', coverImageBytes.length, coverImageBytes));
  archive.addFile(ArchiveFile('image1.jpg', image1Bytes.length, image1Bytes));

  // Create the META-INF directory if it doesn't exist in the archive
  if (archive.findFile('META-INF/') == null) {
    archive.addFile(ArchiveFile('META-INF/', 0, []));
  }

  // Convert the archive to bytes
  final zipEncoder = ZipEncoder();
  final epubBytes = zipEncoder.encode(archive);

  // Convert List<int> to Uint8List
  if (epubBytes != null) {
    return Uint8List.fromList(epubBytes);
  } else {
    return Uint8List(0);
  }
}
