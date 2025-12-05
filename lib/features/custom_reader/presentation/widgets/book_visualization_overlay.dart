import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/data/models/book.dart'; // This is your Appwrite Book model
import 'package:visualit/data/models/chapter.dart';
import 'package:visualit/data/models/generated_visual.dart';
import 'package:visualit/data/services/appwrite_service.dart';
import 'package:visualit/features/reader/presentation/widgets/image_detail_dialog.dart';
import 'package:visualit/features/reader/presentation/widgets/liquid_glass_container.dart';

// Helper to replace deprecated withOpacity usage (keeps the same visual alpha)
Color _withOpacity(Color base, double opacity) => base.withAlpha((opacity * 255).round());

// A StateProvider to manage the loading state of the generation request
final generationLoadingProvider = StateProvider.autoDispose<bool>((ref) {
  print('📚 DEBUG: Initializing generationLoadingProvider');
  ref.onDispose(() {
    print('📚 DEBUG: Disposing generationLoadingProvider');
  });
  return false;
});

// FutureProvider to fetch book details from Appwrite by title for lookup
final bookDetailsByTitleProvider = FutureProvider.family<Book?, String>((ref, bookTitle) async {
  print('📚 DEBUG: Fetching book details for title: $bookTitle');
  final service = ref.watch(appwriteServiceProvider);
  try {
    final book = await service.getBookByTitle(bookTitle);
    print('📚 DEBUG: Book lookup result - Found: ${book != null}, Title: ${book?.title}');
    return book;
  } catch (e) {
    print('📚 DEBUG: Error fetching book details: $e');
    rethrow;
  }
});

// Provider to find ALL matching chapter documents by book ID and chapter number
// Returns a list because there might be duplicate chapters in the DB
final currentChapterProvider = FutureProvider.family.autoDispose<List<Chapter>, ({String bookTitle, int chapterNumber})>((ref, params) async {
  print('📚 DEBUG: Finding chapters for number ${params.chapterNumber} of book "${params.bookTitle}"');

  // First get the book
  final bookAsync = await ref.watch(bookDetailsByTitleProvider(params.bookTitle).future);
  if (bookAsync == null) {
    print('📚 DEBUG: Book not found, cannot fetch chapters');
    return [];
  }

  // Then get all chapters for this book
  final service = ref.watch(appwriteServiceProvider);
  final chapters = await service.getChaptersForBook(bookAsync.id);
  print('📚 DEBUG: Fetched ${chapters.length} chapters for book ${bookAsync.id}');

  // Find all chapters matching the chapter number
  final matchingChapters = chapters.where((ch) => ch.chapterNumber == params.chapterNumber).toList();
  
  if (matchingChapters.isEmpty) {
    print('📚 DEBUG: No chapters found for number ${params.chapterNumber}. Available: ${chapters.map((c) => c.chapterNumber).toSet().join(", ")}');
    return [];
  }

  print('📚 DEBUG: Found ${matchingChapters.length} matching chapters for number ${params.chapterNumber}');
  matchingChapters.forEach((ch) => print('   - ID: ${ch.id}, Status: ${ch.status}'));
  
  return matchingChapters;
});

// Provider to fetch visuals for the current chapter(s)
final currentChapterVisualsProvider = FutureProvider.family.autoDispose<List<GeneratedVisual>, ({String bookTitle, int chapterNumber})>((ref, params) async {
  print('📚 DEBUG: Fetching visuals for chapter ${params.chapterNumber} of "${params.bookTitle}"');

  final chaptersAsync = await ref.watch(currentChapterProvider(params).future);
  if (chaptersAsync.isEmpty) {
    print('📚 DEBUG: No matching chapters found, returning empty visuals list');
    return [];
  }

  final chapterIds = chaptersAsync.map((ch) => ch.id).toList();
  final service = ref.watch(appwriteServiceProvider);
  
  try {
    print('📚 DEBUG: calling getGeneratedVisualsForChapters with IDs: $chapterIds');
    // Use the bulk fetch method to check all candidate chapters
    final visuals = await service.getGeneratedVisualsForChapters(chapterIds);
    print('📚 DEBUG: Retrieved ${visuals.length} visuals total');
    return visuals;
  } catch (e) {
    print('📚 DEBUG: Error fetching visuals for chapters: $e');
    rethrow;
  }
});

