# Migration Guide: Pre-loaded Books with Temporary Cache Paths

## Problem Summary

**Issue**: Pre-loaded books (imported before the storage fix) were stored with temporary file picker cache paths like `/cache/file_picker/...`. These temporary files are automatically cleaned up by Android, causing "PathNotFoundException" when trying to open these books.

**What Works**: Books downloaded from the marketplace work fine because they use a different storage mechanism.

## Solution Implemented

### 1. Automatic Detection
The app now automatically detects books with missing files when you open the home screen.

### 2. User-Friendly Notifications
- **Home Screen Dialog**: Shows a list of books that need re-importing with option to remove them all
- **Reading Screen**: If you try to open a book with a missing file, shows a clear error message with a "Remove This Book" button

### 3. Migration Tools
Added methods to help manage books with missing files:
- `findBooksWithMissingFiles()` - Scans and lists books with missing files
- `deleteBook(bookId)` - Removes a single book
- `deleteAllBooksWithMissingFiles()` - Removes all books with missing files at once

## How to Fix Your Pre-loaded Books

### Option 1: Using the Automatic Dialog (Recommended)
1. Open the app and go to the Home screen
2. You'll see a dialog listing books with missing files
3. Tap **"Remove All"** to delete all affected books
4. Re-import your books using the "Add Books" or "Add Books from Folder" buttons
5. Books will now be stored permanently

### Option 2: Manual Removal
1. Try to open a book that's not working
2. You'll see an error screen explaining the issue
3. Tap **"Remove This Book"**
4. Go back and re-import the book
5. The book will now be stored permanently

## What Changed in the Code

### 1. Reading Screen (`reading_screen.dart`)
- Added file existence check before parsing EPUB
- Shows user-friendly error messages with actionable buttons
- Provides "Remove This Book" button for books with cache paths

### 2. Home Screen (`home_screen.dart`)
- Added automatic detection of books with missing files on load
- Shows dialog with list of affected books
- Offers bulk removal option

### 3. Library Controller (`library_controller.dart`)
- Added `findBooksWithMissingFiles()` method
- Added `deleteBook()` method  
- Added `deleteAllBooksWithMissingFiles()` method
- Logs warnings when books with cache paths are detected

## Storage Locations

Books are now stored in permanent app-scoped storage:
- **Android**: `<getExternalStorageDirectory()>/VisuaLit/books/`
- **iOS**: `<getApplicationDocumentsDirectory()>/VisuaLit/books/`

## Testing the Migration

1. **Check logs**: Look for warnings like:
   ```
   ⚠️ [LibraryController] Found X books with temporary cache paths:
      - Book Title (ID: 123)
   ```

2. **Try opening a pre-loaded book**: Should see the new error screen with removal button

3. **Check home screen**: Should see the migration dialog if any books have missing files

4. **Re-import books**: After removal, re-import should work and books will be stored permanently

## Technical Details

### Detection Logic
Books are marked as having missing files if:
- The `epubFilePath` contains `/cache/file_picker/` or `/cache/`
- The file doesn't exist at the stored path

### Error Codes
- `FILE_NOT_FOUND_CACHE`: Temporary cache path that no longer exists
- `FILE_NOT_FOUND`: Generic file not found error

### Database Operations
When removing books:
- Book record is deleted from Isar
- Associated content blocks are also deleted
- Changes are committed in a transaction

## Future Improvements

Potential enhancements for a smoother migration:
1. **Automatic Re-import**: If the original file can be found elsewhere, automatically copy it
2. **Backup Suggestions**: Prompt users to export their library before migration
3. **Migration Status Tracking**: Show which books have been successfully migrated
4. **Batch Import**: Allow selecting multiple books to re-import at once

## Support

If you encounter issues:
1. Check the console logs for detailed error messages
2. Ensure you have the original EPUB files available for re-import
3. Clear app cache and restart if the dialog doesn't appear
4. Try importing a single book first to verify the new storage system works

