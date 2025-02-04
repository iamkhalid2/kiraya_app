import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/tenant_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/user_settings_provider.dart';
import 'screens/auth/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const RentManagementApp());
}

class RentManagementApp extends StatelessWidget {
  const RentManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ProxyProvider<AuthProvider, void>(
          update: (_, auth, __) {
            if (auth.isAuthenticated) {
              final nav = Provider.of<NavigationProvider>(_, listen: false);
              nav.reset(); // Reset to dashboard when authenticated
            }
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, UserSettingsProvider>(
          create: (_) => UserSettingsProvider(),
          update: (_, auth, previous) {
            if (!auth.isAuthenticated) {
              return UserSettingsProvider();
            }
            return previous ?? UserSettingsProvider()..loadSettings();
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, TenantProvider>(
          create: (_) => TenantProvider(),
          update: (_, auth, previous) {
            if (!auth.isAuthenticated) {
              return TenantProvider();
            }
            // Create new instance when authenticated to reset state
            return auth.isAuthenticated ? TenantProvider() : (previous ?? TenantProvider());
          },
        ),
      ],
      child: MaterialApp(
        title: 'Kiraya',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          cardTheme: const CardTheme(
            elevation: 2,
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}
