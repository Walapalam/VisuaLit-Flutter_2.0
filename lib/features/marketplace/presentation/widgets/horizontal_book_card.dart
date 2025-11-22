import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/marketplace/presentation/widgets/marketplace_card.dart';

class HorizontalBookCard extends ConsumerWidget {
  final Map<String, dynamic> book;

  const HorizontalBookCard({required this.book, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 140, // Increased width for better aspect ratio with new card
      margin: const EdgeInsets.only(right: 12),
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: MarketplaceCard(book: book),
      ),
    );
  }
}
