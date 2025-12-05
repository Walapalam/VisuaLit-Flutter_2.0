# Quick Reference Guide - Chapter Visualization System

## For Developers

### How to Use the New System

#### 1. ISBN Extraction (Automatic)
When a user opens a book:
```dart
// The system automatically:
// 1. Checks EPUB metadata for ISBN
// 2. Falls back to multi-source API lookup (Google Books + Open Library)
// 3. Validates ISBN-13 checksuma
// 4. Returns empty string if all methods fail (no random ISBNs anymore)
```

#### 2. Viewing Chapter Visualizations
```dart
// User opens visualization overlay for current chapter
// System fetches ONLY current chapter's visuals (not entire book)
final params = (bookTitle: bookTitle, chapterNumber: chapterNumber);
final visuals = await ref.read(currentChapterVisualsProvider(params).future);

// Visuals are automatically separated by type:
final scenes = visuals.where((v) => v.isScene).toList();
final characters = visuals.where((v) => v.isCharacter).toList();
```

#### 3. Generating Visuals
```dart
// User taps "Generate Visuals for this Chapter"
// Button text clearly indicates chapter-only generation
await appwriteService.requestVisualGeneration(
  bookTitle: bookTitle,
  bookISBN: isbn, // From enhanced lookup
  chapterNumber: chapterNumber, // Current chapter only
  chapterContent: chapterContent,
);
```

### Provider Usage

#### Chapter-Scoped Providers
```dart
// Get current chapter document
final chapter = ref.watch(currentChapterProvider((
  bookTitle: 'Harry Potter',
  chapterNumber: 5
)));

// Get visuals for current chapter
final visuals = ref.watch(currentChapterVisualsProvider((
  bookTitle: 'Harry Potter',
  chapterNumber: 5
)));
```

#### Invalidating Providers (Force Refresh)
```dart
// After generating new visuals
ref.invalidate(currentChapterVisualsProvider(params));

// After book data changes
ref.invalidate(bookDetailsByTitleProvider(bookTitle));
```

### UI Components Reference

#### Image Card States
```dart
// Loading: Shimmer placeholder with circular progress
// Success: Image with gradient overlay + description
// Error: Broken icon with "Tap to retry" message
// Empty: "No scenes/characters in this chapter" placeholder
```

#### Responsive Grid
```dart
// Mobile (< 600dp): 2 columns
// Tablet/Desktop (≥ 600dp): 3 columns
// Aspect Ratio: 3:4 (portrait)
// Spacing: 12dp between cards, 16dp edge padding
```

### Data Model Fields

#### GeneratedVisual
```dart
class GeneratedVisual {
  final String id;
  final String chapterId;
  final String entityName;
  final String prompt;
  final String imageFileId;
  final String type;         // NEW: 'scene' or 'character'
  final String description;  // NEW: Display text
  
  bool get isScene => type == 'scene';
  bool get isCharacter => type == 'character';
}
```

#### EpubMetadata
```dart
class EpubMetadata {
  final String title;
  final String author;
  final String? isbn;  // NEW: Extracted from EPUB
  final List<EpubChapter> chapters;
  final Map<String, String> images;
  final Map<String, String> cssFiles;
}
```

---

## For Backend Developers

### Required Appwrite Schema Updates

#### generated_visuals Collection

**Add these attributes:**

1. **type** (String)
   - Required: Yes
   - Indexed: Yes
   - Default: 'scene'
   - Validation: Must be 'scene' or 'character'

2. **description** (String)
   - Required: Yes
   - Max Length: 500
   - Default: Empty string

**Example Documents:**

```json
{
  "$id": "visual_123",
  "chapterId": "chapter_456",
  "entityName": "Dark Forest",
  "prompt": "A dark, mysterious forest with twisted trees",
  "imageFileId": "file_789",
  "type": "scene",
  "description": "The hero enters the dark forest at midnight"
}
```

```json
{
  "$id": "visual_124",
  "chapterId": "chapter_456",
  "entityName": "Gandalf",
  "prompt": "Elderly wizard with grey beard and staff",
  "imageFileId": "file_790",
  "type": "character",
  "description": "Gandalf the Grey"
}
```

### NLP Pipeline Requirements

When generating visuals, the backend must:

1. **Categorize Entities:**
   - Identify if entity is a scene or character
   - Set `type` field accordingly

2. **Generate Descriptions:**
   - For scenes: Short description of what's happening (e.g., "The battle at Helm's Deep")
   - For characters: Character name or short identifier (e.g., "Aragorn, the ranger")
   - Keep descriptions concise (2-10 words ideal)
   - Max 500 characters

3. **Example NLP Logic:**
   ```python
   # Pseudocode
   for entity in extracted_entities:
       if entity.is_character():
           visual = {
               "type": "character",
               "description": entity.name,
               "entityName": entity.name,
               # ... other fields
           }
       elif entity.is_scene():
           visual = {
               "type": "scene",
               "description": f"{entity.action} at {entity.location}",
               "entityName": f"{entity.location}",
               # ... other fields
           }
   ```

---

## For Testers

### Test Scenarios

#### ISBN Extraction
- [ ] Open book with ISBN in EPUB metadata → Verify ISBN displayed in logs
- [ ] Open book without ISBN → Verify API lookup attempts
- [ ] Check with book by obscure author → Verify Open Library fallback
- [ ] Test with malformed ISBN in EPUB → Verify checksum validation

