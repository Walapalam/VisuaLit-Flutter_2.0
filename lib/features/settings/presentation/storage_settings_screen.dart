import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/features/settings/data/cache_manager.dart';

final cacheStatsProvider = FutureProvider.autoDispose<CacheStats>((ref) async {
  final cacheManager = ref.watch(cacheManagerProvider);
  return cacheManager.getCacheStats();
});

class StorageSettingsScreen extends ConsumerStatefulWidget {
  const StorageSettingsScreen({super.key});

  @override
  ConsumerState<StorageSettingsScreen> createState() => _StorageSettingsScreenState();
}

class _StorageSettingsScreenState extends ConsumerState<StorageSettingsScreen> {
  bool _isClearing = false;

  @override
  Widget build(BuildContext context) {
    final cacheStatsAsync = ref.watch(cacheStatsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Settings'),
      ),
      body: cacheStatsAsync.when(
        data: (stats) => _buildContent(stats),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error loading cache stats: $error'),
        ),
      ),
    );
  }
  
  Widget _buildContent(CacheStats stats) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(cacheStatsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCacheSummary(stats),
          const SizedBox(height: 24),
          _buildCacheActions(),
          const SizedBox(height: 24),
          _buildBookList(stats),
        ],
      ),
    );
  }
  
  Widget _buildCacheSummary(CacheStats stats) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cache Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSummaryItem('Total Books', '${stats.totalBooks}'),
            _buildSummaryItem('Total Size', stats.totalSizeFormatted),
            _buildSummaryItem('Ready Books', '${stats.readyBooks}'),
            _buildSummaryItem('Processing Books', '${stats.processingBooks}'),
            _buildSummaryItem('Error Books', '${stats.errorBooks}'),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: stats.totalSizeInBytes / CacheManager.defaultCacheSizeLimit,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                stats.totalSizeInBytes > CacheManager.defaultCacheSizeLimit * 0.8
                    ? Colors.red
                    : Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${stats.totalSizeFormatted} / ${_formatSize(CacheManager.defaultCacheSizeLimit)} used',
              style: TextStyle(
                color: stats.totalSizeInBytes > CacheManager.defaultCacheSizeLimit * 0.8
                    ? Colors.red
                    : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
  
  Widget _buildCacheActions() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cache Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isClearing
                        ? null
                        : () => _showClearCacheConfirmation(),
                    child: _isClearing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Clear All Cache'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final cacheManager = ref.read(cacheManagerProvider);
                      await cacheManager.applyCacheEvictionRules();
                      ref.refresh(cacheStatsProvider);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cache optimized')),
                        );
                      }
                    },
                    child: const Text('Optimize Cache'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBookList(CacheStats stats) {
    final sortedBooks = stats.bookSizes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Books by Size',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...sortedBooks.map((entry) => _buildBookItem(entry.key, entry.value)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBookItem(String title, int size) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: size / CacheManager.defaultCacheSizeLimit,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                const SizedBox(height: 4),
                Text(_formatSize(size)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              // We would need to map title to book ID here
              // For now, just show a message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Clear cache for "$title" (not implemented)')),
              );
            },
          ),
        ],
      ),
    );
  }
  
  void _showClearCacheConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Cache'),
        content: const Text(
          'This will clear the cache for all books. You will need to reprocess them the next time you open them. Are you sure?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() {
                _isClearing = true;
              });
              
              final cacheManager = ref.read(cacheManagerProvider);
              await cacheManager.clearAllCache();
              
              setState(() {
                _isClearing = false;
              });
              
              ref.refresh(cacheStatsProvider);
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cache cleared')),
                );
              }
            },
            child: const Text('CLEAR'),
          ),
        ],
      ),
    );
  }
  
  String _formatSize(int sizeInBytes) {
    if (sizeInBytes < 1024) {
      return '$sizeInBytes B';
    } else if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    } else if (sizeInBytes < 1024 * 1024 * 1024) {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(sizeInBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}