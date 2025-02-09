import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

class ErrorHandler {
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
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

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static String getFirebaseErrorMessage(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'You don\'t have permission to perform this action';
      case 'not-found':
        return 'The requested resource was not found';
      case 'already-exists':
        return 'This resource already exists';
      case 'failed-precondition':
        return 'Operation failed: please check your inputs';
      case 'aborted':
        return 'Operation was aborted, please try again';
      case 'out-of-range':
        return 'Operation was attempted past the valid range';
      case 'unimplemented':
        return 'Operation is not implemented or not supported';
      case 'internal':
        return 'Internal error occurred, please try again later';
      case 'unavailable':
        return 'Service is currently unavailable, please try again later';
      case 'unauthenticated':
        return 'User is not authenticated, please login again';
      case 'cancelled':
        return 'Operation was cancelled';
      default:
        return e.message ?? 'An unknown error occurred';
    }
  }

  static String getFormattedErrorMessage(dynamic error) {
    if (error is FirebaseException) {
      return getFirebaseErrorMessage(error);
    } else if (error is String) {
      return error;
    } else {
      return 'An unexpected error occurred';
    }
  }
}
