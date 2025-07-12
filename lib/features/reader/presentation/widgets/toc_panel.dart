import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/providers/isar_provider.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/data/toc_entry.dart';
import 'package:visualit/features/reader/presentation/reading_controller.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';

// Provider to fetch the book for the TOC Panel (This is correct and stays the same)
final tocBookProvider = FutureProvider.family<Book?, int>((ref, bookId) async {
  final isar = await ref.watch(isarDBProvider.future);
  return isar.books.get(bookId);
});

class TOCPanel extends ConsumerWidget {
  final int bookId;
  final Size viewSize;

  const TOCPanel({super.key, required this.bookId, required this.viewSize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookAsync = ref.watch(tocBookProvider(bookId));
    final isSystemDark = Theme.of(context).brightness == Brightness.dark;

    // Enhanced color scheme for better visibility
    final panelColor = isSystemDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isSystemDark ? Colors.white : Colors.black87;
    final iconColor = isSystemDark ? Colors.white70 : Colors.black54;
    final dividerColor = isSystemDark ? Colors.white12 : Colors.black12;

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: panelColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar for better drag indication
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              bookAsync.when(
                loading: () => const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, st) => Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, color: textColor, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Unable to load contents',
                          style: TextStyle(color: textColor),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (book) {
                  if (book == null || book.toc.isEmpty) {
                    return Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.menu_book, color: textColor, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              'No contents available',
                              style: TextStyle(color: textColor),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Contents',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Divider(height: 1, color: dividerColor),
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            physics: const BouncingScrollPhysics(),
                            itemCount: book.toc.length,
                            itemBuilder: (context, index) {
                              return _TOCEntryTile(
                                entry: book.toc[index],
                                viewSize: viewSize,
                                bookId: bookId,
                                textColor: textColor,
                                iconColor: iconColor,
                                isLastItem: index == book.toc.length - 1,
                              );
                            },
                          ),
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
    );
  }
}

class _TOCEntryTile extends ConsumerWidget {
  final TOCEntry entry;
  final Size viewSize;
  final int bookId;
  final double indent;
  final Color textColor;
  final Color iconColor;
  final bool isLastItem;

  const _TOCEntryTile({
    required this.entry,
    required this.viewSize,
    required this.bookId,
    this.indent = 16.0,
    required this.textColor,
    required this.iconColor,
    required this.isLastItem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasChildren = entry.children.isNotEmpty;
    final isNavigable = entry.src != null;

    void navigate() {
      if (isNavigable) {
        Navigator.of(context).pop();
        ref.read(readingControllerProvider((bookId, viewSize)).notifier)
            .jumpToLocation(entry);
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasChildren)
          Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              title: Text(
                entry.title ?? 'Untitled Section',
                style: TextStyle(
                  color: textColor,
                  fontWeight: isNavigable ? FontWeight.w500 : FontWeight.normal,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              tilePadding: EdgeInsets.only(left: indent, right: 16),
              iconColor: iconColor,
              collapsedIconColor: iconColor,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isNavigable)
                    IconButton(
                      icon: Icon(Icons.navigate_next, color: iconColor),
                      onPressed: navigate,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                    ),
                  const SizedBox(width: 8),
                  Icon(Icons.expand_more, color: iconColor),
                ],
              ),
              children: entry.children.asMap().entries.map((e) {
                return _TOCEntryTile(
                  entry: e.value,
                  viewSize: viewSize,
                  bookId: bookId,
                  indent: indent + 16,
                  textColor: textColor,
                  iconColor: iconColor,
                  isLastItem: e.key == entry.children.length - 1,
                );
              }).toList(),
            ),
          )
        else
          ListTile(
            contentPadding: EdgeInsets.only(left: indent, right: 16),
            title: Text(
              entry.title ?? 'Untitled Chapter',
              style: TextStyle(
                color: textColor,
                fontWeight: isNavigable ? FontWeight.w500 : FontWeight.normal,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: isNavigable
                ? Icon(Icons.navigate_next, color: iconColor)
                : null,
            onTap: isNavigable ? navigate : null,
            enabled: isNavigable,
          ),
        if (!isLastItem)
          Divider(
            height: 1,
            thickness: 0.5,
            color: textColor.withOpacity(0.1),
            indent: indent,
          ),
      ],
    );
  }
}