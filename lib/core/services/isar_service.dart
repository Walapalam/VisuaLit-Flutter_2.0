import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/audiobook_player/data/audiobook.dart';
import 'package:visualit/features/reader/data/highlight.dart'; // Import new schema

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<void> closeDB() async {
    final isar = await db;
    await isar.close();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [
          BookSchema,
          ContentBlockSchema,
          AudiobookSchema,
          HighlightSchema // Add the new schema here
        ],
        directory: dir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }

  Future<void> clearDB() async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.clear();
    });
  }

  // Watch all books in the database
  Stream<List<Book>> watchAllBooks() async* {
    final isar = await db;
    yield* isar.books.where().watch(fireImmediately: true);
  }

  // Add a book to the database
  Future<int> addBook(Book book) async {
    final isar = await db;
    return await isar.writeTxn(() async {
      return await isar.books.put(book);
    });
  }

  // Get all highlights for a specific book
  Future<List<Highlight>> getHighlightsForBook(int bookId) async {
    final isar = await db;
    return await isar.highlights.filter().bookIdEqualTo(bookId).findAll();
  }

  // Save a highlight to the database
  Future<int> saveHighlight(Highlight highlight) async {
    final isar = await db;
    return await isar.writeTxn(() async {
      return await isar.highlights.put(highlight);
    });
  }

  // Update a book's reading progress
  Future<void> updateBookProgress(int bookId, int lastReadPage) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final book = await isar.books.get(bookId);
      if (book != null) {
        book.lastReadPage = lastReadPage;
        book.lastReadTimestamp = DateTime.now();
        await isar.books.put(book);
      }
    });
  }
}
