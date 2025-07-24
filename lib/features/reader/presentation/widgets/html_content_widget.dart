import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:visualit/features/reader/data/book_data.dart';
import 'package:visualit/features/reader/presentation/reading_controller.dart';
import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';

class HtmlContentWidget extends ConsumerWidget {
  final ContentBlock block;
  final int blockIndex;
  final Size viewSize;

  const HtmlContentWidget({
    super.key,
    required this.block,
    required this.blockIndex,
    required this.viewSize,
  });

  String _generateOverrideCss(ReadingPreferences prefs) {
    final resetCss = """
      body, div, h1, h2, h3, h4, h5, h6, li, blockquote, td, th, a {
        font-family: '${prefs.fontFamily}' !important;
        font-size: ${prefs.fontSize}px !important;
        line-height: ${prefs.lineSpacing} !important;
        color: ${Color(prefs.textColor.value).toCss()} !important;
        background-color: transparent !important;
        text-align: left !important;
        margin: 0 !important;
        padding: 0 !important;
        text-indent: 0 !important;
      }
    """;

    final indentCss = """
      p {
        text-indent: ${prefs.textIndent}em !important;
        margin-bottom: 0.5em !important;
      }
    """;

    return resetCss + indentCss;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(readingPreferencesProvider);

    if (block.blockType == BlockType.img && block.imageBytes != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Image.memory(
          Uint8List.fromList(block.imageBytes!),
          fit: BoxFit.contain,
        ),
      );
    }

    if (block.htmlContent == null || block.htmlContent!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final injectedCss = _generateOverrideCss(preferences);
    final finalHtml = '<style>$injectedCss</style>${block.htmlContent!}';

    return HtmlWidget(
      finalHtml,
      textStyle: preferences.getStyleForBlock(block.blockType),
      onTapUrl: (url) {
        if (block.src != null && block.bookId != null) {
          // Note: jumpToHref requires the controller to be updated to support it.
          // For now, this feature is secondary to pagination.
          return true;
        }
        return false;
      },
    );
  }
}

extension ToCss on Color {
  String toCss() => 'rgba($red, $green, $blue, ${alpha / 255})';
}