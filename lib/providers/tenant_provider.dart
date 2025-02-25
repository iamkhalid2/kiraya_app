import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/tenant.dart';
import '../services/firestore_service.dart';
import 'room_provider.dart';

enum TenantSortBy { name, paymentStatus, roomNumber }

class TenantProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Tenant> _tenants = [];
  String _searchQuery = '';
  bool _isLoading = true;
  String? _userId;
  TenantSortBy _sortBy = TenantSortBy.name;
  StreamSubscription<QuerySnapshot>? _tenantsSubscription;

  void _checkInitialization() {
    if (!isInitialized) {
      throw Exception('TenantProvider not initialized');
    }
  }

  TenantSortBy get sortBy => _sortBy;

  List<Tenant> get tenants {
    var filteredTenants = _searchQuery.isEmpty 
      ? List<Tenant>.from(_tenants)
      : _tenants.where((tenant) => 
          tenant.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tenant.roomId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tenant.section.toLowerCase().contains(_searchQuery.toLowerCase())
        ).toList();

    switch (_sortBy) {
      case TenantSortBy.name:
        filteredTenants.sort((a, b) => a.name.compareTo(b.name));
      case TenantSortBy.paymentStatus:
        filteredTenants.sort((a, b) {
          // Custom sort order: Pending -> Partial -> Paid
          final order = {'pending': 0, 'partial': 1, 'paid': 2};
          return (order[a.paymentStatus.toLowerCase()] ?? 0)
              .compareTo(order[b.paymentStatus.toLowerCase()] ?? 0);
        });
      case TenantSortBy.roomNumber:
        filteredTenants.sort((a, b) => a.roomNumber.compareTo(b.roomNumber));
    }
    
    return filteredTenants;
  }

  bool get isLoading => _isLoading;
  bool get isInitialized => _userId != null;

  Stream<List<Tenant>> get tenantsStream {
    if (!isInitialized) return Stream.value([]);
    return _firestoreService.tenantsStream.map((snapshot) {
      _tenants = snapshot.docs.map((doc) => 
        Tenant.fromMap(doc.id, doc.data() as Map<String, dynamic>)
      ).toList();
      notifyListeners();
      return _tenants;
    }).handleError((error) {
      debugPrint('Error in tenants stream: $error');
      _tenants = [];
      notifyListeners();
      return [];
    });
  }

  void initialize(String? userId) {
    // Always cancel existing subscription first
    _tenantsSubscription?.cancel();
    
    if (userId == null) {
      // Handle logout
      _tenants = [];
      _userId = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Reset state before initializing
    _tenants = [];
    _isLoading = true;
    notifyListeners();

    // Initialize with new user ID
    _userId = userId;
    _firestoreService.initialize(userId);

    // Set up new subscription
    _tenantsSubscription = _firestoreService.tenantsStream.listen(
      (snapshot) {
        _tenants = snapshot.docs.map((doc) {
          return Tenant.fromMap(doc.id, doc.data() as Map<String, dynamic>);
        }).toList();
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Error in tenants subscription: $e');
        _tenants = [];
        _isLoading = false;
        notifyListeners();
      },
    );
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
      if (oldTenant.roomId != tenant.roomId || oldTenant.section != tenant.section) {
        if (!roomProvider.rooms.any((room) => room.id == tenant.roomId)) {
          throw Exception('Selected room no longer exists. Please choose a different room.');
        }

        final newRoom = roomProvider.rooms.firstWhere((room) => room.id == tenant.roomId);
        if (!newRoom.hasSection(tenant.section)) {
          throw Exception('Selected section is not valid for this room.');
        }

        // Update tenant data first
        await _firestoreService.updateTenant(tenant.id!, tenant.toMap());

        // Then update room assignments
        await roomProvider.assignTenant(tenant.roomId, tenant.section, tenant.id!);
        await roomProvider.removeTenant(oldTenant.roomId, oldTenant.section);
      } else {
        // If room/section hasn't changed, just update tenant data
        await _firestoreService.updateTenant(tenant.id!, tenant.toMap());
      }
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

  void setSortBy(TenantSortBy sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }

  @override
  void dispose() {
    _tenantsSubscription?.cancel();
    _tenants = [];
    _searchQuery = '';
    _isLoading = false;
    _userId = null;
    super.dispose();
  }
}
