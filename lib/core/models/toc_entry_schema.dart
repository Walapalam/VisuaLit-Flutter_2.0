import 'package:isar/isar.dart';

part 'toc_entry_schema.g.dart';

/// Schema for table of contents entries in a book
@collection
class TOCEntrySchema {
  Id id = Isar.autoIncrement;

  /// The ID of the book this TOC entry belongs to
  @Index(composite: [CompositeIndex('level'), CompositeIndex('orderIndex')])
  late int bookId;

  /// The title of this TOC entry
  late String title;

  /// The source file path this TOC entry points to
  String? src;

  /// The fragment identifier within the source file (e.g., #chapter1)
  String? fragment;

  /// The nesting level of this TOC entry (0 for top-level entries)
  late int level;

  /// The order index of this entry within its level
  late int orderIndex;

  /// The ID of the parent TOC entry (null for top-level entries)
  int? parentId;

  /// Links to the parent TOC entry
  final parent = IsarLink<TOCEntrySchema>();

  /// Links to the children TOC entries
  @Backlink(to: 'parent')
  final children = IsarLinks<TOCEntrySchema>();
}