import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class CartNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  CartNotifier() : super([]);

  void addBook(Map<String, dynamic> book,  BuildContext context) {
    // Check if the book is already in the cart
    final isBookInCart = state.any((b) => b['id'] == book['id']);
    if (!isBookInCart) {
      state = [...state, book];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${book['title']} added to cart'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Show a SnackBar message if the book is already in the cart
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Book is already in the cart'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void removeBook(Map<String, dynamic> book) {
    state = state.where((b) => b != book).toList();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<Map<String, dynamic>>>(
      (ref) => CartNotifier(),
);