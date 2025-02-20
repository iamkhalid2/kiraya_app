import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import '../mocks/firestore_mocks.dart';

void main() {
  late FakeFirebaseFirestore firestore;

  setUp(() {
    firestore = TestFirestoreService.getFirestoreMock();
  });

  group('Firestore Operations Tests', () {
    test('should populate test data successfully', () async {
      await TestFirestoreService.populateWithTestData(firestore);

      final tenants = await TestFirestoreService.getTenants(firestore);
      final payments = await TestFirestoreService.getPayments(firestore);
      final properties = await firestore.collection('properties').get();

      expect(tenants.docs.length, equals(2));
      expect(payments.docs.length, equals(2));
      expect(properties.docs.length, equals(1));
    });

    group('Tenant Operations', () {
      setUp(() async {
        await TestFirestoreService.populateWithTestData(firestore);
      });

      test('should retrieve all tenants', () async {
        final tenants = await TestFirestoreService.getTenants(firestore);
        
        expect(tenants.docs.length, equals(2));
        expect(
          tenants.docs.map((doc) => doc.data()['name']),
          containsAll(['John Doe', 'Jane Smith']),
        );
      });

      test('should retrieve specific tenant', () async {
        final tenants = await TestFirestoreService.getTenants(firestore);
        final firstTenantId = tenants.docs.first.id;
        
        final tenant = await TestFirestoreService.getTenant(firestore, firstTenantId);
        
        expect(tenant.exists, isTrue);
        expect(tenant.data()!['name'], equals('John Doe'));
        expect(tenant.data()!['rentAmount'], equals(1000));
      });

      test('should update tenant information', () async {
        final tenants = await TestFirestoreService.getTenants(firestore);
        final firstTenantId = tenants.docs.first.id;
        
        await TestFirestoreService.updateTenant(
          firestore,
          firstTenantId,
          {'rentAmount': 1100, 'phone': '+1111111111'},
        );
        
        final updatedTenant = await TestFirestoreService.getTenant(firestore, firstTenantId);
        expect(updatedTenant.data()!['rentAmount'], equals(1100));
        expect(updatedTenant.data()!['phone'], equals('+1111111111'));
      });
    });

    group('Payment Operations', () {
      setUp(() async {
        await TestFirestoreService.populateWithTestData(firestore);
      });

      test('should retrieve all payments', () async {
        final payments = await TestFirestoreService.getPayments(firestore);
        
        expect(payments.docs.length, equals(2));
        expect(
          payments.docs.map((doc) => doc.data()['amount']),
          containsAll([1000, 1200]),
        );
      });

      test('should add new payment', () async {
        await firestore.collection('payments').add({
          'tenantId': 'tenant-3',
          'amount': 1500,
          'date': DateTime.now().toIso8601String(),
          'method': 'online',
          'status': 'pending',
        });

        final payments = await TestFirestoreService.getPayments(firestore);
        expect(payments.docs.length, equals(3));
        expect(
          payments.docs.map((doc) => doc.data()['amount']),
          containsAll([1000, 1200, 1500]),
        );
      });
    });

    group('Property Operations', () {
      setUp(() async {
        await TestFirestoreService.populateWithTestData(firestore);
      });

      test('should retrieve property information', () async {
        final properties = await firestore.collection('properties').get();
        final property = properties.docs.first.data();

        expect(property['name'], equals('Building A'));
        expect(property['totalUnits'], equals(10));
        expect(property['occupiedUnits'], equals(8));
      });

      test('should update property information', () async {
        final properties = await firestore.collection('properties').get();
        final propertyId = properties.docs.first.id;

        await firestore.collection('properties').doc(propertyId).update({
          'occupiedUnits': 9,
          'maintenanceRequests': 1,
        });

        final updatedProperty = await firestore.collection('properties').doc(propertyId).get();
        expect(updatedProperty.data()!['occupiedUnits'], equals(9));
        expect(updatedProperty.data()!['maintenanceRequests'], equals(1));
      });
    });
  });
}