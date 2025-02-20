import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestFirestoreService {
  static FakeFirebaseFirestore getFirestoreMock() {
    return FakeFirebaseFirestore();
  }

  static Future<void> populateWithTestData(FakeFirebaseFirestore firestore) async {
    // Add sample tenants
    await firestore.collection('tenants').add({
      'name': 'John Doe',
      'email': 'john@example.com',
      'phone': '+1234567890',
      'rentAmount': 1000,
      'paymentDue': DateTime(2025, 3, 1).toIso8601String(),
      'roomNumber': '101',
      'joinDate': DateTime(2024, 1, 1).toIso8601String(),
    });

    await firestore.collection('tenants').add({
      'name': 'Jane Smith',
      'email': 'jane@example.com',
      'phone': '+1987654321',
      'rentAmount': 1200,
      'paymentDue': DateTime(2025, 3, 1).toIso8601String(),
      'roomNumber': '102',
      'joinDate': DateTime(2024, 2, 1).toIso8601String(),
    });

    // Add sample payments
    await firestore.collection('payments').add({
      'tenantId': 'tenant-1',
      'amount': 1000,
      'date': DateTime(2024, 2, 1).toIso8601String(),
      'method': 'cash',
      'status': 'completed',
    });

    await firestore.collection('payments').add({
      'tenantId': 'tenant-2',
      'amount': 1200,
      'date': DateTime(2024, 2, 1).toIso8601String(),
      'method': 'bank_transfer',
      'status': 'completed',
    });

    // Add sample properties
    await firestore.collection('properties').add({
      'name': 'Building A',
      'address': '123 Main St',
      'totalUnits': 10,
      'occupiedUnits': 8,
      'maintenanceRequests': 2,
    });
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getTenants(
    FakeFirebaseFirestore firestore,
  ) async {
    return firestore.collection('tenants').get();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getPayments(
    FakeFirebaseFirestore firestore,
  ) async {
    return firestore.collection('payments').get();
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>> getTenant(
    FakeFirebaseFirestore firestore,
    String tenantId,
  ) async {
    return firestore.collection('tenants').doc(tenantId).get();
  }

  static Future<void> updateTenant(
    FakeFirebaseFirestore firestore,
    String tenantId,
    Map<String, dynamic> data,
  ) async {
    await firestore.collection('tenants').doc(tenantId).update(data);
  }
}