import 'package:flutter_test/flutter_test.dart';
import 'package:kiraya/models/tenant.dart';
import 'package:kiraya/services/stats_service.dart';

void main() {
  group('StatsService Tests', () {
    final testTenants = [
      Tenant(
        id: '1',
        name: 'Test Tenant 1',
        roomId: 'room1',
        section: 'A',
        rentAmount: 5000,
        initialDeposit: 10000,
        paymentStatus: 'paid',
        phoneNumber: '1234567890',
        joiningDate: DateTime(2024, 1, 1),
        nextDueDate: DateTime(2024, 3, 1),
      ),
      Tenant(
        id: '2',
        name: 'Test Tenant 2',
        roomId: 'room2',
        section: 'B',
        rentAmount: 6000,
        initialDeposit: 12000,
        paymentStatus: 'pending',
        phoneNumber: '0987654321',
        joiningDate: DateTime(2024, 2, 1),
        nextDueDate: DateTime(2024, 3, 1),
      ),
      Tenant(
        id: '3',
        name: 'Test Tenant 3',
        roomId: 'room3',
        section: 'A',
        rentAmount: 4500,
        initialDeposit: 9000,
        paymentStatus: 'partial',
        phoneNumber: '5555555555',
        joiningDate: DateTime(2024, 2, 15),
        nextDueDate: DateTime(2024, 3, 15),
      ),
    ];

    test('getTotalTenants returns correct count', () {
      expect(StatsService.getTotalTenants(testTenants), 3);
    });

    test('getTotalMonthlyIncome calculates correctly', () {
      expect(StatsService.getTotalMonthlyIncome(testTenants), 15500);
    });

    test('getCollectionRate calculates correctly', () {
      // 2 out of 3 tenants have paid or partial status
      expect(StatsService.getCollectionRate(testTenants), (2/3) * 100);
    });

    test('getPaymentStatusDistribution returns correct counts', () {
      final distribution = StatsService.getPaymentStatusDistribution(testTenants);
      expect(distribution['paid'], 1);
      expect(distribution['pending'], 1);
      expect(distribution['partial'], 1);
    });

    test('getVacancyRate calculates correctly', () {
      // 3 tenants in 5 total rooms = 40% vacancy
      expect(StatsService.getVacancyRate(testTenants, 5), 40.0);
    });

    test('getTotalDeposits calculates correctly', () {
      expect(StatsService.getTotalDeposits(testTenants), 31000);
    });

    test('getRevenueHistory returns correct data structure', () {
      final history = StatsService.getRevenueHistory(testTenants);
      expect(history, isA<List<MapEntry<DateTime, double>>>());
      expect(history.length, 6); // Default 6 months
    });

    test('getTenantMetrics returns all required metrics', () {
      final metrics = StatsService.getTenantMetrics(testTenants);
      expect(metrics.containsKey('newTenants'), true);
      expect(metrics.containsKey('dueSoon'), true);
      expect(metrics.containsKey('overdue'), true);
    });

    test('getTenantsWithDuePayments returns sorted list', () {
      final dueTenants = StatsService.getTenantsWithDuePayments(testTenants);
      expect(dueTenants, isA<List<Tenant>>());
      
      // Verify sorting
      for (var i = 0; i < dueTenants.length - 1; i++) {
        expect(
          dueTenants[i].nextDueDate.isBefore(dueTenants[i + 1].nextDueDate) ||
          dueTenants[i].nextDueDate.isAtSameMomentAs(dueTenants[i + 1].nextDueDate),
          true,
        );
      }
    });
  });
}
