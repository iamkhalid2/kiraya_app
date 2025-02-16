import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '190795649881-f14tl88k9sr2590pocthc1cge4a6p3qk.apps.googleusercontent.com',
    scopes: ['email'],  // Only request basic email scope
  );
  bool _isLoading = false;
  bool _isInitialized = false;

  User? get user => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  bool get isLoading => _isLoading;
  bool get isAuthenticated => user != null;
  bool get isInitialized => _isInitialized;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _isInitialized = true;
      notifyListeners();
    });
  }

  void _setLoading(bool value) {
    if (_isInitialized) return;
    _isLoading = value;
    notifyListeners();
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    if (kIsWeb) {
      try {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        return await _auth.signInWithPopup(googleProvider);
      } catch (e) {
        throw _handleAuthError(e);
      }
    } else {
      try {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        return await _auth.signInWithCredential(credential);
      } catch (e) {
        if (e is PlatformException && e.code == 'sign_in_failed') {
          throw 'Google Sign In failed. Please try again.';
        }
        throw _handleAuthError(e);
      }
    }
  }

  String _handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'Invalid email address';
        case 'user-disabled':
          return 'This account has been disabled';
        case 'user-not-found':
          return 'No user found with this email';
        case 'wrong-password':
          return 'Incorrect password';
        case 'email-already-in-use':
          return 'An account already exists with this email';
        case 'weak-password':
          return 'Please use a stronger password';
        case 'operation-not-allowed':
          return 'This operation is not allowed';
        default:
          return error.message ?? 'An error occurred during authentication';
      }
    }
    return 'An unexpected error occurred';
  }

  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
  }
}
