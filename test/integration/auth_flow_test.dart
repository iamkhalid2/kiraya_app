import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import '../mocks/auth_mocks.dart';
import '../mocks/firestore_mocks.dart';
import '../setup/test_setup.dart';

void main() {
  late MockFirebaseAuth auth;
  late FakeFirebaseFirestore firestore;

  setUp(() {
    auth = TestAuthService.getMockAuth();
    firestore = TestFirestoreService.getFirestoreMock();
  });

  group('Authentication Flow Integration Tests', () {
    testWidgets('complete sign in and tenant creation flow',
        (WidgetTester tester) async {
      // Start with authentication
      final signInResult = await TestAuthService.signInWithGoogle(
        auth: auth,
        shouldSucceed: true,
      );
      expect(signInResult.user, isNotNull);

      // After successful auth, create a tenant
      await firestore.collection('tenants').add({
        'name': 'Test Tenant',
        'email': signInResult.user!.email,
        'rentAmount': 1000,
        'roomNumber': '101',
      });

      // Verify tenant was created
      final tenants = await TestFirestoreService.getTenants(firestore);
      expect(tenants.docs.length, equals(1));
      expect(tenants.docs.first.data()['name'], equals('Test Tenant'));
      expect(tenants.docs.first.data()['email'], equals(signInResult.user!.email));

      // Create a payment for the tenant
      final tenantId = tenants.docs.first.id;
      await firestore.collection('payments').add({
        'tenantId': tenantId,
        'amount': 1000,
        'date': DateTime.now().toIso8601String(),
        'method': 'online',
        'status': 'completed',
      });

      // Verify payment was recorded
      final payments = await TestFirestoreService.getPayments(firestore);
      expect(payments.docs.length, equals(1));
      expect(payments.docs.first.data()['tenantId'], equals(tenantId));
      expect(payments.docs.first.data()['amount'], equals(1000));
    });
  });
}