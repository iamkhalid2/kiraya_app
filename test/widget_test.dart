import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:kiraya/main.dart';
import 'package:kiraya/providers/auth_provider.dart';
import 'package:kiraya/providers/room_provider.dart';
import 'package:kiraya/providers/tenant_provider.dart';
import 'package:kiraya/providers/user_settings_provider.dart';

void main() {
  testWidgets('App initializes with loading state', (WidgetTester tester) async {
    // Build our app with required providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => UserSettingsProvider()),
          ChangeNotifierProvider(create: (_) => RoomProvider()),
          ChangeNotifierProvider(create: (_) => TenantProvider()),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the loading indicator is shown initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
