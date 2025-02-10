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
    // Ensure user document exists
    _initializeUserData().catchError((e) {
      debugPrint('Error initializing user data: $e');
    });
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

  // Stream of user settings with error handling
  Stream<DocumentSnapshot> get userSettingsStream {
    _checkInitialized();
    return _currentUserSettings.snapshots().handleError((error) {
      debugPrint('Error in settings stream: $error');
      throw Exception('Failed to load settings: $error');
    });
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
      debugPrint('Error getting user settings: $e');
      throw Exception('Failed to get user settings: $e');
    }
  }

  // Update user settings
  Future<void> updateUserSettings(UserSettings settings) async {
    _checkInitialized();
    try {
      await _currentUserSettings.set(settings.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating user settings: $e');
      throw Exception('Failed to update user settings: $e');
    }
  }

  // Delete user settings
  Future<void> deleteUserSettings() async {
    _checkInitialized();
    try {
      await _currentUserSettings.delete();
    } catch (e) {
      debugPrint('Error deleting user settings: $e');
      throw Exception('Failed to delete user settings: $e');
    }
  }

  // Tenants Collection Reference with caching
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
  Future<void> _initializeUserData() async {
    _checkInitialized();
    try {
      final userDoc = _firestore.doc('users/$_userId');
      final settingsDoc = _currentUserSettings;

      // Run in a transaction to ensure atomicity
      await _firestore.runTransaction((transaction) async {
        final userSnapshot = await transaction.get(userDoc);
        final settingsSnapshot = await transaction.get(settingsDoc);

        if (!userSnapshot.exists) {
          transaction.set(userDoc, {
            'createdAt': FieldValue.serverTimestamp(),
            'lastAccess': FieldValue.serverTimestamp(),
          });
        } else {
          transaction.update(userDoc, {
            'lastAccess': FieldValue.serverTimestamp(),
          });
        }

        if (!settingsSnapshot.exists) {
          transaction.set(settingsDoc, UserSettings().toMap());
        }
      });
    } catch (e) {
      debugPrint('Error initializing user data: $e');
      throw Exception('Failed to initialize user data: $e');
    }
  }
}
