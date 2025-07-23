import 'package:cached_network_image/cached_network_image.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:visualit/data/models/book.dart';
  import 'package:visualit/data/models/chapter.dart';
  import 'package:visualit/data/models/generated_visual.dart';
  import 'package:visualit/data/services/appwrite_service.dart';
  import 'package:visualit/features/reader/presentation/widgets/image_detail_dialog.dart';
  import 'package:visualit/features/reader/presentation/widgets/liquid_glass_container.dart';
  import 'package:flutter/foundation.dart';

  final generationLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);

  final bookDetailsByTitleProvider = FutureProvider.family<Book?, String>((ref, bookTitle) async {
    final service = ref.watch(appwriteServiceProvider);
    return service.getBookByTitle(bookTitle);
  });

  final chaptersForAppwriteBookProvider = FutureProvider.family<List<Chapter>, String>((ref, appwriteBookId) async {
    final service = ref.watch(appwriteServiceProvider);
    return service.getChaptersForBook(appwriteBookId);
  });

  final generatedVisualsForAppwriteBookProvider = FutureProvider.family<List<GeneratedVisual>, String>((ref, appwriteBookId) async {
    final chaptersAsync = ref.watch(chaptersForAppwriteBookProvider(appwriteBookId));
    return chaptersAsync.when(
      data: (chapters) async {
        if (chapters.isEmpty) return [];
        final chapterIds = chapters.map((c) => c.id).toList();
        final service = ref.watch(appwriteServiceProvider);
        return service.getGeneratedVisualsForChapters(chapterIds);
      },
      loading: () => [],
      error: (err, stack) {
        debugPrint('Error loading chapters for visuals: $err');
        throw Exception('Error loading chapters for visuals: $err');
      },
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

    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final appwriteBookAsyncValue = ref.watch(bookDetailsByTitleProvider(bookTitleForLookup));
      final isGenerating = ref.watch(generationLoadingProvider);

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
                      return _buildGenerationRequestUI(context, ref, isGenerating);
                    } else {
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
            appwriteBook?.title ?? 'Visualizations',
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
      final visualsAsyncValue = ref.watch(generatedVisualsForAppwriteBookProvider(appwriteBookId));

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

    Widget _buildGenerationRequestUI(BuildContext context, WidgetRef ref, bool isGenerating) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No visuals found for this book.\nWould you like to request generation?',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isGenerating ? null : () {
                ref.read(generationLoadingProvider.notifier).state = true;
                debugPrint('Generation request sent for chapter $localChapterNumber');
                Future.delayed(const Duration(seconds: 2), () {
                  ref.read(generationLoadingProvider.notifier).state = false;
                });
              },
              child: isGenerating
                  ? const CircularProgressIndicator()
                  : const Text('Request Generation'),
            ),
          ],
        ),
      );
    }
  }