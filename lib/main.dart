import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;  // Hide Firebase's AuthProvider
import 'firebase_options.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/tenant_list_screen.dart';
import 'screens/rooms/room_grid_screen.dart';
import 'screens/settings_screen.dart';
import 'providers/tenant_provider.dart';
import 'providers/room_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/user_settings_provider.dart';
import 'screens/auth/auth_wrapper.dart';
import 'widgets/loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, UserSettingsProvider>(
          create: (_) => UserSettingsProvider(),
          update: (_, auth, previous) {
            if (auth.user != null) {
              previous?.initialize(auth.user!.uid);
            }
            return previous ?? UserSettingsProvider();
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, RoomProvider>(
          create: (_) => RoomProvider(),
          update: (_, auth, previous) {
            if (auth.user != null) {
              previous?.initialize(auth.user!.uid);
            }
            return previous ?? RoomProvider();
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, TenantProvider>(
          create: (_) => TenantProvider(),
          update: (_, auth, previous) {
            if (auth.user != null) {
              previous?.initialize(auth.user!.uid);
            }
            return previous ?? TenantProvider();
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kiraya',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          backgroundColor: Colors.white,
          elevation: 2,
          indicatorColor: Color(0xFF1976D2).withAlpha(26),
        ),
        cardTheme: CardTheme(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1976D2)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return StreamBuilder<User?>(
            stream: auth.authStateChanges,
            builder: (ctx, authSnapshot) {
              if (authSnapshot.connectionState == ConnectionState.waiting) {
                return const LoadingScreen();
              }
              
              // No need to explicitly initialize with null since providers already handle it
              if (!authSnapshot.hasData) {
                return const AuthWrapper();
              }
              
              return const HomeScreen();
            },
          );
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TenantListScreen(),
    const RoomGridScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people),
            label: 'Tenants',
          ),
          NavigationDestination(
            icon: Icon(Icons.meeting_room),
            label: 'Rooms',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
