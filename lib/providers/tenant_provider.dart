import 'package:flutter/foundation.dart';
import '../models/tenant.dart';
import '../services/hive_database.dart';

class TenantProvider with ChangeNotifier {
  List<Tenant> _tenants = [];
  String _searchQuery = '';
  bool _isLoading = false;

  List<Tenant> get tenants => _searchQuery.isEmpty 
    ? _tenants 
    : _tenants.where((tenant) => 
        tenant.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        tenant.roomNumber.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();

  bool get isLoading => _isLoading;

  Future<void> loadTenants() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tenants = await HiveDatabase.instance.getAllTenants();
    } catch (e) {
      debugPrint('Error loading tenants: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTenant(Tenant tenant) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newTenant = await HiveDatabase.instance.create(tenant);
      _tenants.add(newTenant);
    } catch (e) {
      debugPrint('Error adding tenant: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTenant(Tenant tenant) async {
    _isLoading = true;
    notifyListeners();

    try {
      await HiveDatabase.instance.update(tenant);
      final index = _tenants.indexWhere((t) => t.id == tenant.id);
      if (index != -1) {
        _tenants[index] = tenant;
      }
    } catch (e) {
      debugPrint('Error updating tenant: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTenant(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      // First remove from list to update UI immediately
      _tenants.removeWhere((tenant) => tenant.id == id);
      notifyListeners();
      
      // Then delete from database
      await HiveDatabase.instance.delete(id);
    } catch (e) {
      debugPrint('Error deleting tenant: $e');
      // If deletion fails, reload tenants to restore state
      await loadTenants();
    } finally {
      _isLoading = false;
      notifyListeners();
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
}
