import '../models/tenant.dart';

class WebDatabase {
  static final WebDatabase _instance = WebDatabase._internal();
  static WebDatabase get instance => _instance;
  
  final List<Tenant> _tenants = [];
  int _lastId = 0;

  WebDatabase._internal();

  Future<Tenant> createTenant(Tenant tenant) async {
    _lastId++;
    final newTenant = tenant.copyWith(id: _lastId);
    _tenants.add(newTenant);
    return newTenant;
  }

  Future<List<Tenant>> getAllTenants() async {
    return List.from(_tenants);
  }

  Future<Tenant?> getTenant(int id) async {
    return _tenants.firstWhere((t) => t.id == id);
  }

  Future<void> updateTenant(Tenant tenant) async {
    final index = _tenants.indexWhere((t) => t.id == tenant.id);
    if (index != -1) {
      _tenants[index] = tenant;
    }
  }

  Future<void> deleteTenant(int id) async {
    _tenants.removeWhere((t) => t.id == id);
  }

  Future<List<Tenant>> searchTenants(String query) async {
    final lowercaseQuery = query.toLowerCase();
    return _tenants.where((tenant) =>
      tenant.name.toLowerCase().contains(lowercaseQuery) ||
      tenant.roomNumber.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }
}
