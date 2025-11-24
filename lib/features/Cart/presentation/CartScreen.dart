import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/Cart/presentation/CartNotifier.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:visualit/features/home/presentation/widgets/home_background.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/core/theme/theme_extensions.dart';
import 'package:visualit/core/services/toast_service.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final Map<int, double> _downloadProgress = {};

  Future<Directory?> _getAppLibraryDir() async {
    try {
      if (Platform.isAndroid) {
        final dir = await getExternalStorageDirectory();
        if (dir == null) return null;
        final visuaLitDir = Directory('${dir.path}/VisuaLit/books');
        if (!await visuaLitDir.exists()) {
          await visuaLitDir.create(recursive: true);
        }
        return visuaLitDir;
      } else {
        final base = await getApplicationDocumentsDirectory();
        final visuaLitDir = Directory('${base.path}/VisuaLit/books');
        if (!await visuaLitDir.exists()) {
          await visuaLitDir.create(recursive: true);
        }
        return visuaLitDir;
      }
    } catch (_) {
      return null;
    }
  }

  Future<bool> _isBookDownloaded(String title) async {
    final dir = await _getAppLibraryDir();
    if (dir == null) return false;
    final safeTitle = _sanitizeFileName(title);
    final file = File('${dir.path}/$safeTitle.epub');
    return file.exists();
  }

  String _sanitizeFileName(String name) {
    final invalidChars = RegExp(r'[<>:"/\\|?*]');
    return name.replaceAll(invalidChars, '_').trim();
  }

  Future<void> _downloadBook(Map<String, dynamic> book) async {
    final bookId = book['id'];
    final bookTitle = book['title']?.toString() ?? 'book';
    final downloadUrl = book['formats']?['application/epub+zip']?.toString();

    if (downloadUrl == null) {
      throw Exception('Download URL not available');
    }

    final targetDir = await _getAppLibraryDir();
    if (targetDir == null) {
      throw Exception('Cannot access app library');
    }

    final safeTitle = _sanitizeFileName(bookTitle);
    final filePath = '${targetDir.path}/$safeTitle.epub';
    final file = File(filePath);

    final client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(downloadUrl));
      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw Exception('Failed to download the book');
      }

      final contentLength = response.contentLength ?? 0;
      var downloaded = 0;
      final List<int> bytes = [];

      await for (final chunk in response.stream) {
        bytes.addAll(chunk);
        downloaded += chunk.length;
        if (contentLength > 0) {
          setState(() {
            _downloadProgress[bookId] = downloaded / contentLength;
          });
        }
      }

      await file.writeAsBytes(bytes);
    } finally {
      client.close();
      if (mounted) {
        setState(() {
          _downloadProgress.remove(bookId);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartBooks = ref.watch(cartProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/marketplace');
          },
        ),
        title: Text(
          'Cart',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: HomeBackground()),
          Padding(
            padding: context.screenPadding,
            child: cartBooks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 80,
                          color: AppTheme.primaryGreen.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Your cart is empty',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: cartBooks.length,
                    itemBuilder: (context, index) {
                      final book = cartBooks[index];
                      final bookId = book['id'];
                      final bookTitle = book['title'] ?? 'book';
                      final progress = _downloadProgress[bookId];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: book['formats']['image/jpeg'] != null
                                  ? Image.network(
                                      book['formats']['image/jpeg'],
                                      width: 60,
                                      height: 90,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 60,
                                      height: 90,
                                      color: AppTheme.darkGrey,
                                      child: Icon(
                                        Icons.book,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bookTitle,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    book['author'] ?? 'Unknown Author',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            FutureBuilder<bool>(
                              future: _isBookDownloaded(bookTitle),
                              builder: (context, snapshot) {
                                final isDownloaded = snapshot.data ?? false;
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (!isDownloaded)
                                      progress != null
                                          ? SizedBox(
                                              width: 32,
                                              height: 32,
                                              child: CircularProgressIndicator(
                                                value: progress,
                                                strokeWidth: 3,
                                                color: AppTheme.primaryGreen,
                                              ),
                                            )
                                          : IconButton(
                                              icon: Icon(
                                                Icons.download,
                                                color: Colors.blue,
                                              ),
                                              onPressed: () async {
                                                setState(
                                                  () =>
                                                      _downloadProgress[bookId] =
                                                          0.0,
                                                );
                                                try {
                                                  await _downloadBook(book);
                                                  if (mounted) {
                                                    ToastService.show(
                                                      context,
                                                      '$bookTitle downloaded',
                                                      type: ToastType.success,
                                                    );
                                                  }
                                                } catch (e) {
                                                  if (mounted) {
                                                    ToastService.show(
                                                      context,
                                                      'Error: $e',
                                                      type: ToastType.error,
                                                    );
                                                    setState(
                                                      () => _downloadProgress
                                                          .remove(bookId),
                                                    );
                                                  }
                                                }
                                              },
                                            )
                                    else
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () {
                                        ref
                                            .read(cartProvider.notifier)
                                            .removeBook(book);
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
