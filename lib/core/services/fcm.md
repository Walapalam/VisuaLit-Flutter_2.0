Firebase Cloud Messaging (FCM) Setup Guide for Flutter (Android)

This guide covers how to connect your Flutter Android app to FCM specifically for Marketing Notifications.

Prerequisites

A Flutter project created.

A Google Account.

An Android device or Emulator (with Google Play Services installed).

Phase 1: Firebase Console Setup

Create Project:

Go to the Firebase Console.

Click "Add project" and follow the steps (disable Google Analytics for now to keep it simple).

Register Android App:

Click the Android Icon (robot) in the project overview.

Android package name: Open your Flutter project, go to android/app/build.gradle, and find applicationId (e.g., com.example.myapp). Paste it here.

Click Register app.

Download Config File:

Download the google-services.json file.

Move this file into your Flutter project at this exact path:
[your_project_folder]/android/app/google-services.json

Phase 2: Flutter Dependencies

Open your pubspec.yaml file.

Add these two packages under dependencies:

dependencies:
flutter:
sdk: flutter
# Core Firebase functionality
firebase_core: ^3.6.0
# Cloud Messaging functionality
firebase_messaging: ^15.1.3


(Note: Check pub.dev for the absolute latest versions, but these are standard).

Run flutter pub get in your terminal.

Phase 3: Android Native Configuration

You need to tell the Android build system to read that JSON file you downloaded.

1. Project-level Gradle (android/build.gradle)
   Add the Google Services classpath inside the dependencies block:

buildscript {
dependencies {
// ... other dependencies
classpath 'com.google.gms:google-services:4.4.2' // Add this line
}
}


2. App-level Gradle (android/app/build.gradle)
   Add the plugin at the very bottom of the file (or in the plugins block at the top):

apply plugin: 'com.android.application'
apply plugin: 'com.google.gms.google-services' // Add this line
// ... rest of file


3. Android Manifest (android/app/src/main/AndroidManifest.xml)
   For Android 13+ (API 33), you explicitly need permission to post notifications. Add this permission inside the <manifest> tag, above the <application> tag.

<manifest xmlns:android="[http://schemas.android.com/apk/res/android](http://schemas.android.com/apk/res/android)" package="com.example.yourapp">

    <!-- Add this permission for Android 13+ support -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.INTERNET"/>

    <application ...>
        <!-- ... -->
    </application>
</manifest>


Phase 4: Flutter Code Implementation

Now we write the code to initialize Firebase and ask the user for permission.

Open lib/main.dart and replace/update your main function:

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
// 1. Ensure Flutter bindings are initialized
WidgetsFlutterBinding.ensureInitialized();

// 2. Initialize Firebase
await Firebase.initializeApp();

// 3. Run the app
runApp(const MyApp());
}

class MyApp extends StatefulWidget {
const MyApp({super.key});

@override
State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

@override
void initState() {
super.initState();
// 4. Setup FCM when the app starts
setupFCM();
}

Future<void> setupFCM() async {
final messaging = FirebaseMessaging.instance;

    // A. Request Permission (Required for Android 13+)
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      
      // B. Get the token
      // This is the "Address" you need to send a message to THIS specific device
      String? token = await messaging.getToken();
      print("========================================");
      print("FCM TOKEN: $token");
      print("========================================");
      
      // In a real app, you would send this token to your backend database here.
      
    } else {
      print('User declined or has not accepted permission');
    }
}

@override
Widget build(BuildContext context) {
return MaterialApp(
home: Scaffold(
appBar: AppBar(title: const Text("Marketing Notifications")),
body: const Center(
child: Text("Check your debug console for the Token!"),
),
),
);
}
}


Phase 5: How to Test (The Fun Part)

Run the App: Connect your physical Android device (recommended) or Emulator. Run flutter run.

Accept Permissions: If on Android 13+, tap "Allow" on the notification popup.

Get the Token: Look at your VS Code/Terminal debug console. Find the line that says FCM TOKEN: .... Copy this long string.

Go to Firebase Console:

Click Messaging (under the Engage section in the left sidebar).

Click Create your first campaign.

Select "Firebase Notification messages".

Compose Message:

Title: "Flash Sale!"

Text: "50% off all eBooks today only."

Target:

Click Test on device (button on the right).

Paste the token you copied from the console.

Click the + button to add it.

Click Test.

Result:

If App is in Background (Home screen): You will see a notification banner appear in the system tray!

If App is in Foreground (Open): Nothing will happen visually (this is normal default behavior), but the message was received. To see it while the app is open, you need extra code, but for marketing, background delivery is usually what matters most.