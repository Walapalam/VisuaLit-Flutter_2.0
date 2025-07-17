import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/data/highlight.dart';
import 'package:visualit/features/reader/presentation/highlights_provider.dart';
import 'package:visualit/features/reader/presentation/reading_controller.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';

class HtmlContentWidget extends ConsumerStatefulWidget {
  final ContentBlock block;
  final int blockIndex;
  final Size viewSize;

  const HtmlContentWidget({
    super.key,
    required this.block,
    required this.blockIndex,
    required this.viewSize,
  });

  @override
  ConsumerState<HtmlContentWidget> createState() => _HtmlContentWidgetState();
}

class _HtmlContentWidgetState extends ConsumerState<HtmlContentWidget> {
  double _scale = 1.0;
  double _baseScale = 1.0;

  @override
  void initState() {
    super.initState();
    debugPrint("[DEBUG] HtmlContentWidget: Initializing for block ${widget.blockIndex} (type: ${widget.block.blockType})");
  }

  @override
  Widget build(BuildContext context) {
    try {
      debugPrint("[DEBUG] HtmlContentWidget: Building widget for block ${widget.blockIndex} (type: ${widget.block.blockType})");

      // Check for null bookId
      if (widget.block.bookId == null) {
        debugPrint("[ERROR] HtmlContentWidget: Block has null bookId");
        return _buildErrorWidget("Block has no book ID");
      }

      final preferences = ref.watch(readingPreferencesProvider);
      final highlightsAsync = ref.watch(highlightsProvider(widget.block.bookId!));

      // Handle image blocks
      if (widget.block.blockType == BlockType.img) {
        return _buildImageWidget(preferences);
      }

      // Handle empty content
      if (widget.block.htmlContent == null || widget.block.htmlContent!.trim().isEmpty) {
        debugPrint("[WARN] HtmlContentWidget: Empty HTML content for block ${widget.blockIndex}");
        return const SizedBox.shrink();
      }

      // Process highlights
      List<Highlight> blockHighlights = [];
      if (highlightsAsync.hasValue) {
        blockHighlights = highlightsAsync.value!.where((h) =>
          h.blockIndexInChapter == widget.block.blockIndexInChapter &&
          h.chapterIndex == widget.block.chapterIndex
        ).toList();

        if (blockHighlights.isNotEmpty) {
          debugPrint("[DEBUG] HtmlContentWidget: Found ${blockHighlights.length} highlights for block ${widget.blockIndex}");
          blockHighlights.sort((a, b) => a.startOffset.compareTo(b.startOffset));
        }
      } else if (highlightsAsync.hasError) {
        debugPrint("[ERROR] HtmlContentWidget: Error loading highlights: ${highlightsAsync.error}");
      }

      // Render HTML content
      return _buildHtmlWidget(preferences, blockHighlights);
    } catch (e, stack) {
      debugPrint("[ERROR] HtmlContentWidget: Unhandled error in build: $e");
      debugPrintStack(stackTrace: stack);
      return _buildErrorWidget("Error: ${e.toString().substring(0, e.toString().length.clamp(0, 50))}...");
    }
  }

