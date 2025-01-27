import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/tenant_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const RentManagementApp());
}

class RentManagementApp extends StatelessWidget {
  const RentManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TenantProvider(),
      child: MaterialApp(
        title: 'Rent Management',
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
        home: const HomeScreen(),
      ),
    );
  }
}
