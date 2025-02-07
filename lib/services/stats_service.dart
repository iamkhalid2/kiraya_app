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
            tenant.nextDueDate.isAfter(currentMonth) && 
            tenant.paymentStatus.toLowerCase() == 'paid')
        .fold(0.0, (sum, tenant) => sum + tenant.rentAmount);
  }

  static List<Tenant> getTenantsWithDuePayments(List<Tenant> tenants) {
    final now = DateTime.now();
    return tenants
        .where((tenant) => 
            tenant.nextDueDate.isBefore(now) || 
            tenant.nextDueDate.isAtSameMomentAs(now))
        .toList()
      ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
  }

  static double getTotalDeposits(List<Tenant> tenants) {
    return tenants.fold(0.0, (sum, tenant) => sum + tenant.initialDeposit);
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

    // Calculate revenue for each month based on due dates and payment status
    for (var tenant in tenants) {
      if (tenant.paymentStatus.toLowerCase() == 'paid') {
        final dueDate = tenant.nextDueDate;
        // Look at the previous month since nextDueDate is for next payment
        final paymentMonth = DateTime(dueDate.year, dueDate.month - 1);
        
        if (history.containsKey(paymentMonth)) {
          history[paymentMonth] = (history[paymentMonth] ?? 0) + tenant.rentAmount;
        }
      }
    }

    return history.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
  }

  static Map<String, double> getTenantMetrics(List<Tenant> tenants) {
    final now = DateTime.now();
    final oneMonthAgo = DateTime(now.year, now.month - 1, now.day);

    final newTenants = tenants.where((tenant) => 
      tenant.joiningDate.isAfter(oneMonthAgo)).length;

    final dueSoon = tenants.where((tenant) => 
      tenant.nextDueDate.isAfter(now) && 
      tenant.nextDueDate.isBefore(now.add(const Duration(days: 7)))).length;

    final overdue = tenants.where((tenant) => 
      tenant.nextDueDate.isBefore(now) && 
      tenant.paymentStatus.toLowerCase() != 'paid').length;

    return {
      'newTenants': newTenants.toDouble(),
      'dueSoon': dueSoon.toDouble(),
      'overdue': overdue.toDouble(),
    };
  }
}
