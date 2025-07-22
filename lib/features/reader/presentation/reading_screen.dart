import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/models/book_schema.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/presentation/widgets/page_turn_widget.dart';

/// The main screen for reading a book.
class ReadingScreen extends ConsumerStatefulWidget {
  /// The ID of the book to read.
  final int bookId;
  
  /// Constructor
  const ReadingScreen({
    Key? key,
    required this.bookId,
  }) : super(key: key);
  
  @override
  ConsumerState<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends ConsumerState<ReadingScreen> {
  /// The book being read.
  BookSchema? _book;
  
  /// Flag to indicate if the book is loading.
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadBook();
  }
  
  /// Load the book from the database.
  Future<void> _loadBook() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final isar = await ref.read(isarProvider).db;
      final book = await isar.bookSchemas.get(widget.bookId);
      
      setState(() {
        _book = book;
        _isLoading = false;
      });
    } catch (e) {
      print('ReadingScreen: Error loading book: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoading ? 'Loading...' : (_book?.title ?? 'Unknown Book')),
        actions: [
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Show reading settings panel
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : PageTurnWidget(bookId: widget.bookId),
    );
  }
}