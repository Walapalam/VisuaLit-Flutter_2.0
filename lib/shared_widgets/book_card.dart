import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:visualit/core/theme/app_theme.dart';

class BookCard extends StatelessWidget {
  final Uint8List? imageBytes;
  final String title;
  final String author;
  final VoidCallback onTap;

  const BookCard({
    super.key,
    this.imageBytes,
    required this.title,
    required this.author,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Container(
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.surface,
                  child: imageBytes != null
                      ? Image.memory(
                    imageBytes!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.book,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        size: 50,
                      );
                    },
                  )
                      : Icon(
                    Icons.book,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    size: 50,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}