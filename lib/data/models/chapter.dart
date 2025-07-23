class Chapter {
  final String id;
  final String bookId;
  final int chapterNumber;
  final String status;
  final String? nlpFileId;

  Chapter({
    required this.id,
    required this.bookId,
    required this.chapterNumber,
    required this.status,
    this.nlpFileId,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['\$id'] as String,
      bookId: json['bookId'] as String,
      chapterNumber: json['chapterNumber'] as int,
      status: json['status'] as String,
      nlpFileId: json['nlpFileId'] as String?,
    );
  }
}