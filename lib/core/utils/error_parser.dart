// lib/core/utils/error_parser.dart
import 'package:appwrite/appwrite.dart';

String parseAppwriteException(AppwriteException e) {
  // Use a switch on the error type for specific messages.
  switch (e.type) {
    case 'user_not_found':
      return 'No account found with that email. Please sign up.';
    case 'user_already_exists':
      return 'An account with this email already exists. Please log in.';
    case 'user_invalid_credentials':
      return 'Invalid email or password. Please try again.';
    case 'user_invalid_phone':
    case 'user_phone_not_found':
      return 'Invalid phone number provided.';
    case 'user_unauthorized':
      return 'You are not authorized for this action.';
    case 'user_session_not_found':
      return 'Your session has expired. Please log in again.';
    case 'general_argument_invalid':
    // This often happens with weak passwords during signup.
      if (e.message != null && e.message!.contains('password')) {
        return 'Password must be at least 8 characters long.';
      }
      return 'Invalid information provided. Please check the fields and try again.';
    default:
    // A fallback for any other errors.
      return e.message ?? 'An unknown error occurred. Please try again.';
  }
}