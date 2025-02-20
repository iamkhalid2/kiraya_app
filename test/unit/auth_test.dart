import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import '../mocks/auth_mocks.dart';

void main() {
  late MockFirebaseAuth auth;

  setUp(() {
    auth = TestAuthService.getMockAuth();
  });

  group('Authentication Tests', () {
    test('should start with no user signed in', () {
      expect(auth.currentUser, isNull);
      expect(auth.authStateChanges().map((user) => user != null), emits(false));
    });

    test('should sign in with test user', () async {
      auth = TestAuthService.getMockAuth(
        signedIn: true,
        mockUser: MockUser(
          isAnonymous: false,
          uid: 'test-uid',
          email: 'test@example.com',
          displayName: 'Test User',
        ),
      );

      expect(auth.currentUser, isNotNull);
      expect(auth.currentUser!.uid, equals('test-uid'));
      expect(auth.currentUser!.email, equals('test@example.com'));
      expect(auth.currentUser!.displayName, equals('Test User'));
    });

    test('should handle Google sign in successfully', () async {
      final result = await TestAuthService.signInWithGoogle(
        auth: auth,
        shouldSucceed: true,
      );

      expect(result, isNotNull);
      expect(result.user, isNotNull);
      expect(auth.currentUser, isNotNull);
    });

    test('should handle Google sign in failure', () async {
      expect(
        () => TestAuthService.signInWithGoogle(
          auth: auth,
          shouldSucceed: false,
        ),
        throwsA(
          isA<FirebaseAuthException>().having(
            (e) => e.code,
            'code',
            'sign_in_cancelled',
          ),
        ),
      );
    });

    test('should sign out successfully', () async {
      // First sign in
      auth = TestAuthService.getMockAuth(signedIn: true);
      expect(auth.currentUser, isNotNull);

      // Then sign out
      await auth.signOut();
      expect(auth.currentUser, isNull);
    });

    test('should handle auth state changes', () async {
      // Initial state check
      expect(auth.currentUser, isNull);

      // Sign in
      final signedInAuth = TestAuthService.getMockAuth(signedIn: true);
      expect(signedInAuth.currentUser, isNotNull);
      expect(
        signedInAuth.authStateChanges(),
        emits(isNotNull),
      );

      // Sign out
      await signedInAuth.signOut();
      expect(signedInAuth.currentUser, isNull);
      expect(
        signedInAuth.authStateChanges(),
        emits(isNull),
      );
    });
  });
}