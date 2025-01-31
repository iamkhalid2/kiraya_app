import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/tenant_provider.dart';
import 'providers/complaint_provider.dart';
import 'providers/navigation_provider.dart';
import 'screens/main_screen.dart';
import 'services/hive_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveDatabase.instance.initialize();
  runApp(const RentManagementApp());
}

class RentManagementApp extends StatelessWidget {
  const RentManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TenantProvider()),
        ChangeNotifierProvider(create: (_) => ComplaintProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
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
        home: const MainScreen(),
      ),
    );
  }
}
