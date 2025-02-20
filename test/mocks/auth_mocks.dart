import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';

class TestAuthService {
  static MockFirebaseAuth getMockAuth({
    bool signedIn = false,
    MockUser? mockUser,
  }) {
    final user = mockUser ?? MockUser(
      isAnonymous: false,
      uid: 'test-uid',
      email: 'test@example.com',
      displayName: 'Test User',
    );
    
    final auth = MockFirebaseAuth(
      mockUser: signedIn ? user : null,
      signedIn: signedIn,
    );
    
    // Ensure the auth state is properly initialized
    if (signedIn) {
      auth.mockUser = user;
    }
    
    return auth;
  }

  static Future<UserCredential> signInWithGoogle({
    required MockFirebaseAuth auth,
    bool shouldSucceed = true,
  }) async {
    final googleSignIn = MockGoogleSignIn();
    final signInAccount = await googleSignIn.signIn();
    if (!shouldSucceed || signInAccount == null) {
      throw FirebaseAuthException(
        code: 'sign_in_cancelled',
        message: 'Google sign in was cancelled',
      );
    }

    final googleAuth = await signInAccount.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return auth.signInWithCredential(credential);
  }
}
