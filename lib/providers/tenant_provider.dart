import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/tenant.dart';
import '../services/firestore_service.dart';
import 'room_provider.dart';

class TenantProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Tenant> _tenants = [];
  String _searchQuery = '';
  bool _isLoading = false;
  Stream<List<Tenant>>? _tenantsStream;
  StreamSubscription<QuerySnapshot>? _tenantsSubscription;
  String? _userId;

  List<Tenant> get tenants => _searchQuery.isEmpty 
    ? _tenants 
    : _tenants.where((tenant) => 
        tenant.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        tenant.roomId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        tenant.section.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();

  bool get isLoading => _isLoading;
  bool get isInitialized => _userId != null;
  Stream<List<Tenant>>? get tenantsStream => _tenantsStream;

  void initialize(String userId) {
    if (_userId == userId) return;
    
    _tenantsSubscription?.cancel();
    _userId = userId;
    _firestoreService.initialize(userId);
    
    _tenantsSubscription = _firestoreService.tenantsStream.listen(
      (snapshot) {
        _tenants = snapshot.docs.map((doc) {
          return Tenant.fromMap(doc.id, doc.data() as Map<String, dynamic>);
        }).toList();
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Error in tenants subscription: $e');
        _tenants = [];
        notifyListeners();
      }
    );
  }

  void _checkInitialization() {
    if (!isInitialized) {
      throw Exception('TenantProvider not initialized');
    }
  }

  Future<void> addTenant(BuildContext context, Tenant tenant) async {
    _checkInitialization();
    try {
      // Validate that the room and section exist
      final roomProvider = Provider.of<RoomProvider>(context, listen: false);
      if (!roomProvider.isInitialized) {
        throw Exception('Room system is not initialized. Please try again.');
      }

      if (!roomProvider.rooms.any((room) => room.id == tenant.roomId)) {
        throw Exception('Selected room no longer exists. Please choose a different room.');
      }
      
      final room = roomProvider.rooms.firstWhere((room) => room.id == tenant.roomId);
      if (!room.hasSection(tenant.section)) {
        throw Exception('Selected section is not valid for this room.');
      }

      // Verify section availability
      if (room.getSection(tenant.section).isOccupied) {
        throw Exception('Selected section is no longer available. Please choose another section.');
      }

      // Add tenant first to get the ID
      final docRef = await _firestoreService.addTenant(tenant.toMap());
      final assignedTenant = tenant.copyWith(id: docRef.id);

      // Then update room occupancy with the new tenant ID
      await roomProvider.assignTenant(
        assignedTenant.roomId,
        assignedTenant.section,
        assignedTenant.id!
      );
    } catch (e) {
      debugPrint('Error adding tenant: $e');
      rethrow;
    }
  }

  Future<void> updateTenant(BuildContext context, Tenant tenant) async {
    _checkInitialization();
    if (tenant.id == null) {
      throw Exception('Cannot update tenant: Invalid tenant data');
    }

    try {
      // Get the old tenant data for comparison
      final oldTenant = _tenants.firstWhere(
        (t) => t.id == tenant.id,
        orElse: () => throw Exception('Tenant not found. They may have been deleted.'),
      );

      final roomProvider = Provider.of<RoomProvider>(context, listen: false);
      if (!roomProvider.isInitialized) {
        throw Exception('Room system is not initialized. Please try again.');
      }

      // Validate new room assignment if changed
      if (oldTenant.roomId != tenant.roomId) {
        if (!roomProvider.rooms.any((room) => room.id == tenant.roomId)) {
          throw Exception('Selected room no longer exists. Please choose a different room.');
        }

        final newRoom = roomProvider.rooms.firstWhere((room) => room.id == tenant.roomId);
        if (!newRoom.hasSection(tenant.section)) {
          throw Exception('Selected section is not valid for this room.');
        }
      }

      // If room or section changed, update room occupancy
      if (oldTenant.roomId != tenant.roomId || oldTenant.section != tenant.section) {
        await roomProvider.removeTenant(oldTenant.roomId, oldTenant.section);
        await roomProvider.assignTenant(tenant.roomId, tenant.section, tenant.id!);
      }

      // Update tenant data
      await _firestoreService.updateTenant(tenant.id!, tenant.toMap());
    } catch (e) {
      debugPrint('Error updating tenant: $e');
      rethrow;
    }
  }

  Future<void> deleteTenant(BuildContext context, String id) async {
    _checkInitialization();
    try {
      // Get tenant before deletion
      final tenant = _tenants.firstWhere(
        (t) => t.id == id,
        orElse: () => throw Exception('Tenant not found. They may have been already deleted.'),
      );

      final roomProvider = Provider.of<RoomProvider>(context, listen: false);
      if (!roomProvider.isInitialized) {
        throw Exception('Room system is not initialized. Please try again.');
      }

      // First remove from room to maintain data consistency
      await roomProvider.removeTenant(tenant.roomId, tenant.section);
      
      // Then delete tenant record
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
    _tenantsSubscription?.cancel();
    _tenants.clear();
    _searchQuery = '';
    _isLoading = false;
    _userId = null;
    super.dispose();
  }
}