#### Visualization Display
- [ ] Open chapter with scenes and characters → Verify both sections show
- [ ] Open chapter with only scenes → Verify "No characters" placeholder
- [ ] Open chapter with no visuals → Verify "No Visualizations Yet" message
- [ ] Rotate device → Verify grid adjusts (2→3 or 3→2 columns)

#### Image Loading
- [ ] Wait for images to load → Verify shimmer appears
- [ ] Disconnect internet → Verify error cards with retry option
- [ ] Tap retry on failed image → Verify only that image reloads
- [ ] Tap image → Verify detail dialog opens with Hero animation

#### Generation Flow
- [ ] Tap "Generate Visuals for this Chapter" → Verify button text is chapter-specific
- [ ] Watch loading state → Verify "Curating scenes..." message
- [ ] Wait for completion → Verify visuals appear in categorized sections
- [ ] Generate again for different chapter → Verify chapter isolation

#### Sticky Headers
- [ ] Scroll down → Verify "Scenes" header sticks to top
- [ ] Scroll past scenes → Verify "Characters" header sticks
- [ ] Check header badges → Verify counts match actual visuals

### Performance Benchmarks

**Baseline Metrics:**
- Initial load: < 2 seconds (on 4G)
- Image loading: < 1 second per image (cached)
- Generation request: 60-120 seconds (backend dependent)
- UI transitions: 60 FPS

**Memory Usage:**
- Before: ~150MB for 100-image book
- After: ~25MB for 10-image chapter
- Target: < 30MB per chapter

---

## Troubleshooting

### Common Issues

#### "No visualizations found"
**Cause:** Chapter not in Appwrite or no visuals generated yet
**Fix:** Tap "Generate Visuals for this Chapter" button

#### Images not loading
**Cause:** Network issue or invalid fileId
**Fix:** Check Appwrite storage bucket permissions, tap retry on individual images

#### ISBN lookup fails
**Cause:** Book not in Google Books or Open Library
**Fix:** System returns empty string (expected behavior, no longer generates random ISBN)

#### Wrong chapter visuals showing
**Cause:** Chapter number mismatch between local and Appwrite
**Fix:** Check chapter numbering system (1-based vs 0-based)

### Debug Logs

Search console for these prefixes:
- `📚 DEBUG:` - General operations
- `📚 ISBN Lookup:` - ISBN extraction flow
- `📚 EPUB Parser:` - EPUB metadata parsing

**Example:**
```
📚 ISBN Lookup: Starting for title="Harry Potter", author="J.K. Rowling"
📚 ISBN Lookup: Found via Google Books (title+author): 9780439708180
📚 DEBUG: Using ISBN from EPUB metadata: 9780439708180
📚 DEBUG: Retrieved 8 visuals for chapter 5
📚 DEBUG: Breakdown - Scenes: 5, Characters: 3
```

---

## API Reference

### IsbnLookupService

```dart
// Enhanced lookup with author parameter
Future<String> lookupIsbnByTitle(String title, String author)

// Returns:
// - Valid ISBN-13 (if found and validated)
// - Empty string (if not found)
// Never returns random/fake ISBN
```

### AppwriteService

```dart
// Chapter-specific fetch (new, efficient)
Future<List<GeneratedVisual>> getGeneratedVisualsForChapter(String chapterId)

// Book-wide fetch (legacy, still available)
Future<List<GeneratedVisual>> getGeneratedVisualsForChapters(List<String> chapterIds)

// Image URL generator
String getImageUrl(String fileId)
```

### Providers

```dart
// Current chapter document
final currentChapterProvider = FutureProvider.family.autoDispose<Chapter?, ({String bookTitle, int chapterNumber})>

// Current chapter visuals
final currentChapterVisualsProvider = FutureProvider.family.autoDispose<List<GeneratedVisual>, ({String bookTitle, int chapterNumber})>

// Book details
final bookDetailsByTitleProvider = FutureProvider.family<Book?, String>

// Generation loading state
final generationLoadingProvider = StateProvider.autoDispose<bool>
```

---

## Migration Guide

### If you have existing code using old system:

**Before:**
```dart
// Book-wide fetch
final visuals = ref.watch(generatedVisualsForAppwriteBookProvider(bookId));
```

**After:**
```dart
// Chapter-specific fetch
final params = (bookTitle: bookTitle, chapterNumber: chapterNumber);
final visuals = ref.watch(currentChapterVisualsProvider(params));

// Separate by type
final scenes = visuals.where((v) => v.isScene).toList();
final characters = visuals.where((v) => v.isCharacter).toList();
```

**ISBN Lookup:**

Before:
```dart
final isbn = await IsbnLookupService.lookupIsbnByTitle(title);
```

After:
```dart
// Check EPUB first
final isbn = epubData.isbn ?? await IsbnLookupService.lookupIsbnByTitle(title, author);
```

---

## Version Info

- **Implementation Date:** 2025-01-22
- **Flutter Version:** 3.x
- **Minimum Dart SDK:** 3.0.0
- **Minimum Appwrite:** 1.4.0

## Support

For questions or issues:
1. Check debug logs (search for `📚` prefix)
2. Review IMPLEMENTATION_COMPLETE.md
3. Verify backend schema matches requirements
4. Test with sample EPUB containing ISBN

---

**Happy Coding! 🚀**

