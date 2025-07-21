import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/features/reader/application/search_service.dart';
import 'package:visualit/features/reader/data/book_data.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _debounce = Debouncer(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce.run(() {
      ref.read(searchQueryProvider.notifier).state = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(filteredSearchResultsProvider);
    final selectedBookId = ref.watch(selectedBookFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search in books...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
              textInputAction: TextInputAction.search,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Book filter chips
          if (_searchController.text.isNotEmpty)
            searchResults.when(
              data: (results) {
                final books = results.map((r) => r.book).toSet().toList();
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All Books'),
                        selected: selectedBookId == null,
                        onSelected: (selected) {
                          if (selected) {
                            ref.read(selectedBookFilterProvider.notifier).state = null;
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      ...books.map((book) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(book.title ?? 'Untitled'),
                          selected: selectedBookId == book.id,
                          onSelected: (selected) {
                            ref.read(selectedBookFilterProvider.notifier).state = 
                                selected ? book.id : null;
                          },
                        ),
                      )),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox(height: 52),
              error: (_, __) => const SizedBox(height: 52),
            ),

          // Search results
          Expanded(
            child: searchResults.when(
              data: (results) {
                if (_searchController.text.isEmpty) {
                  return const Center(
                    child: Text('Enter a search term to find content in your books'),
                  );
                }

                if (results.isEmpty) {
                  return const Center(
                    child: Text('No results found'),
                  );
                }

                // Group results by book
                final groupedResults = ref.read(searchServiceProvider).groupResultsByBook(results);

                return ListView.builder(
                  itemCount: groupedResults.length,
                  itemBuilder: (context, index) {
                    final book = groupedResults.keys.elementAt(index);
                    final bookResults = groupedResults[book]!;

                    return ExpansionTile(
                      title: Text(book.title ?? 'Untitled'),
                      subtitle: Text('${bookResults.length} results'),
                      initiallyExpanded: groupedResults.length == 1,
                      children: bookResults.map((result) {
                        return ListTile(
                          title: Text(
                            result.snippet,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            'Chapter ${result.block.chapterIndex! + 1}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          onTap: () {
                            // Navigate to the reader screen at the specific block
                            context.push('/reader/${book.id}?blockId=${result.block.id}');
                          },
                        );
                      }).toList(),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Debouncer to prevent excessive searches while typing
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
