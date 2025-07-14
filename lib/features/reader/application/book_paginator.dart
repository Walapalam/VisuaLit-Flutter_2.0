// /*
// import 'package:flutter/material.dart';
// import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
// import 'package:html/parser.dart' as html_parser;
// import 'package:visualit/features/reader/data/book_data.dart';
// import 'package:visualit/features/reader/domain/book_page.dart';
// import 'package:visualit/features/reader/presentation/reading_preferences_controller.dart';
//
// class BookPaginator {
//   final List<ContentBlock> allBlocks;
//   final Size viewSize;
//   final ReadingPreferences preferences;
//   final WidgetFactory factory;
//
//   final Map<int, BookPage> _pageCache = {};
//   final Map<int, int> _blockToPageMap = {};
//   final Map<String, int> _locationToBlockIndexMap = {};
//
//   int _totalPages = 1;
//   bool _isPaginationComplete = false;
//
//   BookPaginator._({
//     required this.allBlocks,
//     required this.viewSize,
//     required this.preferences,
//     required this.factory,
//   });
//
//   static Future<BookPaginator> create({
//     required List<ContentBlock> allBlocks,
//     required Size viewSize,
//     required ReadingPreferences preferences,
//     required WidgetFactory factory,
//   }) async {
//     print("⏳ [BookPaginator] Create method called. Starting widget-based pagination...");
//     final paginator = BookPaginator._(
//       allBlocks: allBlocks,
//       viewSize: viewSize,
//       preferences: preferences,
//       factory: factory,
//     );
//     paginator._buildLocationMap();
//     await paginator._calculateAllPages();
//     print("✅ [BookPaginator] Pagination complete. Returning instance.");
//     return paginator;
//   }
//
//   void _buildLocationMap() {
//     for (int i = 0; i < allBlocks.length; i++) {
//       final block = allBlocks[i];
//       if (block.src != null) {
//         if (!_locationToBlockIndexMap.containsKey(block.src!)) {
//           _locationToBlockIndexMap[block.src!] = i;
//         }
//         if (block.htmlContent != null) {
//           final document = html_parser.parseFragment(block.htmlContent!);
//           final elementWithId = document.querySelector('[id]');
//           if (elementWithId != null) {
//             final id = elementWithId.attributes['id'];
//             if (id != null && id.isNotEmpty) {
//               final locationKey = '${block.src}#$id';
//               _locationToBlockIndexMap[locationKey] = i;
//             }
//           }
//         }
//       }
//     }
//     print("  [BookPaginator] Built location map with ${_locationToBlockIndexMap.length} entries.");
//   }
//
//   int findBlockIndexByLocation(String src, String? fragment) {
//     if (fragment != null && fragment.isNotEmpty) {
//       final key = '$src#$fragment';
//       if (_locationToBlockIndexMap.containsKey(key)) {
//         return _locationToBlockIndexMap[key]!;
//       }
//     }
//     return _locationToBlockIndexMap[src] ?? -1;
//   }
//
//   int get totalPages => _isPaginationComplete ? _totalPages : 0;
//   bool get isPaginationComplete => _isPaginationComplete;
//
//   int? getPageForBlock(int blockIndex) {
//     if (!_isPaginationComplete) return null;
//     return _blockToPageMap[blockIndex];
//   }
//
//   BookPage? getPage(int pageIndex) {
//     return _pageCache[pageIndex];
//   }
//
//   Future<void> _calculateAllPages() async {
//     print("  [BookPaginator] Starting _calculateAllPages with widget-based measurement...");
//     if (allBlocks.isEmpty) {
//       _isPaginationComplete = true;
//       _totalPages = 0;
//       print("  [BookPaginator] No blocks to process. Finished.");
//       return;
//     }
//
//     int currentPageIndex = 0;
//     int currentBlockIndex = 0;
//
//     const EdgeInsets margins = EdgeInsets.symmetric(horizontal: 20, vertical: 30);
//     final double availableHeight = viewSize.height - margins.top - margins.bottom;
//     final double availableWidth = viewSize.width - margins.left - margins.bottom;
//
//     while (currentBlockIndex < allBlocks.length) {
//       final List<ContentBlock> pageBlocks = [];
//       double currentY = 0;
//       final int startingBlockIndex = currentBlockIndex;
//
//       _blockToPageMap[startingBlockIndex] = currentPageIndex;
//
//       while (currentBlockIndex < allBlocks.length) {
//         final block = allBlocks[currentBlockIndex];
//
//         final renderObject = _measureBlock(block, availableWidth);
//         if (renderObject == null) {
//           currentBlockIndex++;
//           continue;
//         }
//         final blockHeight = renderObject.size.height + 12.0;
//
//         if (currentY + blockHeight > availableHeight && pageBlocks.isNotEmpty) {
//           break;
//         }
//
//         pageBlocks.add(block);
//         currentY += blockHeight;
//         currentBlockIndex++;
//       }
//
//       if (pageBlocks.isEmpty && currentBlockIndex < allBlocks.length) {
//         pageBlocks.add(allBlocks[currentBlockIndex]);
//         currentBlockIndex++;
//       }
//
//       _pageCache[currentPageIndex] = BookPage(
//         pageIndex: currentPageIndex,
//         blocks: pageBlocks,
//         startingBlockIndex: startingBlockIndex,
//         endingBlockIndex: currentBlockIndex - 1,
//       );
//
//       if (currentPageIndex > 0 && currentPageIndex % 50 == 0) {
//         print("    [BookPaginator] Calculated page $currentPageIndex...");
//       }
//       currentPageIndex++;
//     }
//
//     _totalPages = currentPageIndex;
//     _isPaginationComplete = true;
//     print("✅ [BookPaginator] Finished calculation! Total pages: $_totalPages");
//   }
//
//   // --- THIS METHOD IS NOW CORRECTLY PLACED INSIDE THE CLASS ---
//   RenderBox? _measureBlock(ContentBlock block, double maxWidth) {
//     Widget blockWidget;
//     if (block.blockType == BlockType.img && block.imageBytes != null) {
//       blockWidget = ConstrainedBox(
//         constraints: BoxConstraints(maxWidth: maxWidth),
//         // Accessing instance variable 'viewSize' is now valid.
//         child: Image.memory(block.imageBytes!, fit: BoxFit.contain, height: viewSize.height * 0.6),
//       );
//     } else if (block.htmlContent != null) {
//       // Accessing instance variables 'factory' and 'preferences' is now valid.
//       blockWidget = factory.build(
//         block.htmlContent!,
//         textStyle: preferences.getStyleForBlock(block.blockType),
//       );
//     } else {
//       return null;
//     }
//
//     // Accessing instance variable 'factory' is now valid.
//     final render = blockWidget.createRenderObject(factory.context);
//     render.layout(BoxConstraints(maxWidth: maxWidth));
//     return render;
//   }
// }*/
