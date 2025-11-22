# Uniform Chapter Numbering System

## Overview
This document describes the uniform chapter numbering system implemented across the VisuaLit Frontend application to ensure consistent chapter identification when communicating with the backend API.

## Problem Statement
Previously, chapter numbers were calculated inconsistently:
- Some places used `index + 1`
- Some places hardcoded chapter numbers
- No standardized field existed in the `EpubChapter` model

This caused potential mismatches when requesting visual generation from the backend, as the chapter number sent might not correspond to the actual chapter being displayed.

## Solution

### 1. Enhanced `EpubChapter` Model
**File:** `lib/features/custom_reader/application/epub_parser_service.dart`

Added a `chapterNumber` field to the `EpubChapter` class:

```dart
class EpubChapter {
  final String id;
  final String title;
  final String href;
  final String content;
  final int chapterNumber; // NEW: Uniform chapter number (1-based index)

  EpubChapter({
    required this.id,
    required this.title,
    required this.href,
    required this.content,
    required this.chapterNumber, // NEW
  });
}
```

### 2. Chapter Number Assignment During Parsing
**File:** `lib/features/custom_reader/application/epub_parser_service.dart`

Chapter numbers are assigned during EPUB parsing based on spine order:

```dart
for (int i = 0; i < spineItems.length; i++) {
  // ... chapter loading logic ...
  chapters.add(EpubChapter(
    id: itemId,
    title: chapterTitle,
    href: fullPath,
    content: content,
    chapterNumber: i + 1, // 1-based chapter numbering
  ));
}
```

**Key Points:**
- ✅ **1-based indexing**: Chapter numbers start at 1 (not 0)
- ✅ **Spine order**: Follows the reading order defined in the EPUB manifest
- ✅ **Consistent assignment**: Same chapter always gets same number
- ✅ **Debug logging**: Prints chapter number and title during parsing

### 3. Using Chapter Numbers in UI
**File:** `lib/features/custom_reader/presentation/reading_screen.dart`

The reading screen now uses the stored `chapterNumber` instead of calculating it:

```dart
BookVisualizationOverlay(
  bookTitleForLookup: _epubData?.title ?? 'Unknown',
  localBookISBN: _currentBookIsbn,
  localChapterNumber: _epubData?.chapters[_currentChapterIndex].chapterNumber ?? (_currentChapterIndex + 1),
  localChapterContent: _epubData?.chapters[_currentChapterIndex].content ?? '',
  onClose: _hideVisualizationOverlay,
)
```

**Fallback:** If for any reason the `chapterNumber` is null, it falls back to `_currentChapterIndex + 1`

### 4. Backend Communication
**File:** `lib/data/services/appwrite_service.dart`

The chapter number is sent to the backend in the POST request:

```dart
final requestBody = <String, dynamic>{
  'isbn': bookISBN ?? "",
  'book_title': bookTitle,
  'chapter_number': chapterNumber, // Uses the uniform chapter number
  'chapter_content': chapterContent,
};
```

## Debug Logging

### During EPUB Parsing
```
📖 DEBUG: Starting chapter parsing from EPUB spine
📖 DEBUG: Parsed Chapter #1 - Title: "Cover"
📖 DEBUG: Parsed Chapter #2 - Title: "Introduction"
📖 DEBUG: Parsed Chapter #3 - Title: "Chapter 1: The Beginning"
...
📖 DEBUG: Completed parsing 15 chapters with uniform numbering
```

### During Backend Request
```
📖 DEBUG: Using uniform chapter number for backend: 3 (Index: 2)

╔═══════════════════════════════════════════════════════════════
║ 🚀 POST REQUEST: Visual Generation Initiated
╠═══════════════════════════════════════════════════════════════
║ 📍 Endpoint: https://fastapi-backend-...
║ 📖 Book Title: The Great Gatsby
║ 📚 ISBN: 978-0743273565
║ 📄 Chapter Number: 3
║ 📝 Content Length: 15234 characters
║ ⏱️  Timeout: None (unlimited)
╚═══════════════════════════════════════════════════════════════
```

## Numbering Rules

### Standard EPUB Books
- **Chapter 1** = First item in EPUB spine (often cover page)
- **Chapter 2** = Second item in spine
- **Chapter N** = Nth item in spine

### Books with Front Matter
Some EPUBs have front matter (cover, title page, copyright, table of contents):
- **Chapter 1** = Cover
- **Chapter 2** = Title Page
- **Chapter 3** = Copyright
- **Chapter 4** = Table of Contents
- **Chapter 5** = First actual chapter of content
- etc.

**Important:** The numbering follows the EPUB spine order, NOT the semantic chapter structure. If the first "real" chapter is item #5 in the spine, it will be numbered as Chapter 5.

## Benefits

### ✅ Consistency
- Same chapter always has same number across the entire app
- Backend receives the exact chapter number the user is viewing

### ✅ Traceability
- Easy to correlate frontend requests with backend processing
- Debug logs show exact chapter being processed

### ✅ Reliability
- No calculation errors from index mismatches
- Fallback mechanism prevents null reference errors

### ✅ Maintainability
- Single source of truth for chapter numbers
- Easy to update or modify numbering logic in one place

## Migration Notes

### For Existing Code
When working with chapters, always use:
```dart
// ✅ CORRECT
chapter.chapterNumber

// ❌ INCORRECT (old way)
_currentChapterIndex + 1
```

### For New Features
When implementing new features that need chapter numbers:
1. Access `EpubChapter.chapterNumber` directly
2. Add debug logging to trace chapter number usage
3. Include chapter number in error messages for debugging

## Backend Contract

### Request Format
```json
{
  "isbn": "978-0743273565",
  "book_title": "The Great Gatsby",
  "chapter_number": 3,
  "chapter_content": "<html>...</html>"
}
```

### Response Format
```json
{
  "status": "success",
  "chapter_id": "abc123",
  "analysis": {
    "chapter_number": 3,
    "entities": [...],
    "images": [...]
  }
}
```

The backend should store and return the same `chapter_number` to maintain correlation.

## Testing

### Manual Testing
1. Open any EPUB book
2. Navigate to any chapter
3. Open visualization overlay
4. Check console logs for chapter number
5. Verify the number matches the spine order

### What to Verify
- ✅ Chapter numbers are sequential (1, 2, 3, ...)
- ✅ Same chapter always has same number
- ✅ Backend request includes correct chapter number
- ✅ Chapter number in logs matches UI display

## Related Files

- `lib/features/custom_reader/application/epub_parser_service.dart` - Chapter number assignment
- `lib/features/custom_reader/presentation/reading_screen.dart` - Chapter number usage
- `lib/data/services/appwrite_service.dart` - Backend communication
- `lib/features/reader/presentation/widgets/book_overview_dialog.dart` - Visualization UI
- `lib/features/custom_reader/presentation/widgets/book_visualization_overlay.dart` - Visualization UI

## Future Enhancements

### Semantic Chapter Numbering
Currently uses spine order. Could be enhanced to:
- Parse table of contents for semantic chapter numbers
- Handle books with prologue/epilogue specially
- Skip front matter in numbering

### Chapter Metadata
Could extend `EpubChapter` with:
- `semanticNumber` - Chapter number from TOC
- `type` - 'frontmatter', 'chapter', 'backmatter'
- `isNumbered` - Whether this is a numbered chapter

### Validation
Add validation to ensure:
- No duplicate chapter numbers
- Sequential numbering (no gaps)
- Chapter numbers match between frontend and backend

---

**Last Updated:** 2025-11-20  
**Version:** 1.0  
**Status:** ✅ Implemented and Tested

