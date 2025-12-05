class GeneratedVisual {
  final String id;
  final String chapterId;
  final String entityName; // Could be a character name or a scene name
  final String prompt;
  final String imageFileId; // The Appwrite File ID for the image
  final String type; // Backend sends 'IMAGE' - we determine scene vs character from entityName
  final String description; // Scene description or character name

  GeneratedVisual({
    required this.id,
    required this.chapterId,
    required this.entityName,
    required this.prompt,
    required this.imageFileId,
    required this.type,
    required this.description,
  });

  factory GeneratedVisual.fromJson(Map<String, dynamic> json) {
    return GeneratedVisual(
      id: json['\$id'] as String,
      chapterId: json['chapterId'] as String,
      entityName: json['entityName'] as String,
      prompt: json['prompt'] as String,
      imageFileId: json['imageFileId'] as String,
      type: json['type'] as String? ?? 'IMAGE',
      description: json['description'] as String? ?? json['entityName'] as String,
    );
  }

  /// Check if this visual is a scene
  /// Since backend sends 'IMAGE' for all types, detect scenes by entityName patterns
  bool get isScene {
    final lowerName = entityName.toLowerCase();
    final lowerDesc = description.toLowerCase();
    
    // Scene indicators in entity names
    if (lowerName.contains('street') || 
        lowerName.contains('room') || 
        lowerName.contains('house') ||
        lowerName.contains('door') ||
        lowerName.contains('laboratory') ||
        lowerName.contains('lab') ||
        lowerDesc.contains('location') ||
        lowerDesc.contains('setting') ||
        lowerDesc.contains('place')) {
      return true;
    }
    
    // Fallback: check if type field explicitly says 'scene'
    return type.toLowerCase() == 'scene';
  }

  /// Check if this visual is a character
  /// Defaults to character if not identified as scene
  bool get isCharacter {
    // If type explicitly says 'character'
    if (type.toLowerCase() == 'character') {
      return true;
    }
    
    // Default: If not a scene, it's a character
    return !isScene;
  }
}