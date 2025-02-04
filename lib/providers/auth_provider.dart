import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;

  AuthProvider() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // Getters
  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  // Sign up with email and password
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      return await _authService.signUpWithEmail(email, password);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      try {
        return await _authService.signInWithEmail(email, password);
      } catch (e) {
        _isLoading = false;
        notifyListeners();
        rethrow;
      }
    } finally {
      // Only set loading to false if we haven't already done so in the catch block
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      final UserCredential? result = await _authService.signInWithGoogle();
      return result != null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      await _authService.signOut();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
