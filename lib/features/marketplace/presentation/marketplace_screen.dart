import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:visualit/features/Cart/presentation/CartNotifier.dart';


final gutenbergBooksProvider = FutureProvider<List<dynamic>>((ref) async {
  final response = await http.get(Uri.parse('https://gutendex.com/books/'));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['results'];
  } else {
    throw Exception('Failed to load books');
  }
});

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final booksAsyncValue = ref.watch(gutenbergBooksProvider);

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
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
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
      body: booksAsyncValue.when(
        data: (books) {
          final filteredBooks = books.where((book) {
            final title = book['title']?.toLowerCase() ?? '';
            return title.contains(_searchQuery);
          }).toList();

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2 / 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: filteredBooks.length,
            itemBuilder: (context, index) {
              final book = filteredBooks[index];
              final coverUrl = book['formats']['image/jpeg'];

              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.8,
                            maxHeight: MediaQuery.of(context).size.height * 0.5,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Book Cover
                                Center(
                                  child: coverUrl != null
                                      ? Image.network(
                                    coverUrl,
                                    fit: BoxFit.cover,
                                    height: 150,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[800],
                                        height: 150,
                                        child: const Center(
                                          child: Icon(Icons.book, size: 40),
                                        ),
                                      );
                                    },
                                  )
                                      : Container(
                                    color: Colors.grey[800],
                                    height: 150,
                                    child: const Center(
                                      child: Icon(Icons.book, size: 40),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Book Title
                                Text(
                                  book['title'] ?? 'No Title',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                      ),
                                      onPressed: () {
                                        ref.read(cartProvider.notifier).addBook(book, context);
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Add to Cart'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Purchased ${book['title']}')),
                                        );
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
                            ? Image.network(
                          coverUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: const Center(
                                child: Icon(Icons.book, size: 40),
                              ),
                            );
                          },
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}