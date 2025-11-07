// lib/features/home/presentation/widgets/empty_library_view.dart

import 'package:flutter/material.dart';
import 'package:visualit/core/theme/app_theme.dart';

class EmptyLibraryView extends StatelessWidget {
  final VoidCallback onSelectBooks;

  const EmptyLibraryView({super.key, required this.onSelectBooks});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No books found.\nStart by importing your first book!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Select Your Books'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: AppTheme.black,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onSelectBooks,
            ),
          ],
        ),
      ),
    );
  }
}
