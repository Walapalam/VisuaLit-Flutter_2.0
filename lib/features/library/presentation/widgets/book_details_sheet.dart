import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/library/presentation/library_controller.dart';

class BookDetailsSheet extends ConsumerStatefulWidget {
  final Book book;
  final LibraryController controller;

  const BookDetailsSheet({
    super.key,
    required this.book,
    required this.controller,
  });

  @override
  ConsumerState<BookDetailsSheet> createState() => _BookDetailsSheetState();
}

class _BookDetailsSheetState extends ConsumerState<BookDetailsSheet> {
  String _selectedTab = 'chapters'; // 'chapters' or 'images'

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.85, // limit to avoid covering the app bar
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    const SizedBox(height: 16),

                    // Book Cover and Info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cover
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 100,
                            height: 140,
                            color: Colors.grey[900],
                            child: widget.book.coverImageBytes != null
                                ? Image.memory(
                                    Uint8List.fromList(
                                      widget.book.coverImageBytes!,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : Icon(
                                    Icons.book,
                                    size: 40,
                                    color: Colors.grey[700],
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Title and Author
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.book.title ?? 'Unknown Title',
                                style: const TextStyle(
                                  color: AppTheme.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.book.author ?? 'Unknown Author',
                                style: TextStyle(
                                  color: AppTheme.white.withOpacity(0.7),
                                  fontSize: 15,
                                ),
                              ),
                              if (widget.book.publisher != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  widget.book.publisher!,
                                  style: TextStyle(
                                    color: AppTheme.white.withOpacity(0.5),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Reading Progress
                    if (widget.book.lastReadPage > 0) ...[
                      _buildProgressSection(),
                      const SizedBox(height: 24),
                    ],

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.play_arrow,
                            label: widget.book.lastReadPage > 0
                                ? 'Continue Reading'
                                : 'Start Reading',
                            isPrimary: true,
                            onTap: () {
                              Navigator.pop(context);
                              context.goNamed(
                                'bookReader',
                                pathParameters: {
                                  'bookId': widget.book.id.toString(),
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildIconButton(
                          icon: Icons.delete_outline,
                          onTap: () => _showDeleteConfirmation(context),
                        ),
                        const SizedBox(width: 8),
                        _buildIconButton(
                          icon: Icons.share_outlined,
                          onTap: () {
                            // TODO: Implement share functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Share feature coming soon'),
                                backgroundColor: AppTheme.primaryGreen,
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Book Stats
                    _buildStatsRow(),

                    const SizedBox(height: 24),

                    // Tab Selector (Chapters / Images)
                    _buildTabSelector(),

                    const SizedBox(height: 16),

                    // Tab Content
                    if (_selectedTab == 'chapters')
                      _buildChaptersList()
                    else
                      _buildImagesList(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressSection() {
    final progress = widget.book.totalChapters > 0
        ? widget.book.lastReadPage / widget.book.totalChapters
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reading Progress',
              style: TextStyle(
                color: AppTheme.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                color: AppTheme.primaryGreen,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppTheme.primaryGreen,
            ),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isPrimary
                ? AppTheme.primaryGreen
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: isPrimary
                ? null
                : Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isPrimary ? AppTheme.black : AppTheme.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? AppTheme.black : AppTheme.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Icon(icon, color: AppTheme.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    // Calculate chapters from TOC
    final chaptersCount = widget.book.toc.isNotEmpty
        ? widget.book.toc.length
        : (widget.book.totalChapters > 0 ? widget.book.totalChapters : null);

    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            icon: Icons.menu_book,
            label: 'Chapters',
            value: chaptersCount != null ? '$chaptersCount' : 'N/A',
          ),
        ),
        Expanded(
          child: _buildStatItem(
            icon: Icons.access_time,
            label: 'Last Read',
            value: widget.book.lastReadTimestamp != null
                ? _formatDate(widget.book.lastReadTimestamp!)
                : 'Never',
          ),
        ),
        Expanded(
          child: _buildStatItem(
            icon: Icons.storage,
            label: 'Size',
            value: widget.book.fileSizeInBytes != null
                ? _formatFileSize(widget.book.fileSizeInBytes!)
                : 'N/A',
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryGreen, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.white.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              label: 'Chapters',
              isSelected: _selectedTab == 'chapters',
              onTap: () => setState(() => _selectedTab = 'chapters'),
            ),
          ),
          Expanded(
            child: _buildTab(
              label: 'Images',
              isSelected: _selectedTab == 'images',
              onTap: () => setState(() => _selectedTab = 'images'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected
                ? AppTheme.black
                : AppTheme.white.withOpacity(0.6),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildChaptersList() {
    if (widget.book.toc.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No chapters available',
            style: TextStyle(
              color: AppTheme.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Column(
      children: widget.book.toc.asMap().entries.map((entry) {
        final index = entry.key;
        final chapter = entry.value;
        final isRead = index < widget.book.lastReadPage;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: ListTile(
            leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isRead
                    ? AppTheme.primaryGreen.withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: isRead
                        ? AppTheme.primaryGreen
                        : AppTheme.white.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            title: Text(
              chapter.title ?? 'Untitled Chapter',
              style: TextStyle(
                color: isRead
                    ? AppTheme.white
                    : AppTheme.white.withOpacity(0.8),
                fontSize: 14,
                fontWeight: isRead ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            trailing: isRead
                ? const Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryGreen,
                    size: 18,
                  )
                : null,
            onTap: () {
              Navigator.pop(context);
              context.goNamed(
                'bookReader',
                pathParameters: {'bookId': widget.book.id.toString()},
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildImagesList() {
    // TODO: Fetch images from ContentBlock where blockType == BlockType.img
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.image_outlined,
              size: 48,
              color: AppTheme.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Image gallery coming soon',
              style: TextStyle(
                color: AppTheme.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Remove from Library?',
          style: TextStyle(color: AppTheme.white),
        ),
        content: Text(
          'Are you sure you want to remove "${widget.book.title}" from your library? This action cannot be undone.',
          style: TextStyle(color: AppTheme.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.white),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close bottom sheet
              widget.controller.deleteBook(widget.book.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Book removed from library'),
                  backgroundColor: AppTheme.primaryGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
