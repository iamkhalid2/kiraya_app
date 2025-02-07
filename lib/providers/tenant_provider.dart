import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/tenant.dart';
import '../services/firestore_service.dart';
import 'room_provider.dart';

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
        tenant.roomId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        tenant.section.toLowerCase().contains(_searchQuery.toLowerCase())
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

  Future<void> addTenant(BuildContext context, Tenant tenant) async {
    try {
      // Validate that the room and section exist
      final roomProvider = Provider.of<RoomProvider>(context, listen: false);
      if (!roomProvider.rooms.any((room) => room.id == tenant.roomId)) {
        throw Exception('Invalid room selected');
      }
      
      final room = roomProvider.rooms.firstWhere((room) => room.id == tenant.roomId);
      if (!room.hasSection(tenant.section)) {
        throw Exception('Invalid section selected');
      }

      final docRef = await _firestoreService.addTenant(tenant.toMap());
      // Update room occupancy
      await roomProvider.assignTenant(tenant.roomId, tenant.section, docRef.id);
    } catch (e) {
      debugPrint('Error adding tenant: $e');
      rethrow;
    }
  }

  Future<void> updateTenant(BuildContext context, Tenant tenant) async {
    try {
      if (tenant.id == null) throw Exception('Tenant ID cannot be null');
      await _firestoreService.updateTenant(tenant.id!, tenant.toMap());
    } catch (e) {
      debugPrint('Error updating tenant: $e');
      rethrow;
    }
  }

  Future<void> deleteTenant(BuildContext context, String id) async {
    try {
      // Get tenant before deletion to get room info
      final tenant = _tenants.firstWhere((t) => t.id == id);
      await _firestoreService.deleteTenant(id);
      // Update room occupancy
      final roomProvider = Provider.of<RoomProvider>(context, listen: false);
      await roomProvider.removeTenant(tenant.roomId, tenant.section);
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
