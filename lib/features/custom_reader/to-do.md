# Reading Screen Refactor: Action Plan

This document outlines the step-by-step plan to refactor the EPUB reading screen. The goal is to build a new, simpler, chapter-based rendering model that is more performant and maintainable.

**Strategy:** All new logic and UI will be built in new files to avoid disrupting the existing implementation. We will switch the navigation to the new screen once it is feature-complete and tested.

---

## Overall Progress

- [x] Phase A: Foundation (EPUB Parsing & Basic Rendering)
- [ ] Phase B: Core Reading UI & Highlighting POC
- [ ] Phase C: Full Feature Implementation
- [ ] Phase D: Polish & Testing

---

## Phase A: Foundation (Estimated: Weeks 1-3) — Completed

The goal of this phase is to build the foundational components for the new reader.

### Task 1: Create a Dedicated EPUB Parsing Service
**Status:** Completed

**Objective:** Encapsulate all EPUB file processing logic into a new, reusable service.

**Key Steps:**
- Use the archive package to extract the contents of the .epub file.
- Parse `META-INF/container.xml` to find the `.opf` file.
- Parse the `.opf` file (XML) to extract metadata, manifest, and spine.
- Parse the navigation file (`toc.ncx` or `nav.xhtml`) for the table of contents.

**Affected Files:**
- `lib/features/reader/application/epub_parser_service.dart` (New File)
- `pubspec.yaml` (To add `archive` and `xml` packages).

### Task 2: Integrate a Third-Party HTML Rendering Library in a New Screen
**Status:** Completed

**Objective:** Create the new reading screen and use a robust library to handle the complexities of rendering EPUB content.

**Key Steps:**
- Add the `flutter_html` package to `pubspec.yaml`.
- Create a new `new_reading_screen.dart` file.
- In this new screen, use `flutter_html` to render the content of a single chapter in a scrollable view. The old `BookPageWidget` will not be used.

**Affected Files:**
- `pubspec.yaml` (To add `flutter_html`).
- `lib/features/reader/presentation/new_reading_screen.dart` (New File)

### Task 3: Implement Chapter-Based State Management
**Status:** Completed

**Objective:** Create a new Riverpod controller to manage the state of the new reading screen, focusing on chapters as the primary unit.

**Key Steps:**
- Create a new `new_reading_controller.dart` file.
- Define a `NewReadingState` class that holds a list of parsed `Chapter` objects and the `currentChapterIndex`.
- The `NewReadingScreen` will be driven by this state, displaying the XHTML of the current chapter.

**Affected Files:**
- `lib/features/reader/presentation/new_reading_controller.dart` (New File)
- `lib/features/reader/presentation/new_reading_screen.dart` (To consume the new controller)

---

## Phase B: Core Reading UI & Highlighting POC (Estimated: Weeks 4-5)

Focus on building the UI and de-risking the most complex feature.

### Task 4: Implement Stacked Overlay UI in the New Screen
**Status:** [ ] Incomplete

**Objective:** Create an immersive reading experience with overlaid controls.

**Key Steps:**
- In `new_reading_screen.dart`, use a `Stack` widget as the root.
- The first child will be the chapter content. Subsequent children will be the UI controls (AppBar, etc.) wrapped in `AnimatedOpacity`.
- A `GestureDetector` will toggle the visibility of the UI overlays.

**Affected Files:**
- `lib/features/reader/presentation/new_reading_screen.dart` (Layout and state changes)

### Task 5: Apply CSS and Image Styling from EPUB
**Status:** [ ] Incomplete

**Objective:** Ensure the book content is displayed with its intended styling.

**Key Steps:**
- Extend the `EpubParserService` to read and merge all CSS files.
- Pass the combined CSS to the `flutter_html` widget in `new_reading_screen.dart`.
- Create a custom `ImageRenderer` for `flutter_html` to load images from the extracted EPUB directory.

**Affected Files:**
- `lib/features/reader/application/epub_parser_service.dart` (Extend service)
- `lib/features/reader/presentation/new_reading_screen.dart` (Pass styles to widget)

### Task 6: Proof-of-Concept for Text Highlighting
**Status:** [ ] Incomplete

**Objective:** Validate a technical approach for text selection before full implementation.

**Key Steps:**
- Create a new, separate POC widget.
- Use `SelectableText.rich` and its `onSelectionChanged` callback.
- Use a simple Riverpod provider to manage a list of selected `TextRange` objects.
- Re-render the widget to apply a background color to the selected ranges.

**Affected Files:**
- `lib/features/reader/presentation/widgets/highlight_poc.dart` (New File for POC)

---

## Phase C: Full Feature Implementation (Estimated: Weeks 6-8)

Build out advanced features based on the solid foundation.

### Task 7: Full Highlighting System
**Status:** [ ] Incomplete

**Objective:** Integrate a complete, persistent text highlighting feature.

**Key Steps:**
- Implement the selection mechanism within the new reader, based on the POC.
- Create an Isar model for `Highlight`.
- Save highlight data (chapter, offsets, color) to Isar.
- The `NewReadingController` will fetch and provide highlights for the current chapter to the UI.

**Affected Files:**
- `lib/features/reader/data/highlight.dart` (New Isar model)
- `lib/core/providers/isar_provider.dart` (Update schema)
- `lib/features/reader/presentation/new_reading_controller.dart` (Manage highlight state)
- `lib/features/reader/presentation/new_reading_screen.dart` (Handle gestures and render highlights)

---

## Phase D: Polish & Testing (Estimated: Weeks 9-10)

Finalize the feature and ensure its quality.

### Task 8: Performance Optimization & Caching
**Status:** [ ] Incomplete

**Objective:** Ensure the new reader is fast and responsive.

**Key Steps:**
- Implement a chapter content cache in Isar to avoid re-reading files.
- Implement chapter pre-loading in the `NewReadingController`.
- Profile the app with Flutter DevTools to fix bottlenecks.

**Affected Files:**
- `lib/core/services/isar_service.dart` (For caching)
- `lib/features/reader/presentation/new_reading_controller.dart` (For pre-loading)

### Task 9: UI/UX Refinements and Final Testing
**Status:** [ ] Incomplete

**Objective:** Polish the UI and conduct thorough testing.

**Key Steps:**
- Refine animations and transitions.
- Ensure full responsiveness.
- Test with a wide variety of EPUB files.
- Write unit and widget tests for the new services and critical UI components.

**Affected Files:**
- `lib/features/reader/presentation/new_reading_screen.dart`
- `test/` directory (new test files)

Manually test the app with a diverse collection of EPUB files (different versions, complex layouts, various languages) to catch edge cases.

Write unit and widget tests for the new services and critical UI components.
