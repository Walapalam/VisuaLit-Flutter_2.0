import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:visualit/core/api/appwrite_client.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/data/book_data.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final databases = ref.read(appwriteDatabasesProvider);
  final isar = ref.watch(isarDBProvider).requireValue;
  return SyncService(databases: databases, isar: isar);
});

class SyncService {
  final appwrite.Databases _databases;
  final Isar _isar;
  final String _databaseId = dotenv.env['APPWRITE_DATABASE_ID']!;

  SyncService({required appwrite.Databases databases, required Isar isar})
      : _databases = databases,
        _isar = isar;

  Future<void> syncCloudToLocal(String userId) async {
    // Fetch data from Appwrite
    final userLibrary = await _databases.listDocuments(
      databaseId: _databaseId,
      collectionId: 'UserLibrary',
      queries: [appwrite.Query.equal('userId', userId)],
    );

    final readingProgress = await _databases.listDocuments(
      databaseId: _databaseId,
      collectionId: 'ReadingProgress',
      queries: [appwrite.Query.equal('userId', userId)],
    );

    // Perform a write transaction in Isar
    await _isar.writeTxn(() async {
      // Clear existing local data for the user
      await _isar.books.where().deleteAll();

      // Insert new records into Isar
      for (final bookDoc in userLibrary.documents) {
        final bookId = bookDoc.data['bookId'];
        final bookDetails = await _databases.getDocument(
          databaseId: _databaseId,
          collectionId: 'Books',
          documentId: bookId,
        );

        final newBook = Book()
          ..epubFilePath = bookDetails.data['bookFile_fileId']
          ..title = bookDetails.data['title']
          ..author = bookDetails.data['author']
          ..coverImageBytes = null;

        await _isar.books.put(newBook);
      }

      for (final progressDoc in readingProgress.documents) {
        final book = await _isar.books.get(progressDoc.data['bookId']);
        if (book != null) {
          book.lastReadPage =
              (progressDoc.data['progress_percentage'] * 100).toInt();
          await _isar.books.put(book);
        }
      }
    });
  }

  Future<void> syncLocalToCloud(String userId) async {
    // Read all records from the local Isar database
    final localBooks = await _isar.books.where().findAll();

    // Perform "update" or "create" operations in Appwrite
    for (final book in localBooks) {
      // Example: Update reading progress
      final progressDocs = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: 'ReadingProgress',
        queries: [
          appwrite.Query.equal('userId', userId),
          appwrite.Query.equal('bookId', book.id.toString()),
        ],
      );

      if (progressDocs.documents.isNotEmpty) {
        // Update existing progress
        await _databases.updateDocument(
          databaseId: _databaseId,
          collectionId: 'ReadingProgress',
          documentId: progressDocs.documents.first.$id,
          data: {
            'last_locator': 'TODO',
            'progress_percentage': book.lastReadPage / 100.0,
          },
        );
      } else {
        // Create new progress record
        await _databases.createDocument(
          databaseId: _databaseId,
          collectionId: 'ReadingProgress',
          documentId: appwrite.ID.unique(),
          data: {
            'userId': userId,
            'bookId': book.id.toString(),
            'last_locator': 'TODO',
            'progress_percentage': book.lastReadPage / 100.0,
          },
        );
      }
    }
  }
}