import 'dart:typed_data';

// ---- Enums ----
enum ProcessingStatus { queued, processing, ready, error }

enum BlockType { p, h1, h2, h3, h4, h5, h6, img, unsupported }

// ---- Models ----
class Book {
  int id;
  String epubFilePath;
  String? title;
  String? author;
  Uint8List? coverImageBytes;
  
  // Metadata fields
  String? publisher;
  String? language;
  DateTime? publicationDate;
  
  ProcessingStatus status = ProcessingStatus.queued;
  
  int lastReadPage = 0;
  DateTime? lastReadTimestamp;
  
  List<TOCEntry> toc = [];
  
  Book({
    required this.id,
    required this.epubFilePath,
    this.title,
    this.author,
    this.coverImageBytes,
    this.publisher,
    this.language,
    this.publicationDate,
    this.status = ProcessingStatus.queued,
    this.lastReadPage = 0,
    this.lastReadTimestamp,
    this.toc = const [],
  });
  
  // Factory method to create a Book from a Map (for JSON serialization)
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      epubFilePath: json['epubFilePath'],
      title: json['title'],
      author: json['author'],
      coverImageBytes: json['coverImageBytes'] != null ? Uint8List.fromList(List<int>.from(json['coverImageBytes'])) : null,
      publisher: json['publisher'],
      language: json['language'],
      publicationDate: json['publicationDate'] != null ? DateTime.parse(json['publicationDate']) : null,
      status: ProcessingStatus.values[json['status'] ?? 0],
      lastReadPage: json['lastReadPage'] ?? 0,
      lastReadTimestamp: json['lastReadTimestamp'] != null ? DateTime.parse(json['lastReadTimestamp']) : null,
      toc: (json['toc'] as List?)?.map((e) => TOCEntry.fromJson(e)).toList() ?? [],
    );
  }
  
  // Method to convert a Book to a Map (for JSON serialization)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'epubFilePath': epubFilePath,
      'title': title,
      'author': author,
      'coverImageBytes': coverImageBytes?.toList(),
      'publisher': publisher,
      'language': language,
      'publicationDate': publicationDate?.toIso8601String(),
      'status': status.index,
      'lastReadPage': lastReadPage,
      'lastReadTimestamp': lastReadTimestamp?.toIso8601String(),
      'toc': toc.map((e) => e.toJson()).toList(),
    };
  }
}

class ContentBlock {
  int id;
  int? bookId;
  int? chapterIndex;
  int? blockIndexInChapter;
  String? src; // The source XHTML file of this block
  BlockType blockType;
  
  // Now the primary source for rendering
  String? htmlContent;
  
  // Keep plain text for searching, indexing, or simple displays
  String? textContent;
  
  // Store image data directly if the block is an image
  Uint8List? imageBytes;
  
  ContentBlock({
    required this.id,
    this.bookId,
    this.chapterIndex,
    this.blockIndexInChapter,
    this.src,
    required this.blockType,
    this.htmlContent,
    this.textContent,
    this.imageBytes,
  });
  
  // Factory method to create a ContentBlock from a Map (for JSON serialization)
  factory ContentBlock.fromJson(Map<String, dynamic> json) {
    return ContentBlock(
      id: json['id'],
      bookId: json['bookId'],
      chapterIndex: json['chapterIndex'],
      blockIndexInChapter: json['blockIndexInChapter'],
      src: json['src'],
      blockType: BlockType.values[json['blockType'] ?? 0],
      htmlContent: json['htmlContent'],
      textContent: json['textContent'],
      imageBytes: json['imageBytes'] != null ? Uint8List.fromList(List<int>.from(json['imageBytes'])) : null,
    );
  }
  
  // Method to convert a ContentBlock to a Map (for JSON serialization)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'chapterIndex': chapterIndex,
      'blockIndexInChapter': blockIndexInChapter,
      'src': src,
      'blockType': blockType.index,
      'htmlContent': htmlContent,
      'textContent': textContent,
      'imageBytes': imageBytes?.toList(),
    };
  }
}

class Highlight {
  int id;
  int bookId;
  int? chapterIndex;
  int? blockIndexInChapter;
  
  /// The selected text content.
  String text;
  
  /// The start offset of the selection within the block's plain text.
  int startOffset;
  
  /// The end offset of the selection within the block's plain text.
  int endOffset;
  
  /// The ARGB color value of the highlight.
  int color;
  
  DateTime timestamp;
  
  String? note; // For future annotation features
  
  Highlight({
    required this.id,
    required this.bookId,
    this.chapterIndex,
    this.blockIndexInChapter,
    required this.text,
    required this.startOffset,
    required this.endOffset,
    required this.color,
    DateTime? timestamp,
    this.note,
  }) : timestamp = timestamp ?? DateTime.now();
  
  // Factory method to create a Highlight from a Map (for JSON serialization)
  factory Highlight.fromJson(Map<String, dynamic> json) {
    return Highlight(
      id: json['id'],
      bookId: json['bookId'],
      chapterIndex: json['chapterIndex'],
      blockIndexInChapter: json['blockIndexInChapter'],
      text: json['text'],
      startOffset: json['startOffset'],
      endOffset: json['endOffset'],
      color: json['color'],
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
      note: json['note'],
    );
  }
  
  // Method to convert a Highlight to a Map (for JSON serialization)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'chapterIndex': chapterIndex,
      'blockIndexInChapter': blockIndexInChapter,
      'text': text,
      'startOffset': startOffset,
      'endOffset': endOffset,
      'color': color,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
    };
  }
}

class TOCEntry {
  String? title;
  String? src; // Path to the chapter file, e.g., "chapter1.xhtml"
  String? fragment; // ID within the file, e.g., "section2"
  
  // For nesting chapters
  List<TOCEntry> children;
  
  TOCEntry({
    this.title,
    this.src,
    this.fragment,
    this.children = const [],
  });
  
  // Factory method to create a TOCEntry from a Map (for JSON serialization)
  factory TOCEntry.fromJson(Map<String, dynamic> json) {
    return TOCEntry(
      title: json['title'],
      src: json['src'],
      fragment: json['fragment'],
      children: (json['children'] as List?)?.map((e) => TOCEntry.fromJson(e)).toList() ?? [],
    );
  }
  
  // Method to convert a TOCEntry to a Map (for JSON serialization)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'src': src,
      'fragment': fragment,
      'children': children.map((e) => e.toJson()).toList(),
    };
  }
}