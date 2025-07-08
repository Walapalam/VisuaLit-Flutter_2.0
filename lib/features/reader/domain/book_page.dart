import 'package:visualit/features/reader/data/book_data.dart';

class BookPage {
  final int pageIndex;
  final List<ContentBlock> blocks;
  final int startingBlockIndex;
  final int endingBlockIndex;

  BookPage({
    required this.pageIndex,
    required this.blocks,
    required this.startingBlockIndex,
    required this.endingBlockIndex,
  });
}