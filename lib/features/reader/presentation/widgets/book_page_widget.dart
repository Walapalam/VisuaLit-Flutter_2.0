import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:visualit/core/models/content_block_schema.dart';
import 'dart:typed_data';

/// A widget that displays a single page of a book.
class BookPageWidget extends StatelessWidget {
  /// The content blocks to display on this page.
  final List<ContentBlockSchema> blocks;

  /// The font settings to use for rendering text.
  final Map<String, dynamic> fontSettings;

  /// Constructor
  const BookPageWidget({
    Key? key,
    required this.blocks,
    required this.fontSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) {
      return const Center(
        child: Text('No content to display'),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: blocks.map((block) => _buildContentBlock(context, block)).toList(),
        ),
      ),
    );
  }

  /// Build a widget for a content block based on its type.
  Widget _buildContentBlock(BuildContext context, ContentBlockSchema block) {
    // Base text style for all content
    final baseTextStyle = TextStyle(
      fontSize: fontSettings['fontSize'] as double,
      fontFamily: fontSettings['fontFamily'] as String,
      height: fontSettings['lineSpacing'] as double,
    );

    switch (block.blockType) {
      case BlockType.h1:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: HtmlWidget(
            block.htmlContent,
            textStyle: baseTextStyle.copyWith(
              fontSize: (fontSettings['fontSize'] as double) * 1.5,
              fontWeight: FontWeight.bold,
            ),
            customStylesBuilder: (element) {
              return {'margin': '0', 'padding': '0'};
            },
          ),
        );
      case BlockType.h2:
        return Padding(
          padding: const EdgeInsets.only(bottom: 14.0),
          child: HtmlWidget(
            block.htmlContent,
            textStyle: baseTextStyle.copyWith(
              fontSize: (fontSettings['fontSize'] as double) * 1.4,
              fontWeight: FontWeight.bold,
            ),
            customStylesBuilder: (element) {
              return {'margin': '0', 'padding': '0'};
            },
          ),
        );
      case BlockType.h3:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: HtmlWidget(
            block.htmlContent,
            textStyle: baseTextStyle.copyWith(
              fontSize: (fontSettings['fontSize'] as double) * 1.3,
              fontWeight: FontWeight.bold,
            ),
            customStylesBuilder: (element) {
              return {'margin': '0', 'padding': '0'};
            },
          ),
        );
      case BlockType.h4:
      case BlockType.h5:
      case BlockType.h6:
        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: HtmlWidget(
            block.htmlContent,
            textStyle: baseTextStyle.copyWith(
              fontSize: (fontSettings['fontSize'] as double) * 1.2,
              fontWeight: FontWeight.bold,
            ),
            customStylesBuilder: (element) {
              return {'margin': '0', 'padding': '0'};
            },
          ),
        );
      case BlockType.img:
        if (block.imageBytes != null) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Image.memory(
                Uint8List.fromList(block.imageBytes!),
                fit: BoxFit.contain,
                width: double.infinity,
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      case BlockType.p:
      default:
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: HtmlWidget(
            block.htmlContent,
            textStyle: baseTextStyle,
            customStylesBuilder: (element) {
              return {'margin': '0', 'padding': '0'};
            },
          ),
        );
    }
  }
}
