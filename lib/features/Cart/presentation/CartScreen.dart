import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/Cart/presentation/CartNotifier.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:visualit/core/theme/theme_extensions.dart';

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
        final visuaLitDir = Directory('${dir.path}/VisuaLit');
        if (!await visuaLitDir.exists()) {
          await visuaLitDir.create(recursive: true);
        }
        return visuaLitDir;
      } else {
        final base = await getApplicationDocumentsDirectory();
        final visuaLitDir = Directory('${base.path}/VisuaLit');
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

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$bookTitle saved to Library')));
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.goNamed('marketplace');
          },
        ),
        title: const Text('Cart'),
      ),
      body: Padding(
        padding: context.screenPadding,
        child: cartBooks.isEmpty
            ? const Center(
                child: Text(
                  'No books in the cart',
                  style: TextStyle(fontSize: 18),
                ),
              )
            : ListView.builder(
                itemCount: cartBooks.length,
                itemBuilder: (context, index) {
                  final book = cartBooks[index];
                  final bookId = book['id'];
                  final bookTitle = book['title'] ?? 'book';
                  final progress = _downloadProgress[bookId];

                  return ListTile(
                    leading: book['formats']['image/jpeg'] != null
                        ? Image.network(
                            book['formats']['image/jpeg'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.book),
                    title: Text(bookTitle),
                    trailing: FutureBuilder<bool>(
                      future: _isBookDownloaded(bookTitle),
                      builder: (context, snapshot) {
                        final isDownloaded = snapshot.data ?? false;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isDownloaded)
                              progress != null
                                  ? Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          value: progress,
                                          strokeWidth: 3,
                                        ),
                                        Text(
                                          '${(progress * 100).toInt()}%',
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      ],
                                    )
                                  : IconButton(
                                      icon: const Icon(
                                        Icons.download,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () async {
                                        setState(
                                          () => _downloadProgress[bookId] = 0.0,
                                        );
                                        try {
                                          await _downloadBook(book);
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Error downloading ${book['title']}: $e',
                                                ),
                                              ),
                                            );
                                            setState(
                                              () => _downloadProgress.remove(
                                                bookId,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Book'),
                                    content: const Text(
                                      'Are you sure you want to delete this book from the cart?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          ref
                                              .read(cartProvider.notifier)
                                              .removeBook(book);
                                          Navigator.of(context).pop();
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
