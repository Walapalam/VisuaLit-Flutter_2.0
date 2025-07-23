import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/Cart/presentation/CartNotifier.dart';
import 'package:visualit/features/library/presentation/library_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;


class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final Set<int> downloadingIds = {};

  @override
  Widget build(BuildContext context) {
    final cartBooks = ref.watch(cartProvider);
    final libraryController = ref.read(libraryControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.goNamed('marketplace'); // Replace '/home' with your actual route to the marketplace
          },
        ),
        title: const Text('Cart'),
      ),
      body: cartBooks.isEmpty
          ? const Center(
        child: Text(
          'No books in the cart',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: cartBooks.length,
        itemBuilder: (context, index) {
          final book = cartBooks[index];
          final bookId = book['id'];

          return ListTile(
            leading: book['formats']['image/jpeg'] != null
                ? Image.network(
              book['formats']['image/jpeg'],
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            )
                : const Icon(Icons.book),
            title: Text(book['title'] ?? 'No Title'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                downloadingIds.contains(bookId)
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : IconButton(
                  icon: const Icon(Icons.download, color: Colors.blue),
                  onPressed: () async {
                    setState(() => downloadingIds.add(bookId)); // Show loading indicator
                    try {
                      // Get the download URL for the EPUB file
                      final downloadUrl = book['formats']['application/epub+zip'];
                      if (downloadUrl == null) {
                        throw Exception('Download URL not available');
                      }

                      // Download the EPUB file
                      final response = await http.get(Uri.parse(downloadUrl));
                      if (response.statusCode == 200) {
                        // Save the book to the library
                        final bookData = {
                          'id': book['id'],
                          'title': book['title'],
                          'authors': book['authors'],
                          'fileBytes': response.bodyBytes,
                        };
                        await libraryController.addBookFromCart(bookData);

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${book['title']} added to Library')),
                        );
                      } else {
                        throw Exception('Failed to download the book');
                      }
                    } catch (e) {
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error downloading ${book['title']}: $e')),
                      );
                    } finally {
                      setState(() => downloadingIds.remove(bookId)); // Hide loading indicator
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Book'),
                        content: const Text('Are you sure you want to delete this book from the cart?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              ref.read(cartProvider.notifier).removeBook(book);
                              Navigator.of(context).pop();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
