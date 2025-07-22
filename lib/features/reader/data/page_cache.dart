import 'dart:convert';
import 'package:isar/isar.dart';

part 'page_cache.g.dart';

/// A model for caching calculated page metadata.
/// This improves performance for large books and reduces layout lag.
@collection
class PageCache {
  Id id = Isar.autoIncrement;
  
  /// Reference to the book
  @Index(composite: [CompositeIndex('deviceId'), CompositeIndex('fontSizeKey')])
  int bookId;
  
  /// Device identifier (to handle different screen sizes)
  String deviceId;
  
  /// Font size and dimensions key (e.g., "18.0_360.0_640.0")
  String fontSizeKey;
  
  /// Serialized page metadata as JSON
  String pageMapJson;
  
  /// Constructor
  PageCache({
    required this.bookId,
    required this.deviceId,
    required this.fontSizeKey,
    required this.pageMapJson,
  });
}

/// Metadata for a single page.
class PageMetadata {
  final int pageIndex;
  final int blockId;
  final double offsetInBlock;
  final double height;
  
  PageMetadata({
    required this.pageIndex,
    required this.blockId,
    required this.offsetInBlock,
    required this.height,
  });
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'pageIndex': pageIndex,
      'blockId': blockId,
      'offsetInBlock': offsetInBlock,
      'height': height,
    };
  }
  
  /// Create from JSON
  factory PageMetadata.fromJson(Map<String, dynamic> json) {
    return PageMetadata(
      pageIndex: json['pageIndex'],
      blockId: json['blockId'],
      offsetInBlock: json['offsetInBlock'],
      height: json['height'],
    );
  }
  
  /// Convert a list of PageMetadata to JSON string
  static String toJsonString(List<PageMetadata> pages) {
    final jsonList = pages.map((page) => page.toJson()).toList();
    return jsonEncode(jsonList);
  }
  
  /// Create a list of PageMetadata from JSON string
  static List<PageMetadata> fromJsonString(String jsonString) {
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => PageMetadata.fromJson(json)).toList();
  }
}