class BookVisualizationOverlay extends ConsumerWidget {
  final String bookTitleForLookup;
  final String? localBookISBN;
  final int localChapterNumber;
  final String localChapterContent;
  final VoidCallback onClose;

  const BookVisualizationOverlay({
    super.key,
    required this.bookTitleForLookup,
    this.localBookISBN,
    required this.localChapterNumber,
    required this.localChapterContent,
    required this.onClose,
  });

  // Add debug prints without modifying the constructor
  void _debugPrintInfo() {
    print('📚 DEBUG: BookVisualizationOverlay initialized');
    print('📚 DEBUG: Book Title: $bookTitleForLookup');
    print('📚 DEBUG: Chapter Number: $localChapterNumber');
    print('📚 DEBUG: ISBN: ${localBookISBN ?? "Not provided"}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _debugPrintInfo();
    print('📚 DEBUG: Building BookVisualizationOverlay');

    final appwriteBookAsyncValue = ref.watch(bookDetailsByTitleProvider(bookTitleForLookup));
    final isGenerating = ref.watch(generationLoadingProvider);

    print('📚 DEBUG: Generation status - isGenerating: $isGenerating');

    appwriteBookAsyncValue.whenData((book) {
      print('📚 DEBUG: Appwrite book lookup result: ${book?.title ?? "Not found"}');
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: _withOpacity(Colors.black, 0.0),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: LiquidGlassContainer(
          borderRadius: BorderRadius.circular(20.0),
          padding: EdgeInsets.zero,
          backgroundColor: _withOpacity(Theme.of(context).colorScheme.surface, 0.1),
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 40),
                  Expanded(
                    child: appwriteBookAsyncValue.when(
                      data: (appwriteBook) {
                        if (appwriteBook == null) {
                          return _buildGenerationRequestUI(context, ref, isGenerating);
                        } else {
                          // Use chapter-scoped provider
                          return _buildChapterVisualsDisplay(context, ref, appwriteBook.title);
                        }
                      },
                      loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
                      error: (error, stack) => Center(
                        child: _buildErrorWidget(context, "Error looking up book: $error", () {
                          ref.invalidate(bookDetailsByTitleProvider(bookTitleForLookup));
                        }),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: onClose,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the visuals display for the current chapter with sticky section headers
  Widget _buildChapterVisualsDisplay(BuildContext context, WidgetRef ref, String bookTitle) {
    print('📚 DEBUG: Building chapter visuals display for chapter $localChapterNumber');

    final params = (bookTitle: bookTitle, chapterNumber: localChapterNumber);
    final visualsAsyncValue = ref.watch(currentChapterVisualsProvider(params));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Chapter $localChapterNumber Visualizations',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: _withOpacity(Colors.black, 0.3),
                  blurRadius: 5,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: visualsAsyncValue.when(
            data: (visuals) {
              if (visuals.isEmpty) {
                return _buildEmptyState(context);
              }

              // Separate visuals by type
              print('📚 DEBUG: Processing ${visuals.length} visuals');
              // Safely print the list of types for debugging
              print('📚 DEBUG: Type values found: ${visuals.map((v) => v.type).toList()}');

              // Log each visual individually for detailed inspection
              for (var i = 0; i < visuals.length; i++) {
                final v = visuals[i];
                print('📚 DEBUG: Visual $i - Type: "${v.type}", Entity: "${v.entityName}", isScene: ${v.isScene}, isCharacter: ${v.isCharacter}');
              }
              
              // Filter visuals by type (now handles IMAGE type via entityName patterns)
              final scenes = visuals.where((v) => v.isScene).toList();
              final characters = visuals.where((v) => v.isCharacter).toList();
              
              print('📚 DEBUG: Filtered - ${scenes.length} scenes, ${characters.length} characters');

              return _buildSectionsScrollView(context, ref, scenes, characters);
            },
            loading: () => _buildShimmerLoading(context),
            error: (error, stack) => Center(
              child: _buildErrorWidget(context, "Failed to load visuals: $error", () {
                ref.invalidate(currentChapterVisualsProvider(params));
              }),
            ),
          ),
        ),
      ],
    );
  }

  /// Build scrollable sections with sticky headers for scenes and characters
  Widget _buildSectionsScrollView(BuildContext context, WidgetRef ref, List<GeneratedVisual> scenes, List<GeneratedVisual> characters) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid: 2 columns on mobile, 3 on tablets/wide screens
        final crossAxisCount = constraints.maxWidth >= 600 ? 3 : 2;

        return CustomScrollView(
          slivers: [
            // Scenes Section
            _buildStickyHeader(context, 'Scenes', Icons.landscape, scenes.length),
            if (scenes.isEmpty)
              _buildEmptySectionPlaceholder(context, 'No scenes in this chapter')
            else
              _buildImageGrid(context, ref, scenes, crossAxisCount),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Characters Section
            _buildStickyHeader(context, 'Characters', Icons.people, characters.length),
            if (characters.isEmpty)
              _buildEmptySectionPlaceholder(context, 'No characters in this chapter')
            else
              _buildImageGrid(context, ref, characters, crossAxisCount),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        );
      },
    );
  }

  /// Build sticky section header
  Widget _buildStickyHeader(BuildContext context, String title, IconData icon, int count) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickyHeaderDelegate(
        minHeight: 60,
        maxHeight: 60,
        child: LiquidGlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          backgroundColor: _withOpacity(Theme.of(context).colorScheme.surface, 0.15),
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _withOpacity(Theme.of(context).colorScheme.secondary, 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build responsive image grid
  Widget _buildImageGrid(BuildContext context, WidgetRef ref, List<GeneratedVisual> visuals, int crossAxisCount) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 3 / 4, // Portrait aspect ratio
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final visual = visuals[index];
            return _buildImageCard(context, ref, visual);
          },
          childCount: visuals.length,
        ),
      ),
    );
  }

  /// Build individual image card with description overlay
  Widget _buildImageCard(BuildContext context, WidgetRef ref, GeneratedVisual visual) {
    final appwriteService = ref.read(appwriteServiceProvider);
    final imageUrl = appwriteService.getImageUrl(visual.imageFileId);

    return Hero(
      tag: 'visual_${visual.id}',
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (context, animation, secondaryAnimation) =>
                  ImageDetailDialog(
                    tag: 'visual_${visual.id}',
                    imageUrl: imageUrl,
                    title: visual.entityName,
                    description: visual.prompt,
                    detail1Label: 'Type',
                    detail1: visual.type,
                    detail2Label: 'Visual ID',
                    detail2: visual.id,
                  ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        },
        child: LiquidGlassContainer(
          padding: EdgeInsets.zero,
          backgroundColor: _withOpacity(Colors.white, 0.1),
          borderRadius: BorderRadius.circular(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _buildImagePlaceholder(),
                  errorWidget: (context, url, error) => _buildImageErrorCard(context, () {
                    // Retry single image by invalidating cache
                    CachedNetworkImage.evictFromCache(imageUrl);
                    // Trigger rebuild
                    (context as Element).markNeedsBuild();
                  }),
                ),
                // Gradient overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          _withOpacity(Colors.black, 0.8),
                          _withOpacity(Colors.black, 0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      visual.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            color: _withOpacity(Colors.black, 0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build empty state when no visuals exist for the chapter
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: LiquidGlassContainer(
          padding: const EdgeInsets.all(24),
          backgroundColor: _withOpacity(Colors.white, 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.image_not_supported_outlined,
                size: 64,
                color: _withOpacity(Colors.white, 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No Visualizations Yet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Generate visuals for this chapter to see scenes and characters come to life.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build empty section placeholder
  Widget _buildEmptySectionPlaceholder(BuildContext context, String message) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LiquidGlassContainer(
          padding: const EdgeInsets.all(16),
          backgroundColor: _withOpacity(Colors.white, 0.05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, color: _withOpacity(Colors.white, 0.5), size: 20),
              const SizedBox(width: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _withOpacity(Colors.white, 0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build image placeholder (shimmer)
  Widget _buildImagePlaceholder() {
    return Container(
      color: _withOpacity(Colors.white, 0.1),
      child: Center(
        child: CircularProgressIndicator(
          color: _withOpacity(Colors.white, 0.5),
          strokeWidth: 2,
        ),
      ),
    );
  }

  /// Build image error card with tap to retry
  Widget _buildImageErrorCard(BuildContext context, VoidCallback onRetry) {
    return GestureDetector(
      onTap: onRetry,
      child: LiquidGlassContainer(
        padding: const EdgeInsets.all(16),
        backgroundColor: _withOpacity(Colors.red, 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_outlined,
              size: 40,
              color: _withOpacity(Colors.white, 0.7),
            ),
            const SizedBox(height: 8),
            Text(
              "Couldn't load image",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _withOpacity(Colors.white, 0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to retry',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _withOpacity(Colors.white, 0.5),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerationRequestUI(BuildContext context, WidgetRef ref, bool isGenerating) {
    print('📚 DEBUG: Building generation request UI, isGenerating: $isGenerating');
    final appwriteService = ref.read(appwriteServiceProvider);

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
          Icon(
            isGenerating ? Icons.hourglass_empty : Icons.auto_awesome,
            size: 80,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 24),
          Text(
            isGenerating
                ? 'Generating Visuals...'
                : 'Visualizations for Chapter $localChapterNumber not found.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            isGenerating
                ? 'Processing chapter, extracting entities, generating images, and uploading to Appwrite.\n\nThis may take 1-2 minutes...'
                : 'Would you like to generate visuals for this chapter?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 32),
          isGenerating
              ? Column(
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary,
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Curating scenes for this chapter...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white60,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          )
              : ElevatedButton.icon(
            onPressed: () async {
              ref.read(generationLoadingProvider.notifier).state = true;

              try {
                print('📚 DEBUG: Starting generation request from UI');
                print('📚 DEBUG: Using ISBN: ${localBookISBN ?? "Not available"}');

                final result = await appwriteService.requestVisualGeneration(
                  bookTitle: bookTitleForLookup,
                  bookISBN: localBookISBN,
                  chapterNumber: localChapterNumber,
                  chapterContent: localChapterContent,
                );

                print('📚 DEBUG: Received result: $result');

                if (result['success'] == true) {
                  // Success - extract analytics if available
                  final analysis = result['analysis'] as Map<String, dynamic>?;
                  final durationSec = analysis?['pipeline']?['duration_sec'] as num?;
                  final chapterId = result['chapter_id'] as String?;

                  final successMessage = durationSec != null
                      ? '✓ Visuals generated in ${durationSec.toInt()} seconds!'
                      : '✓ Visuals generated successfully!';

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(successMessage),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 3),
                    ),
                  );

                  print('📚 DEBUG: Chapter ID: $chapterId');
                  print('📚 DEBUG: Invalidating provider to refresh UI');

                  // Invalidate to trigger immediate refresh to visuals display
                  ref.invalidate(bookDetailsByTitleProvider(bookTitleForLookup));
                  ref.invalidate(currentChapterVisualsProvider((bookTitle: bookTitleForLookup, chapterNumber: localChapterNumber)));

                } else {
                  // Failure - show specific error
                  final errorMessage = result['error'] as String? ?? 'Unknown error occurred';
                  final errorCode = result['error_code'] as String? ?? 'UNKNOWN';

                  print('📚 DEBUG: Generation failed - Code: $errorCode, Message: $errorMessage');

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✗ Generation failed: $errorMessage'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 5),
                      action: SnackBarAction(
                        label: 'Retry',
                        textColor: Colors.white,
                        onPressed: () {
                          // User can tap generate button again
                        },
                      ),
                    ),
                  );
                }
              } catch (e) {
                print('📚 DEBUG: Exception during generation: $e');

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✗ Error: $e'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 5),
                  ),
                );
              } finally {
                ref.read(generationLoadingProvider.notifier).state = false;
              }
            },
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate Visuals for this Chapter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        CircularProgressIndicator(
          color: Theme.of(context).colorScheme.secondary,
          strokeWidth: 3,
        ),
        const SizedBox(height: 24),
        Text(
          'Curating scenes for this chapter...',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white70,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 40),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >= 600 ? 3 : 2;
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 3 / 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 6, // Show 6 shimmer placeholders
                itemBuilder: (context, index) {
                  return LiquidGlassContainer(
                    padding: EdgeInsets.zero,
                    backgroundColor: _withOpacity(Colors.white, 0.05),
                    borderRadius: BorderRadius.circular(12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          Container(
                            color: _withOpacity(Colors.white, 0.1),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    _withOpacity(Colors.black, 0.6),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Container(
                                height: 16,
                                decoration: BoxDecoration(
                                  color: _withOpacity(Colors.white, 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message, VoidCallback onRetry) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, color: Colors.red.shade300, size: 50),
        const SizedBox(height: 10),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red.shade300, fontSize: 16),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: onRetry,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          child: const Text('Retry'),
        ),
      ],
    );
  }
}

/// Delegate for sticky section headers
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _StickyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
