import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:kiraya/main.dart';
import 'package:kiraya/providers/tenant_provider.dart';

void main() {
  testWidgets('Rent Management App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => TenantProvider(),
        child: const RentManagementApp(),
      ),
    );

    expect(find.text('Rent Management'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.filter_list), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
