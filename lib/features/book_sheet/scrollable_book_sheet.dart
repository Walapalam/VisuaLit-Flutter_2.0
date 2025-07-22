// At the top of lib/features/book_sheet/scrollable_book_sheet.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/core/models/book.dart';
import 'package:visualit/core/models/book_metadata.dart';
import 'package:visualit/core/services/epub_service.dart';
import 'package:visualit/core/theme/app_theme.dart';

class BookDetailsSheet extends StatefulWidget {
  final BookMetadata bookMetadata;
  final VoidCallback onStartListening;

  const BookDetailsSheet({
    super.key,
    required this.bookMetadata,
    required this.onStartListening,
  });

  @override
  State<BookDetailsSheet> createState() => _BookDetailsSheetState();
}

class _BookDetailsSheetState extends State<BookDetailsSheet> {
  late Future<Book> _bookFuture;
  final EpubService _epubService = EpubService();

  @override
  void initState() {
    super.initState();
    _bookFuture = _epubService.loadBook(widget.bookMetadata.filePath);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkGrey,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: FutureBuilder<Book>(
                  future: _bookFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppTheme.primaryGreen),
                      );
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return Center(
                        child: Text(
                          snapshot.hasError ? 'Error: ${snapshot.error}' : 'No data available',
                          style: const TextStyle(color: AppTheme.white),
                        ),
                      );
                    }

                    final book = snapshot.data!;

                    return CustomScrollView(
                      controller: scrollController,
                      slivers: [
                        SliverToBoxAdapter(
                          child: Container(
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.black,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Hero(
                                    tag: 'book-${widget.bookMetadata.title}',
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        width: 120,
                                        height: 180,
                                        child: widget.bookMetadata.coverImage ??
                                            _buildPlaceholderCover(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.bookMetadata.title,
                                          style: const TextStyle(
                                            color: AppTheme.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'By ${widget.bookMetadata.authors.join(", ")}',
                                          style: const TextStyle(
                                            color: AppTheme.grey,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        _buildActionButtons(context),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        _buildChaptersList(book),
                        if (book.images.isNotEmpty)
                          _buildImagesGrid(book),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlaceholderCover() {
    return Container(
      color: AppTheme.black,
      child: Center(
        child: Text(
          widget.bookMetadata.title.substring(0, 1),
          style: const TextStyle(
            color: AppTheme.white,
            fontSize: 40,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            context.push('/reader', extra: widget.bookMetadata);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: AppTheme.black,
            minimumSize: const Size(double.infinity, 45),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.book),
          label: const Text('Start Reading'),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: widget.onStartListening,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: AppTheme.black,
            minimumSize: const Size(double.infinity, 45),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.headphones),
          label: const Text('Start Listening'),
        ),
      ],
    );
  }

  Widget _buildChaptersList(Book book) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          if (index == 0) {
            return const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(
                'Table of Contents',
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
          final chapter = book.chapters[index - 1];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                chapter.title,
                style: const TextStyle(color: AppTheme.white),
              ),
              onTap: () => context.push('/reader', extra: widget.bookMetadata),
            ),
          );
        },
        childCount: book.chapters.length + 1,
      ),
    );
  }

  Widget _buildImagesGrid(Book book) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final image = book.images.values.elementAt(index);
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.black,
                ),
                child: image,
              ),
            );
          },
          childCount: book.images.length,
        ),
      ),
    );
  }
}