  // Build the image widget with proper error handling and scaling
  Widget _buildImageWidget(ReadingPreferences preferences) {
    debugPrint("[DEBUG] HtmlContentWidget: Building image widget for block ${widget.blockIndex}");

    // Check if we have image bytes
    if (widget.block.imageBytes == null || widget.block.imageBytes!.isEmpty) {
      debugPrint("[WARN] HtmlContentWidget: Image block has no image bytes");
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_not_supported, color: Colors.grey.shade400, size: 48),
            const SizedBox(height: 8),
            Text(
              "Missing image",
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    debugPrint("[DEBUG] HtmlContentWidget: Rendering image with ${widget.block.imageBytes!.length} bytes");

    return GestureDetector(
      onScaleStart: (details) {
        _baseScale = _scale;
      },
      onScaleUpdate: (details) {
        setState(() {
          _scale = (_baseScale * details.scale).clamp(0.8, 3.0);
        });
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate appropriate image size based on container constraints
          final maxWidth = constraints.maxWidth;
          final maxHeight = widget.viewSize.height * 0.6;

          return Transform.scale(
            scale: _scale,
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: maxWidth,
                    maxHeight: maxHeight,
                  ),
                  child: Image.memory(
                    Uint8List.fromList(widget.block.imageBytes!),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint("[ERROR] HtmlContentWidget: Failed to render image: $error");
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.broken_image, color: Colors.red.shade300, size: 48),
                            const SizedBox(height: 8),
                            Text(
                              "Failed to load image",
                              style: TextStyle(color: Colors.red.shade300),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Build the HTML widget with proper error handling and scaling
  Widget _buildHtmlWidget(ReadingPreferences preferences, List<Highlight> blockHighlights) {
    debugPrint("[DEBUG] HtmlContentWidget: Building HTML widget for block ${widget.blockIndex}");

    // Use the already sanitized HTML content
    String htmlContent;
    try {
      // HTML content is already sanitized during processing
      htmlContent = widget.block.htmlContent!;

      // Add highlights if needed
      if (blockHighlights.isNotEmpty) {
        htmlContent = _injectHighlightTags(htmlContent, blockHighlights);
      }
    } catch (e) {
      debugPrint("[ERROR] HtmlContentWidget: Error processing HTML content: $e");
      htmlContent = widget.block.textContent ?? "Error processing content";
    }

    return GestureDetector(
      onScaleStart: (details) {
        _baseScale = _scale;
      },
      onScaleUpdate: (details) {
        setState(() {
          _scale = (_baseScale * details.scale).clamp(0.8, 3.0);
        });
      },
      child: Transform.scale(
        scale: _scale,
        alignment: Alignment.topLeft,
        child: SelectionArea(
          child: HtmlWidget(
            htmlContent,
            textStyle: preferences.getStyleForBlock(widget.block.blockType),
            customStylesBuilder: (element) {
              if (element.localName == 'highlight') {
                final colorValue = element.attributes['color'];
                if (colorValue != null) {
                  return {'background-color': colorValue};
                }
              }
              return null;
            },
            onTapUrl: (url) {
              try {
                debugPrint("[DEBUG] HtmlContentWidget: URL tapped: $url");
                if (widget.block.src != null && widget.block.bookId != null) {
                  ref.read(readingControllerProvider(widget.block.bookId!).notifier)
                     .jumpToHref(url, widget.block.src!);
                  return true;
                }
                debugPrint("[WARN] HtmlContentWidget: Cannot handle URL tap, missing src or bookId");
                return false;
              } catch (e) {
                debugPrint("[ERROR] HtmlContentWidget: Error handling URL tap: $e");
                return false;
              }
            },
            onErrorBuilder: (context, element, error) {
              debugPrint("[ERROR] HtmlContentWidget: Error rendering HTML element: $error");
              // Try to render just the text content of the element
              final elementText = element.text;
              if (elementText != null && elementText.isNotEmpty) {
                return Text(
                  elementText,
                  style: preferences.getStyleForBlock(widget.block.blockType),
                );
              }
              return Text(
                "Error rendering element",
                style: TextStyle(color: Colors.red.shade300),
              );
            },
            // Add rendering options to improve compatibility
            renderMode: RenderMode.column,
            enableCaching: true,
            buildAsync: true,
            // Add key to force rebuild when content changes
            key: ValueKey('html_${widget.blockIndex}_${widget.block.id}'),
          ),
        ),
      ),
    );
  }

  // Build a widget to display errors
  Widget _buildErrorWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        message,
        style: TextStyle(color: Colors.red.shade300),
      ),
    );
  }


  String _injectHighlightTags(String html, List<Highlight> highlights) {
    try {
      if (highlights.isEmpty) {
        return html;
      }

      debugPrint("[DEBUG] HtmlContentWidget: Injecting ${highlights.length} highlight tags into HTML");
      String result = html;
      int offset = 0;
      int successfulInjections = 0;

      for (final h in highlights) {
        try {
          final color = Color(h.color);
          final colorString = 'rgba(${color.red},${color.green},${color.blue},${(color.alpha / 255).toStringAsFixed(2)})';
          final startTag = '<highlight color="$colorString">';
          final endTag = '</highlight>';

          final start = h.startOffset + offset;
          final end = h.endOffset + offset;

          debugPrint("[DEBUG] HtmlContentWidget: Processing highlight at positions $start-$end");

          if (start >= 0 && end <= result.length && start < end) {
            result = result.substring(0, start) +
                startTag +
                result.substring(start, end) +
                endTag +
                result.substring(end);
            offset += startTag.length + endTag.length;
            successfulInjections++;
          } else {
            debugPrint("[WARN] HtmlContentWidget: Invalid highlight positions: start=$start, end=$end, htmlLength=${result.length}");
          }
        } catch (e) {
          debugPrint("[ERROR] HtmlContentWidget: Error processing highlight: $e");
        }
      }

      debugPrint("[DEBUG] HtmlContentWidget: Successfully injected $successfulInjections out of ${highlights.length} highlights");
      return result;
    } catch (e, stack) {
      debugPrint("[ERROR] HtmlContentWidget: Error injecting highlight tags: $e");
      debugPrintStack(stackTrace: stack);
      return html; // Return original HTML if there's an error
    }
  }
}
