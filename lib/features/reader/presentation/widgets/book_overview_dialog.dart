import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/data/models/book.dart'; // This is your Appwrite Book model
import 'package:visualit/data/models/chapter.dart';
import 'package:visualit/data/models/generated_visual.dart';
import 'package:visualit/data/services/appwrite_service.dart';
import 'package:visualit/features/reader/presentation/widgets/image_detail_dialog.dart';
import 'package:visualit/features/reader/presentation/widgets/liquid_glass_container.dart';

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

// FutureProvider to fetch chapters for a given Appwrite book ID
final chaptersForAppwriteBookProvider = FutureProvider.family<List<Chapter>, String>((ref, appwriteBookId) async {
  print('📚 DEBUG: Fetching chapters for book ID: $appwriteBookId');
  final service = ref.watch(appwriteServiceProvider);
  try {
    final chapters = await service.getChaptersForBook(appwriteBookId);
    print('📚 DEBUG: Found ${chapters.length} chapters for book ID: $appwriteBookId');
    return chapters;
  } catch (e) {
    print('📚 DEBUG: Error fetching chapters: $e');
    rethrow;
  }
});

// FutureProvider to fetch all generated visuals for a given Appwrite book (indirectly via chapters)
final generatedVisualsForAppwriteBookProvider = FutureProvider.family<List<GeneratedVisual>, String>((ref, appwriteBookId) async {
  print('📚 DEBUG: Starting visual fetch process for book ID: $appwriteBookId');
  final chaptersAsync = ref.watch(chaptersForAppwriteBookProvider(appwriteBookId));

  return chaptersAsync.when(
      data: (chapters) async {
        print('📚 DEBUG: Processing ${chapters.length} chapters for visuals');
        if (chapters.isEmpty) {
          print('📚 DEBUG: No chapters found, returning empty visuals list');
          return [];
        }
        final chapterIds = chapters.map((c) => c.id).toList();
        print('📚 DEBUG: Fetching visuals for chapter IDs: $chapterIds');
        final service = ref.watch(appwriteServiceProvider);
        try {
          final visuals = await service.getGeneratedVisualsForChapters(chapterIds);
          print('📚 DEBUG: Retrieved ${visuals.length} visuals for book ID: $appwriteBookId');
          return visuals;
        } catch (e) {
          print('📚 DEBUG: Error fetching visuals: $e');
          rethrow;
        }
      },
      loading: () {
        print('📚 DEBUG: Chapters still loading, returning empty visuals list');
        return [];
      },
      error: (err, stack) {
        print('📚 DEBUG: Error in chapters fetch: $err');
        print('📚 DEBUG: Stack trace: $stack');
        throw Exception('Error loading chapters for visuals: $err');
      }
  );
});

class BookOverviewDialog extends ConsumerWidget {
  final String bookTitleForLookup;
  final String? localBookISBN;
  final int localChapterNumber;
  final String localChapterContent;

  const BookOverviewDialog({
    super.key,
    required this.bookTitleForLookup,
    this.localBookISBN,
    required this.localChapterNumber,
    required this.localChapterContent,
  });

