# Reading Screen UI/UX Refactor Plan

This plan outlines the steps to create a new, advanced reading screen by combining the working EPUB logic from `reading_screen.dart` with the UI design from `image_dee662.png` and the features from `old_reading_screen.dart`.

We will build this in new files to avoid breaking the current implementation.

---

## Phase 1: Implement Reading Progress (Last Read Location)

**Objective:** Save and restore the user's reading position so they can resume where they left off. We will save the chapter index and the scroll position.

- [ ] **1. Create a Data Model for Progress:**

  Define a new Isar collection to store reading progress. A good structure would be:

  ```dart
  @collection
  class ReadingProgress {
    Id id = Isar.autoIncrement;
    @Index(unique: true)
    int bookId; // The ID of the book this progress belongs to
    String lastChapterHref;
    double lastScrollOffset;
  }
  ```

  Add this new collection to your Isar service.

- [ ] **2. Update the Controller to Manage Progress:**

  In `new_reading_controller.dart`, add logic to:

  - **Load Progress:** When the controller initializes, query Isar for the `ReadingProgress` for the current `bookId`.
  - **Save Progress:** Create a method like `saveProgress(chapterHref, scrollOffset)` that saves the current location to Isar. This should be called automatically when the chapter changes or when the screen is closed.
  - **Initial Position:** The controller should expose the initial chapter and scroll offset that the UI will use when it first builds.

- [ ] **3. Update the UI to Use Progress:**

  In `new_reading_screen.dart`, when the `PageView` is first built, use the "initial position" data from the controller to jump to the correct starting chapter.

  Use a `ScrollController` within each chapter's `SingleChildScrollView` to jump to the `lastScrollOffset` when the chapter loads.

  Listen to scroll notifications to report the current offset back to the `NewReadingController` so it can be saved.

---

## Phase 2: Setup New UI Architecture

**Objective:** Create the new file structure and set up the Riverpod controller to manage the complex UI state.

- [ ] **1. Create New Files:**

  Create a new folder: `lib/features/new_reader/`

  Inside, create:
  - `presentation/new_reading_screen.dart`
  - `presentation/widgets/new_reading_overlay.dart`
  - `application/new_reading_controller.dart`

- [ ] **2. Implement the Controller's UI State:**

  In `new_reading_controller.dart`, expand the state to manage:

  - Loading of the `EpubMetadata`.
  - Tracking `currentChapterIndex`.
  - A boolean for overlay visibility (`isOverlayVisible`).
  - A boolean for the settings panel (`isSettingsPanelVisible`).

  Files to reference: `reading_screen.dart` (for loading logic).

---

## Phase 3: Build the Overlay UI

**Objective:** Implement the main stacked layout with the immersive content view and the UI overlay that can be toggled.

- [ ] **1. Create the Main Stack in `new_reading_screen.dart`:**

  - The root widget should be a `Scaffold` with a `Stack`.
  - The first child of the `Stack` will be the `PageView` for the book content.
  - The second child will be the new `NewReadingOverlay` widget.
  - Wrap the `PageView` with a `GestureDetector`. Its `onTap` will call a method on your controller to toggle the `isOverlayVisible` state.

- [ ] **2. Build the `NewReadingOverlay` Widget:**

  In `new_reading_overlay.dart`, the root widget should be an `AnimatedOpacity` whose opacity is driven by `isOverlayVisible` from the controller.

  Inside, use a `Stack` to position the top AppBar, the bottom navigation "pill", and the side FABs.

  Files to reference: `old_reading_screen.dart`.

---

## Phase 4: Implement the New Navigation & FABs

**Objective:** Re-create the specific UI elements from the design image and integrate features from your old screen.

- [ ] **1. Build the Bottom Navigation "Pill":**

  Inside `new_reading_overlay.dart`, use an `Align` widget to place a styled `Container` at the bottom-center.

  Inside, create a `Row` with `IconButton`s for previous/next and a `Text` widget for chapter progress.

  Wire these buttons to call methods on your `NewReadingController`.

- [ ] **2. Add the Floating Action Buttons (FABs):**

  In `new_reading_overlay.dart`, use `Align` to place FABs on the left and right.

  - **Left FAB (Settings):** The `onPressed` should toggle the `isSettingsPanelVisible` boolean in the controller. In `new_reading_screen.dart`, use this boolean to show the `ReadingSettingsPanel`.

    Files to reuse: `reading_settings_panel.dart`.

  - **Right FAB (Overview/Info):** The `onPressed` should show the `BookOverviewDialog`.

    Files to reuse: `book_overview_dialog.dart`.

  Files to reference: `old_reading_screen.dart`.

---

## Phase 5: Final Polish & Cleanup

**Objective:** Ensure everything is working together smoothly and the old files are ready to be replaced.

- [ ] **1. Finalize State Management:** Ensure all UI elements correctly listen to the controller and rebuild when the state changes. Remove all `setState` calls.
- [ ] **2. Update App Navigation:** Update your `app_router.dart` to navigate to the new screen instead of the old one.
- [ ] **3. (Optional) Deprecate Old Files:** Once stable, you can delete the original `reading_screen.dart` and other unneeded files.
