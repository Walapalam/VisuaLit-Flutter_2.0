import 'dart:typed_data';

import 'package:epub_view/epub_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

/// A custom wrapper for EpubView that handles null values properly
/// and provides better scrolling and pagination functionality.
class SafeEpubView extends StatelessWidget {
  final EpubController controller;
  final ExternalLinkPressed? onExternalLinkPressed;
  final bool shrinkWrap;
  final void Function(EpubChapterViewValue? value)? onChapterChanged;
  final void Function(EpubBook document)? onDocumentLoaded;
  final void Function(Exception? error)? onDocumentError;

  const SafeEpubView({
    Key? key,
    required this.controller,
    this.onExternalLinkPressed,
    this.onChapterChanged,
    this.onDocumentLoaded,
    this.onDocumentError,
    this.shrinkWrap = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EpubView(
      controller: controller,
      onExternalLinkPressed: onExternalLinkPressed,
      onChapterChanged: onChapterChanged,
      onDocumentLoaded: onDocumentLoaded,
      onDocumentError: onDocumentError,
      shrinkWrap: shrinkWrap,
      builders: EpubViewBuilders<DefaultBuilderOptions>(
        options: const DefaultBuilderOptions(),
        chapterBuilder: (context, builders, document, chapters, paragraphs, index, chapterIndex, paragraphIndex, onExternalLinkPressed) {
          if (paragraphs.isEmpty) {
            return Container();
          }

          final defaultBuilder = builders as EpubViewBuilders<DefaultBuilderOptions>;
          final options = defaultBuilder.options;

          return Column(
            children: <Widget>[
              if (chapterIndex >= 0 && paragraphIndex == 0)
                builders.chapterDividerBuilder(chapters[chapterIndex]),
              Html(
                data: paragraphs[index].element.outerHtml,
                onLinkTap: (href, _, __) => onExternalLinkPressed(href!),
                style: {
                  'html': Style(
                    padding: HtmlPaddings.only(
                      top: (options.paragraphPadding as EdgeInsets?)?.top,
                      right: (options.paragraphPadding as EdgeInsets?)?.right,
                      bottom: (options.paragraphPadding as EdgeInsets?)?.bottom,
                      left: (options.paragraphPadding as EdgeInsets?)?.left,
                    ),
                  ).merge(Style.fromTextStyle(options.textStyle)),
                },
                extensions: [
                  TagExtension(
                    tagsToExtend: {"img"},
                    builder: (imageContext) {
                      try {
                        final url = imageContext.attributes['src'];
                        if (url == null) {
                          return const SizedBox(); // No src attribute
                        }
                        
                        final cleanUrl = url.replaceAll('../', '');
                        
                        // Safe null checks for all properties
                        if (document.Content == null || 
                            document.Content!.Images == null || 
                            !document.Content!.Images!.containsKey(cleanUrl) ||
                            document.Content!.Images![cleanUrl] == null ||
                            document.Content!.Images![cleanUrl]!.Content == null) {
                          return const SizedBox(); // Return empty widget if any part is null
                        }
                        
                        final content = Uint8List.fromList(
                            document.Content!.Images![cleanUrl]!.Content!);
                        
                        return Image(
                          image: MemoryImage(content),
                        );
                      } catch (e) {
                        debugPrint("Error rendering image: $e");
                        return const SizedBox(); // Return empty widget on error
                      }
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}