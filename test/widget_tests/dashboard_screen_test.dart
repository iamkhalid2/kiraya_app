import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:kiraya/providers/tenant_provider.dart';
import 'package:kiraya/providers/user_settings_provider.dart';
import 'package:kiraya/screens/dashboard/dashboard_screen.dart';
import 'package:kiraya/models/tenant.dart';

void main() {
  group('DashboardScreen Widget Tests', () {
    late TenantProvider tenantProvider;
    late UserSettingsProvider settingsProvider;

    setUp(() {
      tenantProvider = TenantProvider();
      settingsProvider = UserSettingsProvider();
    });

    Future<void> pumpDashboard(WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<TenantProvider>.value(
              value: tenantProvider,
            ),
            ChangeNotifierProvider<UserSettingsProvider>.value(
              value: settingsProvider,
            ),
          ],
          child: const MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('DashboardScreen shows loading indicator initially',
        (WidgetTester tester) async {
      await pumpDashboard(tester);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('DashboardScreen shows stats cards when data is available',
        (WidgetTester tester) async {
      // Setup test data
      final testTenants = [
        Tenant(
          id: '1',
          name: 'Test Tenant',
          roomId: 'room1',
          section: 'A',
          rentAmount: 5000,
          initialDeposit: 10000,
          paymentStatus: 'paid',
          phoneNumber: '1234567890',
          joiningDate: DateTime.now(),
          nextDueDate: DateTime.now().add(const Duration(days: 30)),
        ),
      ];

      // Pump the widget
      await pumpDashboard(tester);

      // Verify stats cards
      expect(find.text('Total Tenants'), findsOneWidget);
      expect(find.text('Monthly Income'), findsOneWidget);
      expect(find.text('Collection Rate'), findsOneWidget);
      expect(find.text('Vacancy Rate'), findsOneWidget);
    });

    testWidgets('DashboardScreen shows revenue history chart',
        (WidgetTester tester) async {
      await pumpDashboard(tester);
      expect(find.text('Revenue History'), findsOneWidget);
    });

    testWidgets('DashboardScreen shows payment status distribution',
        (WidgetTester tester) async {
      await pumpDashboard(tester);
      expect(find.text('Payment Status'), findsOneWidget);
      expect(find.text('Paid'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Partial'), findsOneWidget);
    });
  });
}
