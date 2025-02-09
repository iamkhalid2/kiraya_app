import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_settings.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _userId;
  bool _initialized = false;

  void initialize(String userId) {
    _userId = userId;
    _initialized = true;
  }

  void _checkInitialized() {
    if (!_initialized || _userId == null) {
      throw Exception('FirestoreService not initialized');
    }
  }

  // User Settings Collection Reference
  CollectionReference get _userSettings => _firestore.collection('users/$_userId/settings');

  // Get the current user's settings document
  DocumentReference get _currentUserSettings {
    _checkInitialized();
    return _userSettings.doc('preferences');
  }

  // Stream of user settings
  Stream<DocumentSnapshot> get userSettingsStream {
    _checkInitialized();
    return _currentUserSettings.snapshots();
  }

  // Get user settings
  Future<UserSettings> getUserSettings() async {
    _checkInitialized();
    try {
      final doc = await _currentUserSettings.get();
      
      if (!doc.exists) {
        // Create default settings if they don't exist
        final defaultSettings = UserSettings();
        await _currentUserSettings.set(defaultSettings.toMap());
        return defaultSettings;
      }

      return UserSettings.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to get user settings: $e');
    }
  }

  // Update user settings
  Future<void> updateUserSettings(UserSettings settings) async {
    _checkInitialized();
    try {
      await _currentUserSettings.update(settings.toMap());
    } catch (e) {
      if (e is FirebaseException && e.code == 'not-found') {
        // Create settings if they don't exist
        await _currentUserSettings.set(settings.toMap());
      } else {
        throw Exception('Failed to update user settings: $e');
      }
    }
  }

  // Delete user settings
  Future<void> deleteUserSettings() async {
    _checkInitialized();
    try {
      await _currentUserSettings.delete();
    } catch (e) {
      throw Exception('Failed to delete user settings: $e');
    }
  }

  // Tenants Collection Reference
  CollectionReference get _tenants {
    _checkInitialized();
    return _firestore.collection('users/$_userId/tenants');
  }

  // Tenants stream with ordering and error handling
  Stream<QuerySnapshot> get tenantsStream {
    _checkInitialized();
    return _tenants
      .orderBy('name')
      .snapshots()
      .handleError((error) {
        debugPrint('Error in tenants stream: $error');
        // Re-throw to let the UI handle it
        throw Exception('Failed to load tenants: $error');
      });
  }

  // Add a new tenant using transaction
  Future<DocumentReference> addTenant(Map<String, dynamic> tenantData) async {
    _checkInitialized();
    try {
      final docRef = _tenants.doc();
      await _firestore.runTransaction((transaction) async {
        transaction.set(docRef, {
          ...tenantData,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
      return docRef;
    } catch (e) {
      debugPrint('Error adding tenant: $e');
      throw Exception('Failed to add tenant: $e');
    }
  }

  // Update a tenant using transaction
  Future<void> updateTenant(String tenantId, Map<String, dynamic> tenantData) async {
    _checkInitialized();
    try {
      final docRef = _tenants.doc(tenantId);
      await _firestore.runTransaction((transaction) async {
        // Verify document exists
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          throw Exception('Tenant not found');
        }
        
        transaction.update(docRef, {
          ...tenantData,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      debugPrint('Error updating tenant: $e');
      throw Exception('Failed to update tenant: $e');
    }
  }

  // Delete a tenant using transaction
  Future<void> deleteTenant(String tenantId) async {
    _checkInitialized();
    try {
      final docRef = _tenants.doc(tenantId);
      await _firestore.runTransaction((transaction) async {
        // Verify document exists
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          throw Exception('Tenant not found');
        }
        
        transaction.delete(docRef);
      });
    } catch (e) {
      debugPrint('Error deleting tenant: $e');
      throw Exception('Failed to delete tenant: $e');
    }
  }

  // Initialize user data
  Future<void> initializeUserData() async {
    _checkInitialized();
    try {
      // Create default settings if they don't exist
      final settingsDoc = await _currentUserSettings.get();
      if (!settingsDoc.exists) {
        await _currentUserSettings.set(UserSettings().toMap());
      }
    } catch (e) {
      throw Exception('Failed to initialize user data: $e');
    }
  }
}
