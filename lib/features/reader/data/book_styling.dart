import 'package:isar/isar.dart';

part 'book_styling.g.dart';

@embedded
class BookStyling {
  List<StyleSheet> styleSheets = []; // CSS style sheets

  // Constructor
  BookStyling({
    List<StyleSheet> styleSheets = const [],
  }) : styleSheets = styleSheets;
}

@embedded
class StyleSheet {
  String? href;        // Path to the stylesheet in the EPUB file
  String? content;     // The actual CSS content

  // Constructor
  StyleSheet({
    this.href,
    this.content,
  });
}

// Extension methods for debugging
extension BookStylingDebug on BookStyling {
  // Log the styling details
  void debugLog([String prefix = ""]) {
    print("$prefix BookStyling: ${styleSheets.length} stylesheets");
    for (int i = 0; i < styleSheets.length; i++) {
      print("$prefix StyleSheet[$i]: href: ${styleSheets[i].href}");
      print("$prefix StyleSheet[$i] content length: ${styleSheets[i].content?.length ?? 0}");
    }
  }

  // Get a string representation of the styling
  String toDebugString() {
    return "BookStyling(${styleSheets.length} stylesheets)";
  }
}

// Extension methods for debugging StyleSheet
extension StyleSheetDebug on StyleSheet {
  // Get a string representation of the stylesheet
  String toDebugString() {
    return "StyleSheet(href: $href, contentLength: ${content?.length ?? 0})";
  }
}
