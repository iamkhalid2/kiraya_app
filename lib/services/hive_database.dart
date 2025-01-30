import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/tenant.dart';
import '../models/complaint.dart';

class HiveDatabase {
  static const String _tenantsBoxName = 'tenants';
  static const String _complaintsBoxName = 'complaints';
  static final HiveDatabase instance = HiveDatabase._init();
  
  Box<Tenant>? _tenantsBox;
  Box<Complaint>? _complaintsBox;

  HiveDatabase._init();

  Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(TenantAdapter());
    Hive.registerAdapter(ComplaintAdapter());
    
    // Open boxes
    _tenantsBox = await Hive.openBox<Tenant>(_tenantsBoxName);
    _complaintsBox = await Hive.openBox<Complaint>(_complaintsBoxName);
  }

  Future<Tenant> create(Tenant tenant) async {
    try {
      // Get the next available ID
      int nextId = 1;
      if (_tenantsBox!.isNotEmpty) {
        final lastTenant = _tenantsBox!.values.last;
        nextId = (lastTenant.id ?? 0) + 1;
      }
      tenant.id = nextId;
      await _tenantsBox!.put(nextId.toString(), tenant);
      return tenant;
    } catch (e) {
      debugPrint('Error creating tenant: $e');
      rethrow;
    }
  }

  Future<List<Tenant>> getAllTenants() async {
    try {
      return _tenantsBox!.values.toList();
    } catch (e) {
      debugPrint('Error getting tenants: $e');
      return [];
    }
  }

  Future<Tenant?> getTenant(int id) async {
    try {
      return _tenantsBox!.get(id.toString());
    } catch (e) {
      debugPrint('Error getting tenant: $e');
      return null;
    }
  }

  Future<void> update(Tenant tenant) async {
    try {
      if (tenant.id != null) {
        await _tenantsBox!.put(tenant.id.toString(), tenant);
      }
    } catch (e) {
      debugPrint('Error updating tenant: $e');
      rethrow;
    }
  }

  Future<void> delete(int id) async {
    try {
      await _tenantsBox!.delete(id.toString());
    } catch (e) {
      debugPrint('Error deleting tenant: $e');
      rethrow;
    }
  }

  Future<List<Tenant>> searchTenants(String query) async {
    try {
      final lowercaseQuery = query.toLowerCase();
      return _tenantsBox!.values.where((tenant) =>
        tenant.name.toLowerCase().contains(lowercaseQuery) ||
        tenant.roomNumber.toLowerCase().contains(lowercaseQuery)
      ).toList();
    } catch (e) {
      debugPrint('Error searching tenants: $e');
      return [];
    }
  }

  // Complaint Methods
  Future<Complaint> createComplaint(Complaint complaint) async {
    try {
      int nextId = 1;
      if (_complaintsBox!.isNotEmpty) {
        final lastComplaint = _complaintsBox!.values.last;
        nextId = (lastComplaint.id ?? 0) + 1;
      }
      complaint.id = nextId;
      await _complaintsBox!.put(nextId.toString(), complaint);
      return complaint;
    } catch (e) {
      debugPrint('Error creating complaint: $e');
      rethrow;
    }
  }

  Future<List<Complaint>> getAllComplaints() async {
    try {
      return _complaintsBox!.values.toList();
    } catch (e) {
      debugPrint('Error getting complaints: $e');
      return [];
    }
  }

  Future<Complaint?> getComplaint(int id) async {
    try {
      return _complaintsBox!.get(id.toString());
    } catch (e) {
      debugPrint('Error getting complaint: $e');
      return null;
    }
  }

  Future<void> updateComplaint(Complaint complaint) async {
    try {
      if (complaint.id != null) {
        await _complaintsBox!.put(complaint.id.toString(), complaint);
      }
    } catch (e) {
      debugPrint('Error updating complaint: $e');
      rethrow;
    }
  }

  Future<void> deleteComplaint(int id) async {
    try {
      await _complaintsBox!.delete(id.toString());
    } catch (e) {
      debugPrint('Error deleting complaint: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    await _tenantsBox?.close();
    await _complaintsBox?.close();
  }
}
