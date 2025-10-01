// lib/core/api/appwrite_client.dart

import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

// This file sets up the Appwrite client and provides its services
// to the rest of the app using Riverpod.

// Provider for the Appwrite Client. This is the main connection object.
final appwriteClientProvider = Provider<Client>((ref) {
  // Read the project ID and endpoint from the loaded .env file
  final projectId = dotenv.env['APPWRITE_PROJECT_ID'];
  final endpoint = dotenv.env['APPWRITE_ENDPOINT'];

  // Check if the environment variables are set
  if (projectId == null || endpoint == null) {
    throw Exception(
        'Appwrite Project ID or Endpoint not found in .env file. Make sure it is set up correctly.');
  }

  // Create and configure the Appwrite client
  Client client = Client();
  client
    ..setEndpoint(endpoint)
    ..setProject(projectId);
  // setSelfSigned has been removed for production use with Appwrite Cloud
  // Only use setSelfSigned(status: true) for local development with self-signed certificates

  return client;
});

// Provider for the Appwrite Account service.
// This service handles all user authentication tasks (login, signup, etc.).
final appwriteAccountProvider = Provider<Account>((ref) {
  // Watch the appwriteClientProvider. If it changes, this provider will rebuild.
  final client = ref.watch(appwriteClientProvider);
  return Account(client);
});

// New Firebase Auth provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Provider for the Appwrite Databases service.
// This service is used to interact with your collections and documents.
final appwriteDatabasesProvider = Provider<Databases>((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Databases(client);
});

// Provider for the Appwrite Storage service.
// This service will handle file uploads and downloads (e.g., book covers, EPUB files).
final appwriteStorageProvider = Provider<Storage>((ref) {
  final client = ref.watch(appwriteClientProvider);
  return Storage(client);
});