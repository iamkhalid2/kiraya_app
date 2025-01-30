import '../models/tenant.dart';

class StatsService {
  static int getTotalTenants(List<Tenant> tenants) {
    return tenants.length;
  }

  static double getTotalMonthlyIncome(List<Tenant> tenants) {
    return tenants.fold(0.0, (sum, tenant) => sum + tenant.rentAmount);
  }

  static double getCollectionRate(List<Tenant> tenants) {
    if (tenants.isEmpty) return 0.0;
    
    final paidTenants = tenants.where((tenant) => 
      tenant.paymentStatus.toLowerCase() == 'paid' || 
      tenant.paymentStatus.toLowerCase() == 'partial'
    ).length;
    
    return (paidTenants / tenants.length) * 100;
  }

  static Map<String, int> getPaymentStatusDistribution(List<Tenant> tenants) {
    final distribution = {
      'paid': 0,
      'pending': 0,
      'partial': 0,
    };

    for (var tenant in tenants) {
      final status = tenant.paymentStatus.toLowerCase();
      if (distribution.containsKey(status)) {
        distribution[status] = (distribution[status] ?? 0) + 1;
      }
    }

    return distribution;
  }

  static double getCurrentMonthCollection(List<Tenant> tenants) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    
    return tenants
        .where((tenant) => 
            tenant.lastPaymentDate.isAfter(currentMonth) && 
            (tenant.paymentStatus.toLowerCase() == 'paid' || 
             tenant.paymentStatus.toLowerCase() == 'partial'))
        .fold(0.0, (sum, tenant) => sum + tenant.rentAmount);
  }

  static double getVacancyRate(List<Tenant> tenants, int totalRooms) {
    if (totalRooms == 0) return 0.0;
    return ((totalRooms - tenants.length) / totalRooms) * 100;
  }

  static List<MapEntry<DateTime, double>> getRevenueHistory(List<Tenant> tenants, {int months = 6}) {
    final history = <DateTime, double>{};
    final now = DateTime.now();

    // Initialize last 6 months with 0
    for (var i = 0; i < months; i++) {
      final month = DateTime(now.year, now.month - i);
      history[month] = 0;
    }

    // Calculate revenue for each month
    for (var tenant in tenants) {
      final paymentDate = tenant.lastPaymentDate;
      final monthKey = DateTime(paymentDate.year, paymentDate.month);
      
      if (history.containsKey(monthKey)) {
        history[monthKey] = (history[monthKey] ?? 0) + tenant.rentAmount;
      }
    }

    return history.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
  }
}
