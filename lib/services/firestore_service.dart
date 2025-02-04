import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_settings.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user document reference
  DocumentReference? get _userDoc {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _firestore.collection('users').doc(user.uid);
  }

  // Collection references
  CollectionReference? get _tenants => _userDoc?.collection('tenants');
  DocumentReference? get _userSettings => _userDoc?.collection('settings').doc('config');

  // User Settings
  Stream<DocumentSnapshot?> get userSettingsStream => 
    _userSettings?.snapshots() ?? Stream.value(null);

  Future<void> updateUserSettings(UserSettings settings) async {
    final settingsRef = _userSettings;
    if (settingsRef == null) throw Exception('User not authenticated');
    return settingsRef.set(settings.toMap());
  }

  Future<UserSettings> getUserSettings() async {
    final settingsRef = _userSettings;
    if (settingsRef == null) return UserSettings(); // Return default settings if not authenticated
    
    final doc = await settingsRef.get();
    if (!doc.exists) {
      // Create default settings if they don't exist
      final defaultSettings = UserSettings();
      await settingsRef.set(defaultSettings.toMap());
      return defaultSettings;
    }
    return UserSettings.fromMap(doc.data() as Map<String, dynamic>);
  }

  // Tenants
  Stream<QuerySnapshot?> get tenantsStream => 
    _tenants?.snapshots() ?? Stream.value(null);

  Future<void> addTenant(Map<String, dynamic> tenant) async {
    final tenantsRef = _tenants;
    if (tenantsRef == null) throw Exception('User not authenticated');
    final docRef = await tenantsRef.add(tenant);
    return;
  }

  Future<void> updateTenant(String id, Map<String, dynamic> tenant) async {
    final tenantsRef = _tenants;
    if (tenantsRef == null) throw Exception('User not authenticated');
    return tenantsRef.doc(id).update(tenant);
  }

  Future<void> deleteTenant(String id) async {
    final tenantsRef = _tenants;
    if (tenantsRef == null) throw Exception('User not authenticated');
    return tenantsRef.doc(id).delete();
  }

}
