import '../models/tenant.dart';
import '../models/room.dart';

class StatsService {
  static int getTotalTenants(List<Tenant> tenants) {
    return tenants.length;
  }

  static double getTotalMonthlyIncome(List<Tenant> tenants) {
    return tenants.fold(0.0, (sum, tenant) {
      if (tenant.paymentStatus.toLowerCase() == 'paid') {
        return sum + tenant.rentAmount;
      } else if (tenant.paymentStatus.toLowerCase() == 'partial' && tenant.paidAmount != null) {
        return sum + tenant.paidAmount!;
      }
      return sum;
    });
  }

  static double getCollectionRate(List<Tenant> tenants) {
    if (tenants.isEmpty) return 0.0;
    final paidOrPartial = tenants.where((tenant) =>
      tenant.paymentStatus.toLowerCase() == 'paid' ||
      tenant.paymentStatus.toLowerCase() == 'partial').length;
    return (paidOrPartial / tenants.length) * 100;
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

  static double getVacancyRate(List<Tenant> tenants, List<Room> rooms) {
    // Count total sections across all active rooms
    final totalSections = rooms.fold(0, (sum, room) => sum + room.sections.length);
    if (totalSections == 0) return 0.0;
    
    // Count occupied sections
    final occupiedSections = rooms.fold(0, (sum, room) => 
      sum + room.sections.where((section) => section.isOccupied).length);
    
    return ((totalSections - occupiedSections) / totalSections) * 100;
  }

  static List<MapEntry<DateTime, double>> getRevenueHistory(List<Tenant> tenants, {int months = 12}) {
    final history = <DateTime, double>{};
    final now = DateTime.now();

    // Initialize last N months with 0
    for (var i = 0; i < months; i++) {
      final month = DateTime(now.year, now.month - i);
      history[month] = 0;
    }

    // Calculate revenue for each month
    for (var tenant in tenants) {
      // For paid tenants, add full rent amount
      if (tenant.paymentStatus.toLowerCase() == 'paid') {
        final paymentMonth = DateTime(
          tenant.nextDueDate.year, 
          tenant.nextDueDate.month - 1,
        );
        
        if (history.containsKey(paymentMonth)) {
          history[paymentMonth] = (history[paymentMonth] ?? 0) + tenant.rentAmount;
        }
      } 
      // For partial payments, only add the paid amount
      else if (tenant.paymentStatus.toLowerCase() == 'partial' && tenant.paidAmount != null) {
        final paymentMonth = DateTime(
          tenant.nextDueDate.year, 
          tenant.nextDueDate.month - 1,
        );
        
        if (history.containsKey(paymentMonth)) {
          history[paymentMonth] = (history[paymentMonth] ?? 0) + tenant.paidAmount!;
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
