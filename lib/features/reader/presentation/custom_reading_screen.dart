import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/features/reader/data/book_data.dart' as db;
import 'package:visualit/features/reader/presentation/widgets/reading_settings_panel.dart';

class CustomReadingScreen extends StatefulWidget {
  final db.Book book; // Change from int bookId to Book object
  const CustomReadingScreen({super.key, required this.book});

  @override
  State<CustomReadingScreen> createState() => _CustomReadingScreenState();
}

class _CustomReadingScreenState extends State<CustomReadingScreen> {
  static const platform = MethodChannel('custom_epub_reader');
  bool _isReaderInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeReader();
  }

  Future<void> _initializeReader() async {
    try {
      await platform.invokeMethod('initializeReader', {
        'bookPath': widget.book.epubFilePath,
        'bookId': widget.book.id,
        'title': widget.book.title ?? 'Unknown Title',
      });

      if (mounted) {
        setState(() {
          _isReaderInitialized = true;
        });
      }
    } catch (e) {
      print('Failed to initialize reader: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Custom app bar
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.book.title ?? 'Reading'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _openCustomSettings(),
          ),
        ],
      ),

      // Epub reader embedded as platform view
      body: _isReaderInitialized ? Stack(
        children: [
          // Platform view for epub reader
          AndroidView(
            viewType: 'epub_reader_view',
            creationParams: {
              'bookPath': widget.book.epubFilePath,
              'bookId': widget.book.id,
            },
            creationParamsCodec: const StandardMessageCodec(),
          ),

          // Custom overlay elements
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.brightness_6, color: Colors.white),
                    onPressed: () => _toggleTheme(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.text_fields, color: Colors.white),
                    onPressed: () => _openTextSettings(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ) : const Center(
        child: CircularProgressIndicator(),
      ),

      // Custom FAB for visualization
      floatingActionButton: _isReaderInitialized ? FloatingActionButton(
        onPressed: () => _openVisualization(),
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.analytics),
      ) : null,
    );
  }

  void _openVisualization() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Reading Visualization',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            // Add your visualization content here
            const Expanded(
              child: Center(
                child: Text('Visualization content goes here'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCustomSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ReadingSettingsPanel(),
    );
  }

  void _toggleTheme() {
    // Send message to native reader to toggle theme
    platform.invokeMethod('toggleTheme');
  }

  void _openTextSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ReadingSettingsPanel(),
    );
  }

  @override
  void dispose() {
    platform.invokeMethod('disposeReader');
    super.dispose();
  }
}
