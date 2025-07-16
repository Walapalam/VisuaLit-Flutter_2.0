import 'package:appwrite/appwrite.dart';

String parseAppwriteException(AppwriteException e) {
  switch (e.type) {
    case 'user_invalid_credentials':
      return 'Incorrect email or password. Please try again.';
    case 'user_already_exists':
      return 'An account with this email already exists.';
    case 'user_unauthorized':
      return 'Unauthorized access. Please log in again.';
    case 'general_network_error':
      return 'Network error. Please check your internet connection.';
    case 'user_email_already_verified':
      return 'This email is already verified.';
    case 'user_invalid_token':
      return 'Invalid or expired token. Please try again.';
    case 'user_password_reset_required':
      return 'Password reset required. Please check your email.';
    case 'user_session_already_exists':
      return 'A session is already active. Please log out first.';
    case 'general_rate_limit_exceeded':
      return 'Too many requests. Please try again later.';
    default:
      return e.message ?? 'An unexpected error occurred. Please try again.';
  }
}

String getSuccessMessage(String action) {
  switch (action) {
    case 'login':
      return 'Successfully logged in!';
    case 'signup':
      return 'Account created successfully!';
    case 'password_reset':
      return 'Password reset email sent. Please check your inbox.';
    case 'logout':
      return 'Successfully logged out!';
    default:
      return 'Operation completed successfully!';
  }
}