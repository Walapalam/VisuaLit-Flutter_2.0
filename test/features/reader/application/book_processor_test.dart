/*
import 'package:flutter_test/flutter_test.dart';
import 'package:visualit/features/reader/application/book_processor.dart';

void main() {
  group('BookProcessor', () {
    test('_decodeHtmlEntities should properly decode apostrophes', () {
      // Test with various apostrophe encodings
      expect(BookProcessor._decodeHtmlEntities("It&apos;s a test"), equals("It's a test"));
      expect(BookProcessor._decodeHtmlEntities("It&#39;s a test"), equals("It's a test"));
      expect(BookProcessor._decodeHtmlEntities("It&#x27;s a test"), equals("It's a test"));
      
      // Test with multiple entities
      expect(
        BookProcessor._decodeHtmlEntities("&quot;It&apos;s a test&quot; with &amp; symbol"),
        equals("\"It's a test\" with & symbol")
      );
      
      // Test with no entities
      expect(BookProcessor._decodeHtmlEntities("Plain text"), equals("Plain text"));
      
      // Test with apostrophe already in plain text
      expect(BookProcessor._decodeHtmlEntities("It's already plain"), equals("It's already plain"));
    });
  });
}*/
