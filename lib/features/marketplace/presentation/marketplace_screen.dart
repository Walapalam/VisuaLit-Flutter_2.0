import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:visualit/features/Cart/presentation/CartNotifier.dart';

import '../../library/data/local_library_service.dart';


// State class for marketplace
class MarketplaceState {
  final List<dynamic> books;
  final String? nextUrl;
  final bool isLoading;
  final String searchQuery;

  MarketplaceState({
    required this.books,
    required this.nextUrl,
    required this.isLoading,
    required this.searchQuery,
  });

  MarketplaceState copyWith({
    List<dynamic>? books,
    String? nextUrl,
    bool? isLoading,
    String? searchQuery,
  }) {
    return MarketplaceState(
      books: books ?? this.books,
      nextUrl: nextUrl ?? this.nextUrl,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// Notifier for marketplace state
class MarketplaceNotifier extends StateNotifier<MarketplaceState> {
  MarketplaceNotifier()
      : super(MarketplaceState(
    books: [],
    nextUrl: 'https://gutendex.com/books/',
    isLoading: false,
    searchQuery: '',
  )) {
    loadBooks(reset: true);
  }

  Future<void> loadBooks({bool reset = false}) async {
    if (state.isLoading || state.nextUrl == null) return;
    state = state.copyWith(isLoading: true);

    final url = reset
        ? 'https://gutendex.com/books/?search=${Uri.encodeComponent(state.searchQuery)}'
        : state.nextUrl!;

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newBooks = List<dynamic>.from(data['results']);
        state = state.copyWith(
          books: reset ? newBooks : [...state.books, ...newBooks],
          nextUrl: data['next'],
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, nextUrl: null);
      }
    } catch (_) {
      state = state.copyWith(isLoading: false, nextUrl: null);
    }
  }

  void searchBooks(String query) {
    state = state.copyWith(searchQuery: query, nextUrl: 'https://gutendex.com/books/?search=${Uri.encodeComponent(query)}');
    loadBooks(reset: true);
  }
}

// Riverpod provider
final marketplaceProvider =
StateNotifierProvider<MarketplaceNotifier, MarketplaceState>(
      (ref) => MarketplaceNotifier(),
);

class MarketplaceScreen extends ConsumerWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(marketplaceProvider);
    final notifier = ref.read(marketplaceProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search books...',
                    hintStyle: TextStyle(color: Colors.white),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    notifier.searchBooks(value.toLowerCase());
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () {
                  context.go('/cart');
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: state.isLoading && state.books.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.books.isEmpty
                ? const Center(child: Text('No books found'))
                : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2 / 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: state.books.length,
              itemBuilder: (context, index) {
                final book = state.books[index];
                final coverUrl = book['formats']['image/jpeg'];

                return GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth:
                              MediaQuery.of(context).size.width *
                                  0.8,
                              maxHeight:
                              MediaQuery.of(context).size.height *
                                  0.5,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Center(
                                    child: coverUrl != null
                                        ? RetryNetworkImage(
                                      url: coverUrl,
                                      fit: BoxFit.cover,
                                      height: 150,
                                    )
                                        : Container(
                                      color: Colors.grey[800],
                                      height: 150,
                                      child: const Center(
                                        child: Icon(Icons.book,
                                            size: 40),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    book['title'] ?? 'No Title',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        style:
                                        ElevatedButton.styleFrom(
                                          backgroundColor:
                                          Colors.white,
                                          foregroundColor:
                                          Colors.black,
                                          padding: const EdgeInsets
                                              .symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                        ),
                                        onPressed: () {
                                          ref
                                              .read(cartProvider
                                              .notifier)
                                              .addBook(
                                              book, context);
                                          Navigator.of(context).pop();
                                        },
                                        child:
                                        const Text('Add to Cart'),
                                      ),
                                      ElevatedButton(
                                        style:
                                        ElevatedButton.styleFrom(
                                          backgroundColor:
                                          Colors.white,
                                          foregroundColor:
                                          Colors.black,
                                          padding: const EdgeInsets
                                              .symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                        ),
                                        onPressed: () async{
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(
                                              context)
                                              .showSnackBar(SnackBar(
                                              content: Text('Downloading ${book['title']}...'))
                                          );
                                          try {
                                            final localLibraryService = LocalLibraryService();
                                            final coverUrl = book['formats']['image/jpeg'];

                                            // Download the book cover as example (replace with actual book file)
                                            if (coverUrl != null) {
                                              final response = await http.get(Uri.parse(coverUrl));
                                              if (response.statusCode == 200) {
                                                final fileName = '${book['title']?.replaceAll(RegExp(r'[^\w\s-]'), '')}.epub';
                                                final success = await localLibraryService.downloadBook(
                                                  fileData: response.bodyBytes,
                                                  fileName: fileName,
                                                );

                                                if (success) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Downloaded ${book['title']} successfully!'))
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Failed to download ${book['title']}'))
                                                  );
                                                }
                                              }
                                            }
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Error: $e'))
                                            );
                                          }
                                        },
                                        child: const Text('Buy'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Card(
                    elevation: 4,
                    child: Column(
                      children: [
                        Expanded(
                          child: coverUrl != null
                              ? RetryNetworkImage(
                            url: coverUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                              : Container(
                            color: Colors.grey[800],
                            child: const Center(
                              child: Icon(Icons.book, size: 40),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            book['title'] ?? 'Loading...',
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (state.nextUrl != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: state.isLoading
                    ? null
                    : () => notifier.loadBooks(),
                child: state.isLoading
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : Text(
                  'Load More',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary, // or your custom green
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class RetryNetworkImage extends StatefulWidget {
  final String url;
  final int maxRetries;
  final BoxFit fit;
  final double? height;
  final double? width;

  const RetryNetworkImage({
    required this.url,
    this.maxRetries = 2,
    this.fit = BoxFit.cover,
    this.height,
    this.width,
    super.key,
  });

  @override
  State<RetryNetworkImage> createState() => _RetryNetworkImageState();
}

class _RetryNetworkImageState extends State<RetryNetworkImage> {
  int _retryCount = 0;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      widget.url,
      fit: widget.fit,
      height: widget.height,
      width: widget.width,
      errorBuilder: (context, error, stackTrace) {
        if (_retryCount < widget.maxRetries) {
          _retryCount++;
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) setState(() {});
          });
          return const SizedBox.shrink();
        }
        return Container(
          color: Colors.grey[800],
          height: widget.height,
          width: widget.width,
          child: const Center(child: Icon(Icons.broken_image, size: 40)),
        );
      },
    );
  }
}