import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Centralized error handling for Firebase operations
class ErrorHandler {
  /// Handles Firebase errors and returns user-friendly messages
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      return _getAuthErrorMessage(error);
    } else if (error is FirebaseException) {
      return _getFirebaseErrorMessage(error);
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Handles Firebase Auth errors
  static String _getAuthErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication error: ${error.message ?? "Unknown error"}';
    }
  }

  /// Handles Firestore errors
  static String _getFirebaseErrorMessage(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'You do not have permission to perform this action.';
      case 'not-found':
        return 'The requested data was not found.';
      case 'already-exists':
        return 'This item already exists.';
      case 'resource-exhausted':
        return 'Too many requests. Please try again later.';
      case 'failed-precondition':
        return 'Operation failed. Please check your data and try again.';
      case 'aborted':
        return 'Operation was aborted. Please try again.';
      case 'out-of-range':
        return 'Invalid data range provided.';
      case 'unimplemented':
        return 'This feature is not yet implemented.';
      case 'internal':
        return 'Internal server error. Please try again later.';
      case 'unavailable':
        return 'Service temporarily unavailable. Please try again.';
      case 'data-loss':
        return 'Data loss detected. Please contact support.';
      case 'unauthenticated':
        return 'Please log in to continue.';
      case 'invalid-argument':
        return 'Invalid data provided. Please check your input.';
      case 'deadline-exceeded':
        return 'Request timeout. Please try again.';
      case 'cancelled':
        return 'Operation was cancelled.';
      default:
        return 'Error: ${error.message ?? "Unknown error"}';
    }
  }

  /// Handles Firebase Storage errors (via FirebaseException)
  // ignore: unused_element
  static String _getStorageErrorMessage(FirebaseException error) {
    switch (error.code) {
      case 'object-not-found':
        return 'File not found.';
      case 'bucket-not-found':
        return 'Storage bucket not found.';
      case 'project-not-found':
        return 'Project not found.';
      case 'quota-exceeded':
        return 'Storage quota exceeded.';
      case 'unauthenticated':
        return 'Please log in to upload files.';
      case 'unauthorized':
        return 'You do not have permission to upload files.';
      case 'retry-limit-exceeded':
        return 'Upload failed after multiple attempts.';
      case 'invalid-checksum':
        return 'File upload verification failed.';
      case 'canceled':
        return 'Upload was cancelled.';
      case 'invalid-event-name':
        return 'Invalid upload event.';
      case 'invalid-url':
        return 'Invalid file URL.';
      case 'invalid-argument':
        return 'Invalid file data.';
      case 'no-default-bucket':
        return 'No storage bucket configured.';
      case 'cannot-slice-blob':
        return 'File processing error.';
      case 'server-file-wrong-size':
        return 'File size mismatch. Please try again.';
      default:
        return 'Upload error: ${error.message ?? "Unknown error"}';
    }
  }

  /// Shows error snackbar
  static void showErrorSnackbar(BuildContext context, dynamic error) {
    if (!context.mounted) return;
    
    final message = getErrorMessage(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Shows success snackbar
  static void showSuccessSnackbar(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Shows info snackbar
  static void showInfoSnackbar(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue[700],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Executes a Firebase operation with error handling
  static Future<T?> executeWithErrorHandling<T>({
    required BuildContext context,
    required Future<T> Function() operation,
    String? successMessage,
    bool showLoading = true,
  }) async {
    try {
      final result = await operation();
      if (context.mounted && successMessage != null) {
        showSuccessSnackbar(context, successMessage);
      }
      return result;
    } catch (error) {
      if (context.mounted) {
        showErrorSnackbar(context, error);
      }
      return null;
    }
  }
}
