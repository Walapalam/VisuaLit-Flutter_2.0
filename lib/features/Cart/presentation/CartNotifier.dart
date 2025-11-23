import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:visualit/core/services/toast_service.dart';

class CartNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  CartNotifier() : super([]);

  void addBook(Map<String, dynamic> book, BuildContext context) {
    // Check if the book is already in the cart
    final isBookInCart = state.any((b) => b['id'] == book['id']);
    if (!isBookInCart) {
      state = [...state, book];
      ToastService.show(
        context,
        '${book['title']} added to cart',
        type: ToastType.success,
      );
    } else {
      // Show a SnackBar message if the book is already in the cart
      ToastService.show(
        context,
        'Book is already in the cart',
        type: ToastType.info,
      );
    }
  }

  void removeBook(Map<String, dynamic> book) {
    state = state.where((b) => b != book).toList();
  }
}

final cartProvider =
    StateNotifierProvider<CartNotifier, List<Map<String, dynamic>>>(
      (ref) => CartNotifier(),
    );
