import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user document reference
  DocumentReference get _userDoc => 
      _firestore.collection('users').doc(_auth.currentUser!.uid);

  // Collection references
  CollectionReference get _tenants => _userDoc.collection('tenants');

  // Tenants
  Stream<QuerySnapshot> get tenantsStream => _tenants.snapshots();

  Future<void> addTenant(Map<String, dynamic> tenant) {
    return _tenants.add(tenant);
  }

  Future<void> updateTenant(String id, Map<String, dynamic> tenant) {
    return _tenants.doc(id).update(tenant);
  }

  Future<void> deleteTenant(String id) {
    return _tenants.doc(id).delete();
  }

}
