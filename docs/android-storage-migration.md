# Android storage migration: Scoped storage + SAF

This app migrates away from MANAGE_EXTERNAL_STORAGE and legacy external storage to comply with Google Play policy. We now use:

- App-scoped storage for the library (no runtime permission):
  - Android: getExternalStorageDirectory()/VisuaLit
  - iOS/others: getApplicationDocumentsDirectory()/VisuaLit
- User-initiated imports via the system file picker (no broad permission)
- Optional export via system CREATE_DOCUMENT (planned)
- Audiobooks discovery via MediaStore with READ_MEDIA_AUDIO (API 33+) or READ_EXTERNAL_STORAGE (<=32)

## What changed

- Removed permissions and flags:
  - android.permission.MANAGE_EXTERNAL_STORAGE
  - android.permission.WRITE_EXTERNAL_STORAGE
  - android:requestLegacyExternalStorage
- Kept conditional read for media/audio only:
  - android.permission.READ_MEDIA_AUDIO (33+)
  - android.permission.READ_EXTERNAL_STORAGE (maxSdkVersion 32)

## New storage layout

- App library folder (default):
  - Android: <externalFilesDir>/VisuaLit
  - iOS: <ApplicationDocuments>/VisuaLit
- Library watcher monitors only this folder.

## Import EPUBs

- Pick files (multiple) using FilePicker with withData=true.
- Optional: "Import Directory" lets users pick a directory and we recursively load .epub files (no broad permission).

## Export EPUBs (optional, planned)

- Use Storage Access Framework (CREATE_DOCUMENT) to let the user save a copy anywhere, including Downloads.

## Audiobooks

- Use media_store_plus to query music tracks.
- Runtime permission:
  - Android 13+ (API 33+): READ_MEDIA_AUDIO
  - Android 10–12 (API 29–32): READ_EXTERNAL_STORAGE
- Alternatively, users can pick individual MP3s or a folder via the system picker.

## Policy alignment

- No broad file access; only user-initiated file reads/writes.
- No requestLegacyExternalStorage.
- No MANAGE_EXTERNAL_STORAGE.

## Migration guidance for users

- If you had files under Downloads/VisuaLit from older versions, use "Import from Downloads/VisuaLit" to copy them into the app library.

## Troubleshooting

- If downloads fail, check network permissions and connectivity.
- If imports don’t appear in the Library, confirm the files are valid .epub and try re-importing.
- On Android 13+, ensure READ_MEDIA_AUDIO is granted when scanning audiobooks via MediaStore.

