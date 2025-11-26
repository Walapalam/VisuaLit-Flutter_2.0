# Firebase Setup Guide

This project relies on Firebase for Authentication, Storage, and Cloud Messaging. Follow these steps to set up the environment.

## Prerequisites

1.  **Firebase CLI**: Install the Firebase CLI if you haven't already.
    ```bash
    npm install -g firebase-tools
    ```
2.  **FlutterFire CLI**: Install the FlutterFire CLI.
    ```bash
    dart pub global activate flutterfire_cli
    ```

## Configuration

The project uses `flutterfire configure` to generate the `lib/firebase_options.dart` file, which contains the API keys and project IDs for each platform.

### If you have access to the existing Firebase project:

1.  Login to Firebase:
    ```bash
    firebase login
    ```
2.  Run the configuration command:
    ```bash
    flutterfire configure
    ```
3.  Select the existing project (e.g., `visualit-flutter`) and the platforms you want to support (Android, iOS, macOS, Web).
4.  This will overwrite/update `lib/firebase_options.dart`.

### If you are setting up a NEW Firebase project:

1.  Create a new project in the [Firebase Console](https://console.firebase.google.com/).
2.  Enable **Authentication** (Email/Password, Google Sign-In).
3.  Enable **Cloud Storage**.
4.  Enable **Cloud Messaging** (if used).
5.  Run `flutterfire configure` and select your new project.

## Dependencies

The following packages are already included in `pubspec.yaml`:

*   `firebase_core`
*   `firebase_auth`
*   `firebase_storage`
*   `firebase_messaging`
*   `google_sign_in`

## Initialization

Firebase is initialized in `lib/main.dart`:

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

Ensure `lib/firebase_options.dart` is present and error-free.
