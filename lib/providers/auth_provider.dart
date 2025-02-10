import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isLoading = false;
  bool _isInitialized = false;

  User? get user => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  bool get isLoading => _isLoading;
  bool get isAuthenticated => user != null;
  bool get isInitialized => _isInitialized;

  AuthProvider() {
    // Listen to auth state changes to update initialization state
    _auth.authStateChanges().listen((User? user) {
      _isInitialized = true;
      notifyListeners();
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    _setLoading(true);
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _setLoading(false);
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw _handleAuthError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw _handleAuthError(e);
    } finally {
      _setLoading(false);
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
        case 'operation-not-allowed':
          return 'This operation is not allowed';
        case 'weak-password':
          return 'Please use a stronger password';
        case 'account-exists-with-different-credential':
          return 'An account already exists with a different sign-in method';
        case 'invalid-credential':
          return 'Invalid credentials';
        case 'network-request-failed':
          return 'Network error. Please check your connection.';
        default:
          return 'Authentication error: ${error.message}';
      }
    }
    return 'An unexpected error occurred';
  }

  Future<void> resetPassword(String email) async {
    _setLoading(true);
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updatePassword(String newPassword) async {
    _setLoading(true);
    try {
      if (_auth.currentUser == null) {
        throw 'No user is currently signed in';
      }
      await _auth.currentUser!.updatePassword(newPassword);
    } catch (e) {
      throw _handleAuthError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateEmail(String newEmail) async {
    _setLoading(true);
    try {
      if (_auth.currentUser == null) {
        throw 'No user is currently signed in';
      }
      await _auth.currentUser!.verifyBeforeUpdateEmail(newEmail);
    } catch (e) {
      throw _handleAuthError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> reauthenticate(String password) async {
    _setLoading(true);
    try {
      if (_auth.currentUser == null || _auth.currentUser!.email == null) {
        throw 'No user is currently signed in';
      }
      
      final credential = EmailAuthProvider.credential(
        email: _auth.currentUser!.email!,
        password: password,
      );

      await _auth.currentUser!.reauthenticateWithCredential(credential);
    } catch (e) {
      throw _handleAuthError(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteAccount() async {
    _setLoading(true);
    try {
      if (_auth.currentUser == null) {
        throw 'No user is currently signed in';
      }
      await _auth.currentUser!.delete();
    } catch (e) {
      throw _handleAuthError(e);
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    _isInitialized = false;
    super.dispose();
  }
}
