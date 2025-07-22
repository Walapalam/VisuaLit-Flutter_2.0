import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'highlight_schema.g.dart';

/// Schema for highlights in a book
@collection
class HighlightSchema {
  Id id = Isar.autoIncrement;

  /// The user ID (if authenticated)
  String? userId;

  /// The ID of the book this highlight belongs to
  @Index(composite: [CompositeIndex('chapterIndex')])
  late int bookId;

  /// The index of the chapter this highlight belongs to
  late int chapterIndex;

  /// The index of the first content block this highlight spans
  late int startBlockIndex;

  /// The index of the last content block this highlight spans
  late int endBlockIndex;

  /// The offset within the start block where the highlight begins
  late int startOffset;

  /// The offset within the end block where the highlight ends
  late int endOffset;

  /// The highlighted text
  late String text;

  /// The color of the highlight
  @enumerated
  late HighlightColor color;

  /// Optional note attached to the highlight
  String? note;

  /// Timestamps for synchronization
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}

/// Enum for highlight colors
enum HighlightColor {
  yellow,
  green,
  blue,
  pink,
  purple
}