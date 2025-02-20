import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../setup/test_setup.dart';

void main() {
  group('Navigation Tests', () {
    testWidgets('should render bottom navigation bar', (WidgetTester tester) async {
      final bottomNav = GNav(
        tabs: [
          GButton(icon: Icons.home, text: 'Home'),
          GButton(icon: Icons.people, text: 'Tenants'),
          GButton(icon: Icons.payment, text: 'Payments'),
          GButton(icon: Icons.settings, text: 'Settings'),
        ],
      );

      await tester.pumpWidget(TestSetup.wrapWithMaterialApp(bottomNav));
      await tester.pumpAndSettle();

      expect(find.byType(GNav), findsOneWidget);
      expect(find.byType(GButton), findsNWidgets(4));
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Tenants'), findsOneWidget);
      expect(find.text('Payments'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('should handle tab selection', (WidgetTester tester) async {
      int selectedIndex = 0;

      final bottomNav = GNav(
        selectedIndex: selectedIndex,
        onTabChange: (index) {
          selectedIndex = index;
        },
        tabs: [
          GButton(icon: Icons.home, text: 'Home'),
          GButton(icon: Icons.people, text: 'Tenants'),
          GButton(icon: Icons.payment, text: 'Payments'),
          GButton(icon: Icons.settings, text: 'Settings'),
        ],
      );

      await tester.pumpWidget(TestSetup.wrapWithMaterialApp(bottomNav));
      await tester.pumpAndSettle();

      // Test initial selection
      expect(selectedIndex, equals(0));
// Create a StatefulBuilder to manage state
await tester.pumpWidget(
  TestSetup.wrapWithMaterialApp(
    StatefulBuilder(
      builder: (context, setState) {
        return GNav(
          selectedIndex: selectedIndex,
          onTabChange: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          tabs: [
            GButton(icon: Icons.home, text: 'Home'),
            GButton(icon: Icons.people, text: 'Tenants'),
            GButton(icon: Icons.payment, text: 'Payments'),
            GButton(icon: Icons.settings, text: 'Settings'),
          ],
        );
      },
    ),
  ),
);

// Tap second tab
await tester.tap(find.byType(GButton).at(1));
await tester.pumpAndSettle();
expect(selectedIndex, equals(1));

// Tap fourth tab
await tester.tap(find.byType(GButton).at(3));
await tester.pumpAndSettle();
expect(selectedIndex, equals(3));
      expect(selectedIndex, equals(3));
    });
  });
}