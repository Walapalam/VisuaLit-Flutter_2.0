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
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (context) {
                      return FractionallySizedBox(
                        heightFactor: 0.6, // Covers 60% of the screen height
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Book Cover
                                  Container(
                                    width: 100,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: NetworkImage(book['formats']['image/jpeg'] ?? ''),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Book Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          book['title'] ?? 'No Title',
                                          style: Theme.of(context).textTheme.headlineSmall,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          book['authors'] != null && book['authors'].isNotEmpty
                                              ? book['authors'][0]['name']
                                              : 'Unknown Author',
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          book['description'] ?? 'No description available.',
                                          style: Theme.of(context).textTheme.bodyMedium,
                                          maxLines: 4,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              // Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.shopping_cart, color: Colors.white),
                                      label: const Text('Add to Cart', style: TextStyle(color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue, // Set button background color
                                      ),
                                      onPressed: () {
                                        ref.read(cartProvider.notifier).addBook(book, context);
                                        Navigator.pop(context); // Close the bottom sheet
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.shopping_bag, color: Colors.white),
                                      label: const Text('Buy', style: TextStyle(color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green, // Set button background color
                                      ),
                                      onPressed: () {
                                        // Handle buy action
                                        Navigator.pop(context); // Close the bottom sheet
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
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