import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/tenant.dart';

class HiveDatabase {
  static const String _tenantsBoxName = 'tenants';
  static final HiveDatabase instance = HiveDatabase._init();
  Box<Tenant>? _tenantsBox;

  HiveDatabase._init();

  Future<void> initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TenantAdapter());
    _tenantsBox = await Hive.openBox<Tenant>(_tenantsBoxName);
  }

  Future<Tenant> create(Tenant tenant) async {
    try {
      final id = await _tenantsBox!.add(tenant);
      tenant.id = id;
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
      return _tenantsBox!.get(id);
    } catch (e) {
      debugPrint('Error getting tenant: $e');
      return null;
    }
  }

  Future<void> update(Tenant tenant) async {
    try {
      await _tenantsBox!.put(tenant.id, tenant);
    } catch (e) {
      debugPrint('Error updating tenant: $e');
      rethrow;
    }
  }

  Future<void> delete(int id) async {
    try {
      await _tenantsBox!.delete(id);
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

  Future<void> close() async {
    await _tenantsBox?.close();
  }
}
