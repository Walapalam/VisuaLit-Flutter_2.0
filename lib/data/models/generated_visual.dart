class GeneratedVisual {
  final String id;
  final String chapterId;
  final String entityName; // Could be a character name or a scene name
  final String prompt;
  final String imageFileId; // The Appwrite File ID for the image

  GeneratedVisual({
    required this.id,
    required this.chapterId,
    required this.entityName,
    required this.prompt,
    required this.imageFileId,
  });

  factory GeneratedVisual.fromJson(Map<String, dynamic> json) {
    return GeneratedVisual(
      id: json['\$id'] as String,
      chapterId: json['chapterId'] as String,
      entityName: json['entityName'] as String,
      prompt: json['prompt'] as String,
      imageFileId: json['imageFileId'] as String,
    );
  }
}