import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  // Error messages
  static const String weakPasswordError = 'The password provided is too weak.';
  static const String emailInUseError = 'An account already exists for that email.';
  static const String userNotFoundError = 'No user found for that email.';
  static const String wrongPasswordError = 'Wrong password provided for that user.';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    clientId: '190795649881-75oncp5gms7hh9opcn4saf4nk665l2ve.apps.googleusercontent.com'
  );

  // Stream to listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign up with email and password
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user document
      if (userCredential.user != null) {
        final userDoc = _firestore.collection('users').doc(userCredential.user!.uid);
        await userDoc.set({
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw FirebaseAuthException(
          code: e.code,
          message: weakPasswordError,
        );
      } else if (e.code == 'email-already-in-use') {
        throw FirebaseAuthException(
          code: e.code,
          message: emailInUseError,
        );
      }
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw FirebaseAuthException(
          code: e.code,
          message: userNotFoundError,
        );
      } else if (e.code == 'wrong-password') {
        throw FirebaseAuthException(
          code: e.code,
          message: wrongPasswordError,
        );
      }
      rethrow;
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) return null;

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Create user document if it doesn't exist
      if (userCredential.user != null) {
        final userDoc = _firestore.collection('users').doc(userCredential.user!.uid);
        final docSnapshot = await userDoc.get();
        
        if (!docSnapshot.exists) {
          await userDoc.set({
            'email': userCredential.user!.email,
            'name': userCredential.user!.displayName,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
      
      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      if (e is FirebaseAuthException) {
        print('Firebase Auth Error Code: ${e.code}');
        print('Firebase Auth Error Message: ${e.message}');
      }
      rethrow;  // Throw the error so we can handle it in the UI
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
