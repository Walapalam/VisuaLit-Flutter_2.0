import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/Cart/presentation/CartNotifier.dart';
import 'package:visualit/features/library/presentation/library_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:visualit/core/theme/theme_extensions.dart';
import 'package:device_info_plus/device_info_plus.dart';


class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final Set<int> downloadingIds = {};

  Future<bool> _isBookDownloaded(String title) async {
    Directory? downloadsDir;
    if (Platform.isAndroid) {
      downloadsDir = Directory('/storage/emulated/0/Download');
    } else {
      downloadsDir = await getDownloadsDirectory();
    }
    if (downloadsDir == null) return false;
    final visuaLitDir = Directory('${downloadsDir.path}/VisuaLit');
    final file = File('${visuaLitDir.path}/$title.epub');
    return file.exists();
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;

      if (androidInfo.version.sdkInt >= 30) {
        // Android 11+ requires MANAGE_EXTERNAL_STORAGE
        final status = await Permission.manageExternalStorage.request();
        return status.isGranted;
      } else {
        // Android 10 and below
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    return true; // iOS doesn't need these permissions for app documents
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
        child:cartBooks.isEmpty
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
                      downloadingIds.contains(bookId)
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : IconButton(
                        icon: const Icon(Icons.download, color: Colors.blue),
                        onPressed: () async {
                          setState(() => downloadingIds.add(bookId));
                          try {
                            final downloadUrl = book['formats']['application/epub+zip'];
                            if (downloadUrl == null) {
                              throw Exception('Download URL not available');
                            }

                            final status = await _requestStoragePermission();
                            if (!status) {
                              throw Exception('Storage permission denied. Some Error');
                            }

                            Directory? downloadsDir;
                            if (Platform.isAndroid) {
                              downloadsDir = Directory('/storage/emulated/0/Download');
                            } else {
                              downloadsDir = await getDownloadsDirectory();
                            }
                            if (downloadsDir == null) throw Exception('Cannot access Downloads folder');

                            final visuaLitDir = Directory('${downloadsDir.path}/VisuaLit');
                            if (!await visuaLitDir.exists()) {
                              await visuaLitDir.create(recursive: true);
                            }

                            final fileName = '$bookTitle.epub';
                            final filePath = '${visuaLitDir.path}/$fileName';
                            final file = File(filePath);

                            final response = await http.get(Uri.parse(downloadUrl));
                            if (response.statusCode == 200) {
                              await file.writeAsBytes(response.bodyBytes);

                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$bookTitle saved to VisuaLit folder in Downloads')),
                              );
                              setState(() {}); // Refresh UI to hide download button
                            } else {
                              throw Exception('Failed to download the book');
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error downloading $bookTitle: $e')),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => downloadingIds.remove(bookId));
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
                            content: const Text('Are you sure you want to delete this book from the cart?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  ref.read(cartProvider.notifier).removeBook(book);
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
