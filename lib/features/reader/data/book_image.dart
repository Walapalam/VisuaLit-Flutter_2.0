import 'package:isar/isar.dart';
import 'dart:typed_data';

part 'book_image.g.dart';

@embedded
class BookImage {
  String? src;              // Source path in the EPUB file
  String? name;             // Image name or ID
  String? mimeType;         // MIME type of the image (e.g., "image/jpeg")
  List<byte>? imageBytes;   // The actual image data
  
  // Constructor
  BookImage({
    this.src,
    this.name,
    this.mimeType,
    this.imageBytes,
  });
}

// Extension methods for debugging
extension BookImageDebug on BookImage {
  // Log the image details
  void debugLog([String prefix = ""]) {
    print("$prefix BookImage: name: $name, src: $src, mimeType: $mimeType");
    print("$prefix Image size: ${imageBytes?.length ?? 0} bytes");
  }
  
  // Get a string representation of the image
  String toDebugString() {
    return "BookImage(name: $name, src: $src, mimeType: $mimeType, size: ${imageBytes?.length ?? 0} bytes)";
  }
}