  // Add debug prints without modifying the constructor
  void _debugPrintInfo() {
    print('📚 DEBUG: BookOverviewDialog initialized');
    print('📚 DEBUG: Book Title: $bookTitleForLookup');
    print('📚 DEBUG: Chapter Number: $localChapterNumber');
    print('📚 DEBUG: ISBN: ${localBookISBN ?? "Not provided"}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Call debug prints at the start of build
    _debugPrintInfo();
    print('📚 DEBUG: Building BookOverviewDialog');

    final appwriteBookAsyncValue = ref.watch(bookDetailsByTitleProvider(bookTitleForLookup));
    final isGenerating = ref.watch(generationLoadingProvider);

    print('📚 DEBUG: Generation status - isGenerating: $isGenerating');

    appwriteBookAsyncValue.whenData((book) {
      print('📚 DEBUG: Appwrite book lookup result: ${book?.title ?? "Not found"}');
    });

    return Dialog.fullscreen(
      backgroundColor: Colors.transparent,
      child: LiquidGlassContainer(
        borderRadius: BorderRadius.zero,
        padding: EdgeInsets.zero,
        backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.1),
        child: Column(
          children: [
            _buildAppBar(context, appwriteBookAsyncValue),
            Expanded(
              child: appwriteBookAsyncValue.when(
                data: (appwriteBook) {
                  if (appwriteBook == null) {
                    // Scenario B: Book NOT found in Appwrite, show generation UI
                    return _buildGenerationRequestUI(context, ref, isGenerating);
                  } else {
                    // Scenario A: Book found in Appwrite, now load its visuals
                    return _buildVisualsDisplay(context, ref, appwriteBook.id, appwriteBook.title);
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
      ),
    );
  }


  AppBar _buildAppBar(BuildContext context, AsyncValue<Book?> appwriteBookAsyncValue) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: appwriteBookAsyncValue.when(
        data: (appwriteBook) => Text(
          appwriteBook?.title ?? 'Visualizations', // Use Appwrite book title if found
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
        ),
        loading: () => const Text('Loading Book...', style: TextStyle(color: Colors.white)),
        error: (error, stack) => const Text('Error', style: TextStyle(color: Colors.white)),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildVisualsDisplay(BuildContext context, WidgetRef ref, String appwriteBookId, String bookTitle) {
    print('📚 DEBUG: Building visuals display for book ID: $appwriteBookId');
    final visualsAsyncValue = ref.watch(generatedVisualsForAppwriteBookProvider(appwriteBookId));

    visualsAsyncValue.whenData((visuals) {
      print('📚 DEBUG: Loaded ${visuals.length} visuals for book');
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Visuals for "$bookTitle"',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
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
                return const Center(
                  child: Text('No visualizations found for this book yet. The backend might still be generating or failed to find relevant data.',
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                scrollDirection: Axis.horizontal,
                itemCount: visuals.length,
                itemBuilder: (context, index) {
                  final visual = visuals[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildVisualCard(context, visual),
                  );
                },
              );
            },
            loading: () => _buildShimmerLoading(context),
            error: (error, stack) => Center(
              child: _buildErrorWidget(context, "Failed to load visuals: $error", () {
                ref.invalidate(generatedVisualsForAppwriteBookProvider(appwriteBookId));
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVisualCard(BuildContext context, GeneratedVisual visual) {
    final appwriteService = ProviderScope.containerOf(context).read(appwriteServiceProvider);
    final imageUrl = appwriteService.getImageUrl(visual.imageFileId);

    return SizedBox(
      width: 150,
      height: 220,
      child: LiquidGlassContainer(
        padding: const EdgeInsets.all(8.0),
        backgroundColor: Colors.white.withOpacity(0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
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
                            detail1Label: 'Chapter ID',
                            detail1: visual.chapterId,
                            detail2Label: 'Visual ID',
                            detail2: visual.id,
                          ),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              visual.entityName,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerationRequestUI(BuildContext context, WidgetRef ref, bool isGenerating) {
    print('📚 DEBUG: Building generation request UI, isGenerating: $isGenerating');
    final appwriteService = ref.read(appwriteServiceProvider);

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
                : 'Visualizations for "$bookTitleForLookup" not found in Appwrite.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            isGenerating
                ? 'Processing chapter, extracting entities, generating images, and uploading to Appwrite.\n\nThis may take 1-2 minutes...'
                : 'Do you want to request the backend to generate them?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 32),
          isGenerating
              ? Column(
            children: [
              const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
              const SizedBox(height: 16),
              Text(
                'Please wait, backend is processing...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white60),
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
            label: const Text('Generate Visuals'),
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
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: LiquidGlassContainer(
            padding: const EdgeInsets.all(8.0),
            backgroundColor: Colors.white.withOpacity(0.05),
            child: SizedBox(
              width: 150,
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 80,
                    height: 12,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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