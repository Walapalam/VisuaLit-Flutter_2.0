import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/presentation/reading_controller.dart';

class SearchDialog extends ConsumerStatefulWidget {
  final int bookId;
  final List<ContentBlock> blocks;

  const SearchDialog({
    super.key,
    required this.bookId,
    required this.blocks,
  });

  @override
  ConsumerState<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends ConsumerState<SearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  final List<SearchResult> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    debugPrint("[DEBUG] SearchDialog: Initializing with ${widget.blocks.length} content blocks for book ID: ${widget.bookId}");

    // Set up a listener for the search field
    _searchController.addListener(() {
      if (_searchController.text.length >= 3) {
        debugPrint("[DEBUG] SearchDialog: Auto-searching for: '${_searchController.text}'");
        _performSearch(_searchController.text);
      } else if (_searchController.text.isEmpty && _searchResults.isNotEmpty) {
        debugPrint("[DEBUG] SearchDialog: Clearing search results");
        setState(() {
          _searchResults.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    debugPrint("[DEBUG] SearchDialog: Disposing search dialog");
    try {
      _searchController.dispose();
      debugPrint("[DEBUG] SearchDialog: Search controller disposed");
    } catch (e) {
      debugPrint("[ERROR] SearchDialog: Error disposing search controller: $e");
    }
    super.dispose();
  }

  void _performSearch(String query) {
    try {
      debugPrint("[DEBUG] SearchDialog: Performing search for query: '$query'");

      if (query.isEmpty) {
        debugPrint("[DEBUG] SearchDialog: Empty query, clearing results");
        setState(() {
          _searchResults.clear();
          _isSearching = false;
        });
        return;
      }

      setState(() {
        _isSearching = true;
        _searchResults.clear();
      });

      final startTime = DateTime.now();
      final lowerCaseQuery = query.toLowerCase();
      int blocksSearched = 0;
      int matchesFound = 0;

      // TODO: Perform search in a separate isolate or compute function for better performance
      // For now, we'll do it on the main thread for simplicity
      for (int i = 0; i < widget.blocks.length; i++) {
        try {
          blocksSearched++;
          final block = widget.blocks[i];

          if (block.textContent == null || block.textContent!.isEmpty) {
            continue;
          }

          final text = block.textContent!.toLowerCase();
          int startIndex = 0;
          int blockMatches = 0;

          while (true) {
            final index = text.indexOf(lowerCaseQuery, startIndex);
            if (index == -1) break;

            // Get some context around the match
            final previewStart = index > 20 ? index - 20 : 0;
            final previewEnd = index + lowerCaseQuery.length + 20 < text.length 
                ? index + lowerCaseQuery.length + 20 
                : text.length;

            try {
              final preview = block.textContent!.substring(previewStart, previewEnd);

              _searchResults.add(SearchResult(
                blockIndex: i,
                matchIndex: index,
                preview: preview,
                matchLength: lowerCaseQuery.length,
                previewStartOffset: previewStart,
              ));

              matchesFound++;
              blockMatches++;
              startIndex = index + lowerCaseQuery.length;
            } catch (e) {
              debugPrint("[ERROR] SearchDialog: Error creating preview for match at index $index: $e");
              startIndex = index + 1; // Skip this match and continue
            }
          }

          if (blockMatches > 0) {
            debugPrint("[DEBUG] SearchDialog: Found $blockMatches matches in block $i");
          }
        } catch (e) {
          debugPrint("[ERROR] SearchDialog: Error searching block $i: $e");
        }
      }

      final duration = DateTime.now().difference(startTime);
      debugPrint("[DEBUG] SearchDialog: Search completed in ${duration.inMilliseconds}ms. Searched $blocksSearched blocks, found $matchesFound matches");

      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    } catch (e, stack) {
      debugPrint("[ERROR] SearchDialog: Error in _performSearch: $e");
      debugPrintStack(stackTrace: stack);

      if (mounted) {
        setState(() {
          _isSearching = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _navigateToResult(SearchResult result) async {
    try {
      debugPrint("[DEBUG] SearchDialog: Navigating to search result in block ${result.blockIndex} at index ${result.matchIndex}");

      if (!mounted) {
        debugPrint("[WARN] SearchDialog: Widget not mounted, cannot navigate to result");
        return;
      }

      ReadingController? controller;
      try {
        controller = ref.read(readingControllerProvider(widget.bookId).notifier);
        debugPrint("[DEBUG] SearchDialog: Successfully obtained reading controller");
      } catch (e) {
        debugPrint("[ERROR] SearchDialog: Failed to get reading controller: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Could not access reading controller')),
        );
        return;
      }

      debugPrint("[DEBUG] SearchDialog: Finding page for block ${result.blockIndex}");
      // We know controller is not null here because we would have returned earlier if it was
      final page = await controller!.findPageForBlock(result.blockIndex);

      if (page == null) {
        debugPrint("[WARN] SearchDialog: Could not find page for block ${result.blockIndex}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not find the page for this result')),
          );
        }
        return;
      }

      debugPrint("[DEBUG] SearchDialog: Found result on page $page, navigating");

      if (mounted) {
        Navigator.of(context).pop(SearchNavigation(
          page: page,
          blockIndex: result.blockIndex,
          matchIndex: result.matchIndex,
          matchLength: result.matchLength,
        ));
      } else {
        debugPrint("[WARN] SearchDialog: Widget no longer mounted after finding page");
      }
    } catch (e, stack) {
      debugPrint("[ERROR] SearchDialog: Error navigating to search result: $e");
      debugPrintStack(stackTrace: stack);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigation error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("[DEBUG] SearchDialog: Building search dialog UI");

    try {
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search input field
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search in book',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            debugPrint("[DEBUG] SearchDialog: Clearing search text");
                            _searchController.clear();
                            _performSearch('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value) {
                  debugPrint("[DEBUG] SearchDialog: Search text changed: '$value'");
                  if (value.length >= 3) {
                    _performSearch(value);
                  } else if (value.isEmpty) {
                    _performSearch('');
                  }
                },
                autofocus: true,
              ),
              const SizedBox(height: 16),

              // Search results or status indicators
              if (_isSearching) 
                Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 8),
                    Text("Searching ${widget.blocks.length} blocks...", 
                      style: Theme.of(context).textTheme.bodySmall),
                  ],
                )
              else if (_searchResults.isEmpty && _searchController.text.isNotEmpty)
                Column(
                  children: [
                    const Icon(Icons.search_off, size: 48, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text('No results found for "${_searchController.text}"',
                      textAlign: TextAlign.center),
                  ],
                )
              else if (_searchResults.isNotEmpty)
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text('Found ${_searchResults.length} matches',
                          style: Theme.of(context).textTheme.bodySmall),
                      ),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            try {
                              final result = _searchResults[index];
                              return ListTile(
                                title: RichText(
                                  text: _buildHighlightedText(
                                    result.preview,
                                    result.matchIndex - result.previewStartOffset,
                                    result.matchLength,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text('Match ${index + 1} of ${_searchResults.length}'),
                                onTap: () {
                                  debugPrint("[DEBUG] SearchDialog: Result ${index + 1} tapped");
                                  _navigateToResult(result);
                                },
                              );
                            } catch (e) {
                              debugPrint("[ERROR] SearchDialog: Error building search result $index: $e");
                              return ListTile(
                                title: Text('Error displaying result: ${e.toString()}', 
                                  style: TextStyle(color: Colors.red.shade300)),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // Cancel button
              TextButton(
                onPressed: () {
                  debugPrint("[DEBUG] SearchDialog: Cancel button pressed");
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      );
    } catch (e, stack) {
      debugPrint("[ERROR] SearchDialog: Error building search dialog: $e");
      debugPrintStack(stackTrace: stack);

      // Return a fallback UI in case of error
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Error: ${e.toString()}'),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      );
    }
  }

  TextSpan _buildHighlightedText(String text, int matchStart, int matchLength) {
    try {
      debugPrint("[DEBUG] SearchDialog: Building highlighted text, matchStart: $matchStart, matchLength: $matchLength, textLength: ${text.length}");

      // Validate input parameters
      if (text.isEmpty) {
        debugPrint("[WARN] SearchDialog: Empty text provided for highlighting");
        return const TextSpan(text: "");
      }

      if (matchStart < 0 || matchStart + matchLength > text.length) {
        debugPrint("[WARN] SearchDialog: Invalid match position - matchStart: $matchStart, matchLength: $matchLength, textLength: ${text.length}");
        return TextSpan(text: text);
      }

      // Build the highlighted text span
      return TextSpan(
        children: [
          TextSpan(text: text.substring(0, matchStart)),
          TextSpan(
            text: text.substring(matchStart, matchStart + matchLength),
            style: const TextStyle(
              backgroundColor: Colors.yellow,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: text.substring(matchStart + matchLength)),
        ],
      );
    } catch (e, stack) {
      debugPrint("[ERROR] SearchDialog: Error building highlighted text: $e");
      debugPrintStack(stackTrace: stack);

      // Return the original text without highlighting in case of error
      return TextSpan(text: text);
    }
  }
}

class SearchResult {
  final int blockIndex;
  final int matchIndex;
  final String preview;
  final int matchLength;
  final int previewStartOffset;

  SearchResult({
    required this.blockIndex,
    required this.matchIndex,
    required this.preview,
    required this.matchLength,
    required this.previewStartOffset,
  });
}

class SearchNavigation {
  final int page;
  final int blockIndex;
  final int matchIndex;
  final int matchLength;

  SearchNavigation({
    required this.page,
    required this.blockIndex,
    required this.matchIndex,
    required this.matchLength,
  });
}
