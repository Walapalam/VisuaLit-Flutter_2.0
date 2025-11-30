import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:flutter_html_svg/flutter_html_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/custom_reader/application/epub_parser_service.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/features/custom_reader/presentation/reading_preferences_controller.dart';

class ChapterContent extends ConsumerWidget {
  final EpubChapter chapter;
  final String chapterHref;
  final Map<String, Style> htmlStyles;
  final Widget Function(String src, String chapterHref) imageBuilder;

  const ChapterContent({
    super.key,
    required this.chapter,
    required this.chapterHref,
    required this.htmlStyles,
    required this.imageBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(readingPreferencesProvider);

    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: prefs.textColor.withOpacity(0.3),
          selectionHandleColor: AppTheme.primaryGreen,
        ),
      ),
      child: SelectionArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Html(
              data: chapter.content,
              style: htmlStyles,
              extensions: [
                TagExtension(
                  tagsToExtend: {"img"},
                  builder: (context) {
                    final src = context.attributes['src'];
                    if (src != null && src.isNotEmpty) {
                      return imageBuilder(src, chapterHref);
                    }
                    return const SizedBox.shrink();
                  },
                ),
                TagExtension(
                  tagsToExtend: {"image"},
                  builder: (context) {
                    final xlinkHref = context.attributes['xlink:href'];
                    final href = context.attributes['href'];
                    final imageRef = xlinkHref ?? href;

                    if (imageRef != null && imageRef.isNotEmpty) {
                      return imageBuilder(imageRef, chapterHref);
                    }
                    return const SizedBox.shrink();
                  },
                ),
                ImageExtension(
                  builder: (extensionContext) {
                    final src = extensionContext.attributes['src'];
                    if (src != null && src.isNotEmpty) {
                      return imageBuilder(src, chapterHref);
                    }
                    return const SizedBox.shrink();
                  },
                ),
                TableHtmlExtension(),
                SvgHtmlExtension(
                  networkSchemas: const ["https", "http", "file"],
                  extension: "svg",
                  dataEncoding: "base64",
                  dataMimeType: "image/svg+xml",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
