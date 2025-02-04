import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tenant.dart';
import '../services/firestore_service.dart';

class TenantProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Tenant> _tenants = [];
  String _searchQuery = '';
  bool _isLoading = false;
  Stream<List<Tenant>>? _tenantsStream;

  List<Tenant> get tenants => _searchQuery.isEmpty 
    ? _tenants 
    : _tenants.where((tenant) => 
        tenant.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        tenant.roomNumber.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();

  bool get isLoading => _isLoading;
  Stream<List<Tenant>>? get tenantsStream => _tenantsStream;

  TenantProvider() {
    // Initialize the stream
    _tenantsStream = _firestoreService.tenantsStream.map((snapshot) {
      if (snapshot == null) return [];
      return snapshot.docs.map((doc) {
        return Tenant.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });

    // Listen to stream updates
    _tenantsStream?.listen((tenants) {
      _tenants = tenants;
      notifyListeners();
    });
  }

  Future<void> addTenant(Tenant tenant) async {
    try {
      await _firestoreService.addTenant(tenant.toMap());
    } catch (e) {
      debugPrint('Error adding tenant: $e');
      rethrow;
    }
  }

  Future<void> updateTenant(Tenant tenant) async {
    try {
      if (tenant.id == null) throw Exception('Tenant ID cannot be null');
      await _firestoreService.updateTenant(tenant.id!, tenant.toMap());
    } catch (e) {
      debugPrint('Error updating tenant: $e');
      rethrow;
    }
  }

  Future<void> deleteTenant(String id) async {
    try {
      await _firestoreService.deleteTenant(id);
    } catch (e) {
      debugPrint('Error deleting tenant: $e');
      rethrow;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearchQuery() {
    _searchQuery = '';
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
